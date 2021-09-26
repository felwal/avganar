using Toybox.Application;
using Toybox.Communications;
using Toybox.Lang;
using Toybox.WatchUi;

(:glance)
class SlApi {

    // api consts
    private static const _RESPONSE_OK = 200;
    private static const _TIMEWINDOW_MAX = 60;
    private static const _RADIUS_MAX = 2000;

    // glance consts
    private static const _MAX_STOPS_GLANCE = 1;
    private static const _MAX_DEPARTURES_GLANCE = 2;
    private static const _TIMEWINDOW_GLANCE = 15;

    // detail consts
    private static const _MAX_STOPS_DETAIL = 12;
    private static const _MAX_DEPARTURES_DETAIL = 6;
    private static const _TIMEWINDOW_DETAIL = _TIMEWINDOW_MAX;

    var STOP_CURSOR_GLANCE = 0;
    var stopCursorDetail = 0;

    private var _storage;

    //

    function initialize(storage) {
        _storage = storage;
    }

    // nearby stops (Närliggande Hållplatser 2)
    // bronze: 10_000/month, 30/min
    // TODO: only call these when the distance diff is > x m

    function requestNearbyStopsGlance(lat, lon) {
        Log.i("Requesting glance stops for coords (" + lat + ", " + lon + ") ...");
        requestNearbyStops(lat, lon, _MAX_STOPS_GLANCE, method(:onReceiveNearbyStopsGlance));
    }

    function requestNearbyStopsDetail(lat, lon) {
        Log.i("Requesting detail stops for coords (" + lat + ", " + lon + ") ...");
        requestNearbyStops(lat, lon, _MAX_STOPS_DETAIL, method(:onReceiveNearbyStopsDetail));
    }

    private function requestNearbyStops(lat, lon, maxNo, responseCallback) {
        var url = "https://api.sl.se/api2/nearbystopsv2";

        var params = {
            "key" => KEY_NH,
            "originCoordLat" => lat,
            "originCoordLong" => lon,
            "r" => _RADIUS_MAX,
            "maxNo" => maxNo
        };

        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
            :headers => { "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON }
        };

        Communications.makeWebRequest(url, params, options, responseCallback);
    }

    function onReceiveNearbyStopsGlance(responseCode, data) {
        if (responseCode == _RESPONSE_OK && data != null) {
            var requestDepartures = handleNearbyStopsResponseOk(data, _MAX_STOPS_GLANCE, STOP_CURSOR_GLANCE);

            // request departures
            if (requestDepartures) {
                requestDeparturesGlance();
            }
        }
        else {
            handleNearbyStopsResponseError(responseCode, data);
        }

        WatchUi.requestUpdate();
    }

    function onReceiveNearbyStopsDetail(responseCode, data) {
        if (responseCode == _RESPONSE_OK && data != null) {
            var requestDepartures = handleNearbyStopsResponseOk(data, _MAX_STOPS_DETAIL, stopCursorDetail);

            // request departures
            if (requestDepartures) {
                requestDeparturesDetail();
            }
        }
        else {
            handleNearbyStopsResponseError(responseCode, data);
        }

        WatchUi.requestUpdate();
    }

    //! @return If the selected stop has changed and ddepartures should be requested
    private function handleNearbyStopsResponseOk(data, maxStops, stopCursor) {
        Log.d("Stops response success: " + data);

        // no stops were found
        if (!hasKey(data, "stopLocationOrCoordLocation")) {
            var message;

            if (hasKey(data, "Message")) {
                message = data["Message"];
            }
            else {
                message = Application.loadResource(Rez.Strings.lbl_i_stops_none_found);
            }

            _storage.setPlaceholderStop(message);
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

        var oldSelectedStop = _storage.getStop(stopCursor);
        var newSelectedStopId = stopIds[stopCursor];

        Log.d("Old siteId: " + oldSelectedStop.id + "; new siteId: " + newSelectedStopId);

        if (oldSelectedStop.id == newSelectedStopId) {
            // copy journeys as they have not changed
            // we still need to change stops, as any unselected stop may have changed
            stops[stopCursor].journeys = oldSelectedStop.journeys;
            _storage.setStops(stopIds, stopNames, stops);
            return false;
        }
        _storage.setStops(stopIds, stopNames, stops);
        return true;
    }

    private function handleNearbyStopsResponseError(responseCode, data) {
        Log.e("Stops response error (code " + responseCode + "): " + data);

        var message;

        if (hasKey(data, "Message")) {
            message = data["Message"];
        }
        else if (responseCode == Communications.BLE_CONNECTION_UNAVAILABLE) {
            message = Application.loadResource(Rez.Strings.lbl_e_stops_connection);
        }
        else if (responseCode == Communications.NETWORK_RESPONSE_OUT_OF_MEMORY) {
            message = Application.loadResource(Rez.Strings.lbl_e_stops_memory);
        }
        else {
            message = Application.loadResource(Rez.Strings.lbl_e_stops_code) + " " + responseCode;
        }

        _storage.setPlaceholderStop(message);
    }

    // departures (Realtidsinformation 4)
    // bronze: 10_000/month, 30/min

    function requestDeparturesGlance() {
        var siteId = _storage.getStopId(STOP_CURSOR_GLANCE);

        if (siteId != null && siteId != Stop.NO_ID) {
            Log.i("Requesting glance departures for siteId " + siteId + " ...");
            requestDepartures(siteId, _TIMEWINDOW_GLANCE);
        }
    }

    function requestDeparturesDetail() {
        var siteId = _storage.getStopId(stopCursorDetail);

        if (siteId != null && siteId != Stop.NO_ID) {
            Log.i("Requesting detail departures for siteId " + siteId + " ...");
            requestDepartures(siteId, _TIMEWINDOW_DETAIL);
        }
    }

    private function requestDepartures(siteId, timewindow) {
        var url = "https://api.sl.se/api2/realtimedeparturesv4.json";

        var params = {
            "key" => KEY_RI,
            "siteid" => siteId.toNumber(),
            "timewindow" => timewindow
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
        if (responseCode == _RESPONSE_OK && hasKey(data, "ResponseData")) {
            Log.d("Departures response success: " + data);

            var modes = [ "Metros", "Buses", "Trains", "Trams", "Ships" ];
            var journeys = [];

            for (var m = 0; m < modes.size() && journeys.size() < _MAX_DEPARTURES_DETAIL; m++) {
                var modeData = data["ResponseData"][modes[m]];

                for (var j = 0; j < modeData.size() && journeys.size() < _MAX_DEPARTURES_DETAIL; j++) {
                    var journeyData = modeData[j];

                    var mode = journeyData["TransportMode"];
                    var line = journeyData["LineNumber"];
                    var destination = journeyData["Destination"];
                    var direction = journeyData["JourneyDirection"];
                    var displayTime = journeyData["DisplayTime"];

                    journeys.add(new Journey(mode, line, destination, direction, displayTime));
                }
            }

            _storage.setJourneys(stopCursorDetail, journeys);
            WatchUi.requestUpdate();
        }
        else {
            Log.e("Departures response error (code " + responseCode + "): " + data);
        }
    }

    // tool

    function hasKey(dict, key) {
        return dict != null && dict.hasKey(key) && dict[key] != null;
    }

}
