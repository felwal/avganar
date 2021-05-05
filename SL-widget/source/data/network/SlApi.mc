using Toybox.Communications;
using Toybox.System;
using Toybox.Lang;
using Toybox.WatchUi;
using Carbon.Footprint as Footprint;

(:glance)
class SlApi {

    public static var stopCount = 1;
    public static var stops = [stopCount];
    public static var shownStopNr = 0;

    private static var _requestPos = [Footprint.latDeg(), Footprint.lonDeg()];
    
    private static const RESPONSE_OK = 200;

    // requests

    //! Närliggande Hållplatser 2
    function requestNearbyStops(lat, lon) {
        var url = "https://api.sl.se/api2/nearbystopsv2";

        var params = {
            "key" => KEY_NH,
            "originCoordLat" => lat,
            "originCoordLong" => lon,
            "r" => 2000,
            "maxNo" => stopCount
        };

        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
            :headers => {
                   "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON
            }
        };

        Communications.makeWebRequest(url, params, options, method(:onReceiveNearbyStops));
    }

    //! Realtidsinformation 4
    function requestDepartures(siteId) {
        var url = "https://api.sl.se/api2/realtimedeparturesv4.json?";
        url += "key=" + KEY_RI + "&siteid=" + siteId + "&timewindow=" + 60;

        /*var params = {
            "key" => KEY_RI,
            "siteid" => siteId,
            "timewindow" => 30
        };

        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
            :headers => {
                   "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON
            }
        };*/

        Communications.makeWebRequest(url, {}, {}, method(:onReceiveDepartures));
    }

    // listeners

    //! Närliggande Hållplatser 2 callback listener
    (:glance)
    function onReceiveNearbyStops(responseCode, data) {
        if (responseCode == RESPONSE_OK) {
            System.println(data);

            if (!data.hasKey("stopLocationOrCoordLocation")) {
                var message = "No stops found";
                if (data.hasKey("Message")) {
                     message = data["Message"];
                }

                // add placeholder stops
                for (var i = 0; i < SlApi.stopCount; i++) {
                    stops[i] = new Stop(-2, message);
                }
                WatchUi.requestUpdate();
                return;
            }
            var stopsData = data["stopLocationOrCoordLocation"];

            for (var i = 0; i < SlApi.stopCount && i < stopsData.size(); i++) {
                var stopData = stopsData[i]["StopLocation"];

                var extId = stopData["mainMastExtId"];
                var id = extId.substring(5, extId.length());
                var name = stopData["name"];

                stops[i] = new Stop(id, name);
            }

            requestDepartures(stops[shownStopNr].id);
        }
        else {
            System.println("Response error: " + responseCode);
            var message = data["Message"];

            // add placeholder stops
            for (var i = 0; i < SlApi.stopCount; i++) {
                stops[i] = new Stop(-2, message);
            }
        }

        WatchUi.requestUpdate();
    }

    //! Realtidsinformation 4 callback listener
    (:glance)
    function onReceiveDepartures(responseCode, data) {
        if (responseCode == RESPONSE_OK) {
            System.println(data);

            var modes = ["Metros", "Buses", "Trains", "Trams", "Ships"];
            var journeys = [];

            for (var m = 0; m < modes.size(); m++) {
                var modeData = data["ResponseData"][modes[m]];

                for (var j = 0; j < modeData.size(); j++) {
                    var journeyData = modeData[j];

                    var mode = journeyData["TransportMode"];
                    var line = journeyData["LineNumber"];
                    var destination = journeyData["Destination"];
                    var direction = journeyData["JourneyDirection"];
                    var displayTime = journeyData["DisplayTime"];

                    journeys.add(new Journey(mode, line, destination, direction, displayTime));
                }
            }

            stops[shownStopNr].journeys = journeys;
            WatchUi.requestUpdate();
        }
        else {
            System.println("Response error: " + responseCode);
        }
    }

}
