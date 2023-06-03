using Toybox.Communications;
using Toybox.Lang;
using Toybox.WatchUi;

module NearbyStopsService {

    // Resrobot v2.1 Nearby stops
    // Bronze: 30_000/month, 45/min

    // edges of the operator zone
    const _BOUNDS_SOUTH = 55.33; // Smygehuk (Trelleborg)
    const _BOUNDS_NORTH = 69.06; // Treriksröset (Kiruna)
    const _BOUNDS_WEST = 10.95; // Stora Drammen (Strömstad)
    const _BOUNDS_EAST = 24.16; // Kataja (Haparanda)

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
            Log.i("Requesting stops for coords (" + lat + ", " + lon + ") ...");
            _requestNearbyStops(lat, lon);
        }
    }

    function _requestNearbyStops(lat, lon) {
        isRequesting = true;

        var url = "https://api.resrobot.se/v2.1/location.nearbystops";

        var params = {
            "accessId" => API_KEY,
            "originCoordLat" => lat,
            "originCoordLong" => lon,
            "r" => _MAX_RADIUS,
            "maxNo" => SettingsStorage.getMaxStops(),
            "lang" => rez(Rez.Strings.lang_code),
            "format" => "json"

        };
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :headers => { "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON }
        };

        Communications.makeWebRequest(url, params, options, new Lang.Method(NearbyStopsService, :onReceiveNearbyStops));
    }

    // receive

    function onReceiveNearbyStops(responseCode, data) {
        if (responseCode == ResponseError.HTTP_OK && data != null) {
            _handleNearbyStopsResponseOk(data);
        }
        else {
            var errorCode = DictUtil.get(data, "errorCode", null);
            NearbyStopsStorage.setResponse([], [], new ResponseError(responseCode, errorCode));

            Log.e("Stops response error (responseCode " + responseCode + ", errorCode + " + errorCode + "): " + data);

            // auto rerequest if too large
            if (NearbyStopsStorage.shouldAutoRerequest()) {
                _requestNearbyStops(Footprint.getLatDeg(), Footprint.getLonDeg());
            }
        }

        isRequesting = false;
        WatchUi.requestUpdate();
    }

    function _handleNearbyStopsResponseOk(data) {
        // no stops were found
        if (!DictUtil.hasValue(data, "stopLocationOrCoordLocation")) {
            NearbyStopsStorage.setResponse([], [], rez(Rez.Strings.msg_i_stops_none));
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

            var id = stopData["extId"].toNumber();
            var name = stopData["name"];

            // remove e.g. "(Stockholm kn)"
            var nameEndIndex = name.find("(");
            if (nameEndIndex != null) {
                name = name.substring(0, nameEndIndex);
            }

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
