// This file is part of Avgånär.
//
// Avgånär is free software: you can redistribute it and/or modify it under the terms of
// the GNU General Public License as published by the Free Software Foundation,
// either version 3 of the License, or (at your option) any later version.
//
// Avgånär is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
// without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with Avgånär.
// If not, see <https://www.gnu.org/licenses/>.

using Toybox.Communications;
using Toybox.Lang;
using Toybox.WatchUi;

// Requests and handles stop data.
module NearbyStopsService {

    // API: SL Nearby Stops 2
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
        // final check if location use is turned off
        if (!SettingsStorage.getUseLocation()) {
            NearbyStopsStorage.setResponse([], [], null);
            WatchUi.requestUpdate();
        }
        // check if outside bounds, to not make unnecessary calls outside the operator zone
        else if (lat < _BOUNDS_SOUTH || lat > _BOUNDS_NORTH || lon < _BOUNDS_WEST || lon > _BOUNDS_EAST) {
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

        // transition to new url 2023-12-04--2024-03-15
        var url = "https://journeyplanner.integration.sl.se/v1/nearbystopsv2.json";

        var params = {
            "key" => API_KEY_STOPS,
            "originCoordLat" => lat,
            "originCoordLong" => lon,
            "r" => _MAX_RADIUS,
            "maxNo" => def(NearbyStopsStorage.maxStops, SettingsStorage.getMaxStops()),
            "type" => "S" // stations only
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

            // we need to consider all existing stops, since
            // "id1 name1" should return existing "id1 name1" over "id1 name2"
            var existingIdIndices = ArrUtil.indicesOf(stopIds, id);
            var existingStops = ArrUtil.getAll(stops, existingIdIndices);

            // stop will be null if it is a duplicate in both `id` and `name`
            var stop = NearbyStopsStorage.createStop(id, name, existingStops);
            if (stop == null) {
                continue;
            }

            stopIds.add(id);
            stopNames.add(name);
            stops.add(stop);
        }

        NearbyStopsStorage.setResponse(stopIds, stopNames, stops);
    }

}
