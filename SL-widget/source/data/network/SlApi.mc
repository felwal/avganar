using Toybox.Communications;
using Toybox.Lang;
using Toybox.WatchUi;

class SlApi {

    // edges of the SL zone, with an extra 2 km offset
    private static const _BOUNDS_SOUTH = 58.783223; // Ankarudden (Nynäshamn)
    private static const _BOUNDS_NORTH = 60.225171; // Ellans Vändplan (Norrtälje)
    private static const _BOUNDS_WEST = 17.239541; // Dammen (Nykvarn)
    private static const _BOUNDS_EAST = 19.116554; // Räfsnäs Brygga (Norrtälje)

    private static const _RESPONSE_OK = 200;

    // nearby stops max stops (max = 1000)
    private static const _MAX_STOPS = 25;
    // departures max departures
    private static const _MAX_DEPARTURES = 5;
    // departures time window (max = 60)
    private static const _TIME_WINDOW = 60;
    private static const _TIME_WINDOW_SHORT = 10;
    // nearby stops radius (max = 2000)
    private static const _maxRadius = 2000;

    private var _storage;
    private var _stopCursor;

    private var _maxStops;
    private var _maxDepartures;
    private var _timeWindow;

    // init

    private function initialize(storage, stopCursor, maxStops, maxDepartures, timeWindow) {
        _storage = storage;
        _stopCursor = stopCursor;
        _maxStops = maxStops;
        _maxDepartures = maxDepartures;
        _timeWindow = timeWindow;
    }

    static function detailRequester(storage, stopCursor, shortTimeWindow) {
        var timeWindow = shortTimeWindow ? _TIME_WINDOW_SHORT : _TIME_WINDOW;
        return new SlApi(storage, stopCursor, _MAX_STOPS, _MAX_DEPARTURES, timeWindow);
    }

    // nearby stops (Närliggande Hållplatser 2)
    // bronze: 10_000/month, 30/min

    function requestNearbyStops(lat, lon) {
        // check if outside bounds, to not make unnecessary calls outside the SL zone
        if (lat < _BOUNDS_SOUTH || lat > _BOUNDS_NORTH || lon < _BOUNDS_WEST || lon > _BOUNDS_EAST) {
            Log.i("Location outside bounds; skipping request");
            _storage.setPlaceholderStop(Stop.ERROR_CODE_OUTSIDE_BOUNDS, rez(Rez.Strings.lbl_i_stops_outside_bounds));
            _storage.setPlaceholderDeparture(0, null, "At " + PositionModel.format(lat, lon));

            return;
        }

        Log.i("Requesting stops for coords (" + lat + ", " + lon + ") ...");
        _requestNearbyStops(lat, lon, _maxStops, method(:onReceiveNearbyStops));
    }

    private function _requestNearbyStops(lat, lon, maxNo, responseCallback) {
        var url = "https://api.sl.se/api2/nearbystopsv2";

        var params = {
            "key" => KEY_NH,
            "originCoordLat" => lat,
            "originCoordLong" => lon,
            "r" => _maxRadius,
            "maxNo" => maxNo
        };

        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
            :headers => { "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON }
        };

        Communications.makeWebRequest(url, params, options, responseCallback);
    }

    function onReceiveNearbyStops(responseCode, data) {
        if (responseCode == _RESPONSE_OK && data != null) {
            var requestDepartures = _handleNearbyStopsResponseOk(data, _maxStops);

            // request departures
            if (requestDepartures) {
                requestDepartures();
            }
        }
        else {
            _handleNearbyStopsResponseError(responseCode, data);
        }

        WatchUi.requestUpdate();
    }

    //! @return If the selected stop has changed and departures should be requested
    private function _handleNearbyStopsResponseOk(data, maxStops) {
        Log.d("Stops response success: " + data);

        // no stops were found
        if (!DictCompat.hasKey(data, "stopLocationOrCoordLocation")) {
            var message;

            if (DictCompat.hasKey(data, "Message")) {
                message = data["Message"];
            }
            else {
                message = rez(Rez.Strings.lbl_i_stops_none_found);
            }

            _storage.setPlaceholderStop(Stop.ERROR_CODE_NO_STOPS, message);
            return false;
        }

        // stops were found

        var stopIds = [];
        var stopNames = [];
        var stops = [];

        var stopsData = data["stopLocationOrCoordLocation"];
        for (var i = 0; i < maxStops && i < stopsData.size(); i++) {
            var stopData = stopsData[i]["StopLocation"];

            var extId = stopData["mainMastExtId"];
            var id = extId.substring(5, extId.length()).toNumber();
            var name = stopData["name"];

            stopIds.add(id);
            stopNames.add(name);
            stops.add(new Stop(id, name));
        }

        // apply

        var oldSelectedStop = _storage.getStop(_stopCursor);
        var newSelectedStopId = ArrCompat.coerceGet(stopIds, _stopCursor);

        Log.d("Old siteId: " + oldSelectedStop.id + "; new siteId: " + newSelectedStopId);

        if (oldSelectedStop.id == newSelectedStopId) {
            // copy departures for selected stop as they have not changed
            // we still need to change stops, as any unselected stop may have changed
            ArrCompat.coerceGet(stops, _stopCursor).setDepartures(oldSelectedStop.getAllDepartures());
            _storage.setStops(stopIds, stopNames, stops);
            return false;
        }
        _storage.setStops(stopIds, stopNames, stops);
        return true;
    }

