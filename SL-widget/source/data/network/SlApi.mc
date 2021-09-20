using Toybox.Application;
using Toybox.Communications;
using Toybox.System;
using Toybox.Lang;
using Toybox.WatchUi;

(:glance)
class SlApi {

    private static const RESPONSE_OK = 200;
    private static const TIMEWINDOW_MAX = 60;
    private static const RADIUS_MAX = 2000;

    private var _maxStopsGlance = 1;
    private var _maxStopsView = 1;
    private var _maxDeparturesGlance = 2;
    private var _maxDeparturesView = 6;
    private var _stopCursorView = 0;

    private var _timewindowGlance = 15;
    private var _timewindowView = TIMEWINDOW_MAX;

    var stops = [_maxStopsView];

    // nearby stops (Närliggande Hållplatser 2)

    function requestNearbyStopsGlance(lat, lon) {
        requestNearbyStops(lat, lon, _maxStopsGlance, method(:onReceiveNearbyStopsGlance));
    }

    function requestNearbyStopsView(lat, lon) {
        requestNearbyStops(lat, lon, _maxStopsView, method(:onReceiveNearbyStopsView));
    }

    private function requestNearbyStops(lat, lon, maxNo, responseCallback) {
        var url = "https://api.sl.se/api2/nearbystopsv2";

        var params = {
            "key" => KEY_NH,
            "originCoordLat" => lat,
            "originCoordLong" => lon,
            "r" => RADIUS_MAX,
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
        if (responseCode == RESPONSE_OK) {
            handleNearbyStopsResponseOk(data);
            var siteId = stops[_stopCursorView].id;
            if (siteId != null) {
                requestDepartures(siteId, _timewindowGlance);
            }
        }
        else {
            handleNearbyStopsResponseError(data);
        }

        WatchUi.requestUpdate();
    }

    function onReceiveNearbyStopsView(responseCode, data) {
        if (responseCode == RESPONSE_OK) {
            handleNearbyStopsResponseOk(data);
            var siteId = stops[_stopCursorView].id;
            if (siteId != null) {
                requestDepartures(siteId, _timewindowView);
            }
        }
        else {
            handleNearbyStopsResponseError(data);
        }

        WatchUi.requestUpdate();
    }

    private function handleNearbyStopsResponseOk(data) {
        System.println(data);

        if (!data.hasKey("stopLocationOrCoordLocation")) {
            var message = Application.loadResource(Rez.Strings.stops_none_found);
            if (data.hasKey("Message")) {
                 message = data["Message"];
            }

            // add placeholder stops
            for (var i = 0; i < _maxStopsView; i++) {
                stops[i] = new Stop(-2, message);
            }
            WatchUi.requestUpdate();
            return;
        }
        var stopsData = data["stopLocationOrCoordLocation"];

        for (var i = 0; i < _maxStopsView && i < stopsData.size(); i++) {
            var stopData = stopsData[i]["StopLocation"];

            var extId = stopData["mainMastExtId"];
            var id = extId.substring(5, extId.length());
            var name = stopData["name"];

            stops[i] = new Stop(id, name);
        }
    }

    private function handleNearbyStopsResponseError(data) {
        System.println("Response error: " + responseCode);
        var message = data["Message"];

        // add placeholder stops
        for (var i = 0; i < _maxStopsView; i++) {
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
        if (responseCode == RESPONSE_OK && data["ResponseData"] != null) {
            System.println(data);

            var modes = ["Metros", "Buses", "Trains", "Trams", "Ships"];
            var journeys = [];

            for (var m = 0; m < modes.size() && journeys.size() < _maxDeparturesView; m++) {
                var modeData = data["ResponseData"][modes[m]];

                for (var j = 0; j < modeData.size() && journeys.size() < _maxDeparturesView; j++) {
                    var journeyData = modeData[j];

                    var mode = journeyData["TransportMode"];
                    var line = journeyData["LineNumber"];
                    var destination = journeyData["Destination"];
                    var direction = journeyData["JourneyDirection"];
                    var displayTime = journeyData["DisplayTime"];

                    journeys.add(new Journey(mode, line, destination, direction, displayTime));
                }
            }

            stops[_stopCursorView].journeys = journeys;
            WatchUi.requestUpdate();
        }
        else {
            System.println("Response error: " + responseCode);
        }
    }

}
