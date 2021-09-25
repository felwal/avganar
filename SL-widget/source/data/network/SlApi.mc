using Toybox.Application;
using Toybox.Communications;
using Toybox.System;
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
    private static const _MAX_STOPS_DETAIL = 1;
    private static const _MAX_DEPARTURES_DETAIL = 6;
    private static const _TIMEWINDOW_DETAIL = _TIMEWINDOW_MAX;

    private var _storage;
    private var _stopCursorDetail = 0;

    //

    function initialize(storage) {
        _storage = storage;
    }

    // nearby stops (Närliggande Hållplatser 2)
    // bronze: 10_000/month, 30/min
    // TODO: only call these when the distance diff is > x m

    function requestNearbyStopsGlance(lat, lon) {
        System.println("Requesting glance stops for coords (" + lat + ", " + lon + ") ...");
        requestNearbyStops(lat, lon, _MAX_STOPS_GLANCE, method(:onReceiveNearbyStopsGlance));
    }

    function requestNearbyStopsDetail(lat, lon) {
        System.println("Requesting detail stops for coords (" + lat + ", " + lon + ") ...");
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
            :headers => {
                "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON
            }
        };

        Communications.makeWebRequest(url, params, options, responseCallback);
    }

    function onReceiveNearbyStopsGlance(responseCode, data) {
        if (responseCode == _RESPONSE_OK && data != null) {
            var requestDepartures = handleNearbyStopsResponseOk(data);

            // request departures
            if (requestDepartures) {
                requestDeparturesGlance(_storage.getStopId(_stopCursorDetail));
            }
        }
        else {
            handleNearbyStopsResponseError(responseCode, data);
        }

        WatchUi.requestUpdate();
    }

    function onReceiveNearbyStopsDetail(responseCode, data) {
        if (responseCode == _RESPONSE_OK && data != null) {
            var requestDepartures = handleNearbyStopsResponseOk(data);

            // request departures
            if (requestDepartures) {
                requestDeparturesDetail(_storage.getStopId(_stopCursorDetail));
            }
        }
        else {
            handleNearbyStopsResponseError(responseCode, data);
        }

        WatchUi.requestUpdate();
    }

    private function handleNearbyStopsResponseOk(data) {
        System.println("Stops response success: " + data);

        // no stops were found
        if (!hasKey(data, "stopLocationOrCoordLocation")) {
            var message;
            if (hasKey(data, "Message")) {
                message = data["Message"];
            }
            else {
                message = Application.loadResource(Rez.Strings.stops_none_found);
            }
            _storage.setPlaceholderStop(message);

            return false;
        }

        // stops were found

        var stopIds = [];
        var stopNames = [];
        var stops = [];

        var stopsData = data["stopLocationOrCoordLocation"];
        for (var i = 0; i < _MAX_STOPS_DETAIL && i < stopsData.size(); i++) {
            var stopData = stopsData[i]["StopLocation"];

            var extId = stopData["mainMastExtId"];
            var id = extId.substring(5, extId.length()).toNumber();
            var name = stopData["name"];

            stopIds.add(id);
            stopNames.add(name);
            stops.add(new Stop(id, name));
        }

        // request departures

        var oldSelectedStopId = _storage.getStopId(_stopCursorDetail);
        var newSelectedStopId = stopIds[_stopCursorDetail];
        System.println("Old siteId: " + oldSelectedStopId + "; new siteId: " + newSelectedStopId);

        // only request departures if the selected stop has changed
        if (oldSelectedStopId != newSelectedStopId) {
            _storage.setStops(stopIds, stopNames, stops);
            return true;
        }
        return false;
    }

    private function handleNearbyStopsResponseError(responseCode, data) {
        System.println("Stops response error (" + responseCode + "): " + data);

        var message;
        if (hasKey(data, "Message")) {
            message = data["Message"];
        }
        else {
            message = Application.loadResource(Rez.Strings.stops_connection_error);
        }
        _storage.setPlaceholderStop(message);
    }

    // departures (Realtidsinformation 4)
    // bronze: 10_000/month, 30/min

    function requestDeparturesGlance(siteId) {
        if (siteId != null && siteId != Stop.NO_ID) {
            System.println("Requesting glance departures for siteId " + siteId + " ...");
            requestDepartures(siteId, _TIMEWINDOW_GLANCE);
        }
    }

    function requestDeparturesDetail(siteId) {
        if (siteId != null && siteId != Stop.NO_ID) {
            System.println("Requesting detail departures for siteId " + siteId + " ...");
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
            //:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
            :headers => {
                "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON
            }
        };

        Communications.makeWebRequest(url, params, options, method(:onReceiveDepartures));
    }

    function onReceiveDepartures(responseCode, data) {
        if (responseCode == _RESPONSE_OK && hasKey(data, "ResponseData")) {
            System.println("Departures response success: " + data);

            var modes = ["Metros", "Buses", "Trains", "Trams", "Ships"];
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

            _storage.setJourneys(_stopCursorDetail, journeys);
            WatchUi.requestUpdate();
        }
        else {
            System.println("Departures response error (code " + responseCode + "): " + data);
        }
    }

    // tool

    function hasKey(dict, key) {
        return dict != null && dict.hasKey(key) && dict[key] != null;
    }

}