    private function _handleNearbyStopsResponseError(responseCode, data) {
        Log.i("Stops response error (code " + responseCode + "): " + data);

        var message;

        if (DictCompat.hasKey(data, "Message")) {
            message = data["Message"];
        }
        else if (responseCode == _RESPONSE_OK) {
            message = rez(Rez.Strings.lbl_e_null_data);
        }
        else if (responseCode == Communications.BLE_CONNECTION_UNAVAILABLE) {
            // no bluetooth
            message = rez(Rez.Strings.lbl_e_connection);
        }
        else if (responseCode == Communications.NETWORK_REQUEST_TIMED_OUT) {
            // no internet
            message = rez(Rez.Strings.lbl_e_connection);
        }
        else if (responseCode == Communications.NETWORK_RESPONSE_OUT_OF_MEMORY) {
            message = rez(Rez.Strings.lbl_e_memory);
        }
        else if (responseCode == Communications.BLE_QUEUE_FULL) {
            message = rez(Rez.Strings.lbl_e_queue_full);
        }
        else if (responseCode == Communications.BLE_REQUEST_CANCELLED || responseCode == Communications.REQUEST_CANCELLED) {
            message = rez(Rez.Strings.lbl_e_cancelled);
        }
        else {
            message = rez(Rez.Strings.lbl_e_general) + " " + responseCode;
        }

        _storage.setPlaceholderStop(responseCode, message);
    }

    // departures (Realtidsinformation 4)
    // bronze: 10_000/month, 30/min
    // TODO: only call these when the time diff is > x s

    function requestDepartures() {
        var siteId = _storage.getStopId(_stopCursor);

        if (siteId != null && siteId != Stop.NO_ID) {
            Log.i("Requesting departures for siteId " + siteId + " ...");
            _requestDepartures(siteId);
        }
    }

    private function _requestDepartures(siteId) {
        var url = "https://api.sl.se/api2/realtimedeparturesv4.json";

        var params = {
            "key" => KEY_RI,
            "siteid" => siteId.toNumber(),
            "timewindow" => _timeWindow
        };

        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            // TODO: url doesnt work without .json
            //:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
            :headers => { "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON }
        };

        Communications.makeWebRequest(url, params, options, method(:onReceiveDepartures));
    }

    function onReceiveDepartures(responseCode, data) {
        if (responseCode == _RESPONSE_OK && DictCompat.hasKey(data, "ResponseData")) {
            Log.d("Departures response success: " + data);

            var modes = [ "Metros", "Buses", "Trains", "Trams", "Ships" ];
            var departures = [];

            for (var m = 0; m < modes.size(); m++) {
                var modeData = data["ResponseData"][modes[m]];
                var modeDepartures = [];

                for (var d = 0; d < modeData.size() && modeDepartures.size() < _MAX_DEPARTURES; d++) {
                    var departureData = modeData[d];

                    var mode = departureData["TransportMode"];
                    var group = DictCompat.get(departureData, "GroupOfLine", "");
                    var line = departureData["LineNumber"];
                    var destination = departureData["Destination"];
                    var direction = departureData["DepartureDirection"];
                    var displayTime = departureData["DisplayTime"];

                    modeDepartures.add(new Departure(mode, group, line, destination, direction, displayTime));
                }

                // add null because an ampty array is not matched with the equals() removeAll() performes.
                departures.add(modeDepartures.size() != 0 ? modeDepartures : null);
            }

            // swap metros and buses
            ArrCompat.swap(departures, 0, 1);
            departures.removeAll(null);

            if (departures.size() != 0) {
                _storage.getStop(_stopCursor).setDepartures(departures);
            }
            else {
                Log.d("Departures response empty of departures");
                _storage.setPlaceholderDeparture(_stopCursor, null, rez(Rez.Strings.lbl_i_departures_none_found));
            }

        }
        else {
            var message;

            if (responseCode == _RESPONSE_OK) {
               message = rez(Rez.Strings.lbl_e_null_data);
            }
            else if (responseCode == Communications.BLE_CONNECTION_UNAVAILABLE) {
                // no bluetooth
                message = rez(Rez.Strings.lbl_e_connection);
            }
            else if (responseCode == Communications.NETWORK_REQUEST_TIMED_OUT) {
                // no internet
                message = rez(Rez.Strings.lbl_e_connection);
            }
            else if (responseCode == Communications.NETWORK_RESPONSE_OUT_OF_MEMORY) {
                message = rez(Rez.Strings.lbl_e_memory);
            }
            else if (responseCode == Communications.BLE_QUEUE_FULL) {
                message = rez(Rez.Strings.lbl_e_queue_full);
            }
            else if (responseCode == Communications.NETWORK_RESPONSE_TOO_LARGE) {
                message = rez(Rez.Strings.lbl_e_response_size);
            }
            else if (responseCode == Communications.BLE_REQUEST_CANCELLED || responseCode == Communications.REQUEST_CANCELLED) {
                message = rez(Rez.Strings.lbl_e_cancelled);
            }
            else {
                Log.i("Departures response error (code " + responseCode + "): " + data);
                message = rez(Rez.Strings.lbl_e_general) + " " + responseCode;
            }

            _storage.setPlaceholderDeparture(_stopCursor, responseCode, message);
        }

        WatchUi.requestUpdate();
    }

}
