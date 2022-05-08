using Toybox.Communications;
using Toybox.Lang;
using Toybox.WatchUi;
using Carbon.Footprint;

class SlStopService {

    // edges of the SL zone, with an extra 2 km offset
    private static const _BOUNDS_SOUTH = 58.783223; // Ankarudden (Nynäshamn)
    private static const _BOUNDS_NORTH = 60.225171; // Ellans Vändplan (Norrtälje)
    private static const _BOUNDS_WEST = 17.239541; // Dammen (Nykvarn)
    private static const _BOUNDS_EAST = 19.116554; // Räfsnäs Brygga (Norrtälje)

    private static const _RESPONSE_OK = 200;

    // nearby stops max stops (max = 1000)
    private static const _MAX_STOPS = 25;
    // nearby stops radius (max = 2000)
    private static const _maxRadius = 2000;

    private var _storage;

    // init

    function initialize(storage) {
        _storage = storage;
    }

    // nearby stops (Närliggande Hållplatser 2)
    // bronze: 10_000/month, 30/min

    function requestNearbyStops(lat, lon) {
        // check if outside bounds, to not make unnecessary calls outside the SL zone
        if (lat < _BOUNDS_SOUTH || lat > _BOUNDS_NORTH || lon < _BOUNDS_WEST || lon > _BOUNDS_EAST) {
            Log.i("Location outside bounds; skipping request");

            var msg = lat == 0.0 && lon == 0.0
                ? rez(Rez.Strings.lbl_i_stops_no_gps)
                : rez(Rez.Strings.lbl_i_stops_outside_bounds);

            _storage.setPlaceholderStop(Stop.ERROR_CODE_OUTSIDE_BOUNDS, msg);
            //_storage.getStop(0).setDeparturesPlaceholder(null, "At " + Footprint.format(lat, lon));

            return;
        }

        Log.i("Requesting stops for coords (" + lat + ", " + lon + ") ...");
        _requestNearbyStops(lat, lon);
    }

    private function _requestNearbyStops(lat, lon) {
        var url = "https://api.sl.se/api2/nearbystopsv2";

        var params = {
            "key" => KEY_NH,
            "originCoordLat" => lat,
            "originCoordLong" => lon,
            "r" => _maxRadius,
            "maxNo" => _MAX_STOPS
        };

        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
            :headers => { "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON }
        };

        Communications.makeWebRequest(url, params, options, method(:onReceiveNearbyStops));
    }

    function onReceiveNearbyStops(responseCode, data) {
        if (responseCode == _RESPONSE_OK && data != null) {
            _handleNearbyStopsResponseOk(data);
        }
        else {
            _handleNearbyStopsResponseError(responseCode, data);
        }

        WatchUi.requestUpdate();
    }

    //! @return If the selected stop has changed and departures should be requested
    private function _handleNearbyStopsResponseOk(data) {
        Log.d("Stops response success: " + data);

        // no stops were found
        if (!DictCompat.hasKey(data, "stopLocationOrCoordLocation") || data["stopLocationOrCoordLocation"] == null) {
            var message;

            if (DictCompat.hasKey(data, "Message")) {
                message = data["Message"];
            }
            else {
                message = rez(Rez.Strings.lbl_i_stops_none_found);
            }

            _storage.setPlaceholderStop(Stop.ERROR_CODE_NO_STOPS, message);
        }

        // stops were found

        var stopIds = [];
        var stopNames = [];
        var stops = [];

        var stopsData = data["stopLocationOrCoordLocation"];
        for (var i = 0; i < stopsData.size() && i < _MAX_STOPS; i++) {
            var stopData = stopsData[i]["StopLocation"];

            var extId = stopData["mainMastExtId"];
            var id = extId.substring(5, extId.length()).toNumber();
            var name = stopData["name"];

            stopIds.add(id);
            stopNames.add(name);
            stops.add(new Stop(id, name));
        }

        _storage.setStops(stopIds, stopNames, stops);
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

}
