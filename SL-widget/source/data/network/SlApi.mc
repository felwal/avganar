using Toybox.Application;
using Toybox.Communications;
using Toybox.System;
using Toybox.Lang;
using Toybox.WatchUi;

(:glance)
class SlApi {

    private static const _RESPONSE_OK = 200;
    private static const _TIMEWINDOW_MAX = 60;
    private static const _RADIUS_MAX = 2000;

    private var _maxStopsGlance = 1;
    private var _maxDeparturesGlance = 2;
    private var _timewindowGlance = 15;

    private var _maxStopsDetail = 1;
    private var _maxDeparturesDetail = 6;
    private var _stopCursorDetail = 0;
    private var _timewindowDetail = _TIMEWINDOW_MAX;

    var stops = [_maxStopsDetail];

    // nearby stops (Närliggande Hållplatser 2)

    function requestNearbyStopsGlance(lat, lon) {
        requestNearbyStops(lat, lon, _maxStopsGlance, method(:onReceiveNearbyStopsGlance));
    }

    function requestNearbyStopsDetail(lat, lon) {
        requestNearbyStops(lat, lon, _maxStopsDetail, method(:onReceiveNearbyStopsDetail));
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
        if (responseCode == _RESPONSE_OK) {
            handleNearbyStopsResponseOk(data);
            var siteId = stops[_stopCursorDetail].id;
            if (siteId != null) {
                requestDepartures(siteId, _timewindowGlance);
            }
        }
        else {
            System.println("Response error: " + responseCode);
            handleNearbyStopsResponseError(data);
        }

        WatchUi.requestUpdate();
    }

    function onReceiveNearbyStopsDetail(responseCode, data) {
        if (responseCode == _RESPONSE_OK) {
            handleNearbyStopsResponseOk(data);
            var siteId = stops[_stopCursorDetail].id;
            if (siteId != null) {
                requestDepartures(siteId, _timewindowDetail);
            }
        }
        else {
            System.println("Response error: " + responseCode);
            handleNearbyStopsResponseError(data);
        }

        WatchUi.requestUpdate();
    }

    private function handleNearbyStopsResponseOk(data) {
        System.println(data);

        if (!hasKey(data, "stopLocationOrCoordLocation")) {
            var message;
            if (hasKey(data, "Message")) {
                message = data["Message"];
            }
            else {
                message = Application.loadResource(Rez.Strings.stops_none_found);
            }

            // add placeholder stops
            for (var i = 0; i < _maxStopsDetail; i++) {
                stops[i] = new Stop(-2, message);
            }
            WatchUi.requestUpdate();
            return;
        }
        var stopsData = data["stopLocationOrCoordLocation"];

        for (var i = 0; i < _maxStopsDetail && i < stopsData.size(); i++) {
            var stopData = stopsData[i]["StopLocation"];

            var extId = stopData["mainMastExtId"];
            var id = extId.substring(5, extId.length());
            var name = stopData["name"];

            stops[i] = new Stop(id, name);
        }
    }

    private function handleNearbyStopsResponseError(data) {
        var message;
        if (hasKey(data, "Message")) {
            message = data["Message"];
        }
        else {
            message = Application.loadResource(Rez.Strings.stops_connection_error);
        }

        // add placeholder stops
        for (var i = 0; i < _maxStopsDetail; i++) {
            stops[i] = new Stop(-2, message);
        }
    }

    // departures (Realtidsinformation 4)

    private function requestDepartures(siteId, timewindow) {
        var url = "https://api.sl.se/api2/realtimedeparturesv4.json?";

        var params = {
            "key" => KEY_RI,
            "siteid" => siteId,
            "timewindow" => timewindow
        };

        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
            :headers => {
                "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON
            }
        };

        Communications.makeWebRequest(url, params, options, method(:onReceiveDepartures));
    }

    function onReceiveDepartures(responseCode, data) {
        if (responseCode == _RESPONSE_OK && hasKey(data, "ResponseData")) {
            System.println(data);

            var modes = ["Metros", "Buses", "Trains", "Trams", "Ships"];
            var journeys = [];

            for (var m = 0; m < modes.size() && journeys.size() < _maxDeparturesDetail; m++) {
                var modeData = data["ResponseData"][modes[m]];

                for (var j = 0; j < modeData.size() && journeys.size() < _maxDeparturesDetail; j++) {
                    var journeyData = modeData[j];

                    var mode = journeyData["TransportMode"];
                    var line = journeyData["LineNumber"];
                    var destination = journeyData["Destination"];
                    var direction = journeyData["JourneyDirection"];
                    var displayTime = journeyData["DisplayTime"];

                    journeys.add(new Journey(mode, line, destination, direction, displayTime));
                }
            }

            stops[_stopCursorDetail].journeys = journeys;
            WatchUi.requestUpdate();
        }
        else {
            System.println("Response error: " + responseCode);
        }
    }

    // tool

    function hasKey(dict, key) {
        return dict != null && dict.hasKey(key) && dict[key] != null;
    }

}
