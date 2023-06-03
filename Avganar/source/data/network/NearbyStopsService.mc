using Toybox.Communications;
using Toybox.Lang;
using Toybox.WatchUi;

module NearbyStopsService {

    // Närliggande hållplatser 2
    // Bronze: 10_000/month, 30/min

    // edges of the operator zone, with an extra 2 km offset
    const _BOUNDS_SOUTH = 58.783223; // Ankarudden (Nynäshamn)
    const _BOUNDS_NORTH = 60.225171; // Ellans Vändplan (Norrtälje)
    const _BOUNDS_WEST = 17.239541; // Dammen (Nykvarn)
    const _BOUNDS_EAST = 19.116554; // Räfsnäs Brygga (Norrtälje)

    const _MAX_RADIUS = 2000; // default 1000, max 2000 (meters)

    var isRequesting = false;

    // request

    function requestNearbyStops(lat, lon) {
        // check if outside bounds, to not make unnecessary calls outside the operator zone
        if (lat < _BOUNDS_SOUTH || lat > _BOUNDS_NORTH || lon < _BOUNDS_WEST || lon > _BOUNDS_EAST) {
            Log.i("Location (" + lat +", " + lon + ") outside bounds; skipping request");

            if (lat != 0.0 || lon != 0.0) {
                NearbyStopsStorage.setResponse([], [], rez(Rez.Strings.msg_i_stops_outside_bounds));
            }

            WatchUi.requestUpdate();
        }
        else {
            Log.i("Requesting " + NearbyStopsStorage.maxStops + " stops for coords (" + lat + ", " + lon + ") ...");
            _requestNearbyStops(lat, lon);
        }
    }

    function _requestNearbyStops(lat, lon) {
        isRequesting = true;

        var url = "https://api.sl.se/api2/nearbystopsv2";

        var params = {
            "key" => API_KEY_STOPS,
            "originCoordLat" => lat,
            "originCoordLong" => lon,
            "r" => _MAX_RADIUS,
            "maxNo" => NearbyStopsStorage.maxStops == null ? SettingsStorage.getMaxStops() : NearbyStopsStorage.maxStops
        };
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
            :headers => { "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON }
        };

        Communications.makeWebRequest(url, params, options, new Lang.Method(NearbyStopsService, :onReceiveNearbyStops));
    }

    // receive

    function onReceiveNearbyStops(responseCode, data) {
        isRequesting = false;

        if (responseCode == ResponseError.HTTP_OK && data != null) {
            _handleNearbyStopsResponseOk(data);
        }
        else {
            Log.e("Stops response error (code " + responseCode + "): " + data);

            NearbyStopsStorage.setResponse([], [], new ResponseError(DictUtil.get(data, "Message", responseCode)));

            // auto rerequest if too large
            if (NearbyStopsStorage.shouldAutoRerequest()) {
                requestNearbyStops(Footprint.getLatDeg(), Footprint.getLonDeg());
            }
        }

        WatchUi.requestUpdate();
    }

    function _handleNearbyStopsResponseOk(data) {
        // operator error
        if (DictUtil.hasValue(data, "StatusCode") || DictUtil.hasValue(data, "Message")) {
            var statusCode = data["StatusCode"];
            NearbyStopsStorage.setResponse([], [], new ResponseError(statusCode));

            Log.e("Stops operator response error (code " + statusCode + ")");

            return;
        }

        // no stops were found
        if (!DictUtil.hasValue(data, "stopLocationOrCoordLocation") || data["stopLocationOrCoordLocation"] == null) {
            if (DictUtil.hasValue(data, "Message")) {
                NearbyStopsStorage.setResponse([], [], new ResponseError(data["Message"]));
            }
            else {
                NearbyStopsStorage.setResponse([], [], rez(Rez.Strings.msg_i_stops_none));
            }

            return;
        }

        // stops were found

        //Log.d("Stops response success: " + data);

        var stopIds = [];
        var stopNames = [];
        var stops = [];

        var stopsData = data["stopLocationOrCoordLocation"];
        for (var i = 0; i < stopsData.size(); i++) {
            var stopData = stopsData[i]["StopLocation"];

            var extId = stopData["mainMastExtId"];
            var id = extId.substring(5, extId.length()).toNumber();
            var name = stopData["name"];

            var existingIdIndex = stopIds.indexOf(id);
            var existingStop = existingIdIndex == -1
                ? NearbyStopsStorage.getStopByIdAndName(id, name)
                : stops[existingIdIndex];

            stopIds.add(id);
            stopNames.add(name);
            stops.add(NearbyStopsStorage.createStop(id, name, existingStop));
        }

        NearbyStopsStorage.setResponse(stopIds, stopNames, stops);
    }

}
