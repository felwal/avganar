using Toybox.Communications;
using Toybox.Lang;
using Toybox.WatchUi;

module NearbyStopsService {

    // Närliggande Hållplatser 2
    // Bronze: 10_000/month, 30/min

    // edges of the SL zone, with an extra 2 km offset
    const _BOUNDS_SOUTH = 58.783223; // Ankarudden (Nynäshamn)
    const _BOUNDS_NORTH = 60.225171; // Ellans Vändplan (Norrtälje)
    const _BOUNDS_WEST = 17.239541; // Dammen (Nykvarn)
    const _BOUNDS_EAST = 19.116554; // Räfsnäs Brygga (Norrtälje)

    const _RESPONSE_OK = 200;

    const _MAX_RADIUS = 2000; // default 1000, max 2000 (meters)

    // request

    function requestNearbyStops(lat, lon) {
        // check if outside bounds, to not make unnecessary calls outside the SL zone
        if (lat < _BOUNDS_SOUTH || lat > _BOUNDS_NORTH || lon < _BOUNDS_WEST || lon > _BOUNDS_EAST) {
            Log.i("Location (" + lat +", " + lon + ") outside bounds; skipping request");

            if (lat != 0.0 || lon != 0.0) {
                NearbyStopsStorage.setResponse([], [], rez(Rez.Strings.lbl_i_stops_outside_bounds));
            }

            WatchUi.requestUpdate();
        }
        else {
            Log.i("Requesting stops for coords (" + lat + ", " + lon + ") ...");
            _requestNearbyStops(lat, lon);
        }
    }

    function _requestNearbyStops(lat, lon) {
        var url = "https://api.sl.se/api2/nearbystopsv2";

        var params = {
            "key" => API_KEY_STOPS,
            "originCoordLat" => lat,
            "originCoordLong" => lon,
            "r" => _MAX_RADIUS,
            "maxNo" => SettingsStorage.getMaxStops()
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
        if (responseCode == _RESPONSE_OK && data != null) {
            _handleNearbyStopsResponseOk(data);
        }
        else {
            Log.i("Stops response error (code " + responseCode + "): " + data);

            if (DictUtil.hasKey(data, "Message")) {
                NearbyStopsStorage.setResponse([], [], new ResponseError(data["Message"]));
            }
            else {
                NearbyStopsStorage.setResponse([], [], new ResponseError(responseCode));
            }
        }

        WatchUi.requestUpdate();
    }

    //! @return If the selected stop has changed and departures should be requested
    function _handleNearbyStopsResponseOk(data) {
        // SL error
        if (DictUtil.hasKey(data, "StatusCode") || DictUtil.hasKey(data, "Message")) {
            var statusCode = data["StatusCode"];

            Log.i("Stops SL request error (code " + statusCode + ")");

            NearbyStopsStorage.setResponse([], [], new ResponseError(statusCode));

            return;
        }

        Log.d("Stops response success: " + data);

        // no stops were found
        if (!DictUtil.hasKey(data, "stopLocationOrCoordLocation") || data["stopLocationOrCoordLocation"] == null) {
            if (DictUtil.hasKey(data, "Message")) {
                NearbyStopsStorage.setResponse([], [], new ResponseError(data["Message"]));
            }
            else {
                NearbyStopsStorage.setResponse([], [], rez(Rez.Strings.lbl_i_stops_none));
            }

            return;
        }

        // stops were found

        var stopIds = [];
        var stopNames = [];
        var stops = [];

        var stopsData = data["stopLocationOrCoordLocation"];
        for (var i = 0; i < stopsData.size(); i++) {
            var stopData = stopsData[i]["StopLocation"];

            var extId = stopData["mainMastExtId"];
            var id = extId.substring(5, extId.length()).toNumber();

            // skip duplicate stops (same id but different names)
            if (ArrUtil.in(stopIds, id)) {
                continue;
            }

            var name = stopData["name"];

            stopIds.add(id);
            stopNames.add(name);
            stops.add(FavoriteStopsStorage.createStop(id, name, NearbyStopsStorage.getStopById(id)));
        }

        NearbyStopsStorage.setResponse(stopIds, stopNames, stops);
    }

}
