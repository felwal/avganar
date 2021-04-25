using Toybox.Communications;
using Toybox.System;

(:glance)
class SlApi {

    public static var stopCount = 3;
    public static var stops = new [stopCount];
    
    // requests

    //! Närliggande Hållplatser 2
    function requestNearbyStops(lat, lon) {
        var url = "https://api.sl.se/api2/nearbystopsv2";

        var params = {
            "key" => KEY_NH,
            "originCoordLat" => lat,
            "originCoordLong" => lon,
            "r" => 2000,
            "maxNo" => SlApi.stopCount
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

}

// listeners

//! Request callback listener
(:glance)
function onReceiveNearbyStops(responseCode, data) {
    if (responseCode == 200) {
        System.println(data);
        if (!data.hasKey("stopLocationOrCoordLocation")) {
            return;
        }
        var stops = data["stopLocationOrCoordLocation"];

        for (var i = 0; i < SlApi.stopCount && i < stops.size(); i++) {
            var stop = stops[i]["StopLocation"];
            var extId = stop["mainMastExtId"];
            var id = extId.substring(5, extId.length() - 1);
            var name = stop["name"];

            SlApi.stops[i] = new Stop(id, name);
        }
    }
    else {
        System.println("Response error: " + responseCode);
    }
}
