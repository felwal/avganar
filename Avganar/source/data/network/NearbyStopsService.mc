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

import Toybox.Lang;

using Toybox.Communications;
using Toybox.WatchUi;

// Requests and handles stop data.
module NearbyStopsService {

    // API: SL Nearby Stops 2
    // https://www.trafiklab.se/api/trafiklab-apis/sl/nearby-stops-2/
    // Bronze: 10_000/month, 30/min

    // edges of the operator zone, with an extra 2 km offset
    const _BOUNDS_SOUTH = 58.783223; // Ankarudden (Nynäshamn)
    const _BOUNDS_NORTH = 60.225171; // Ellans Vändplan (Norrtälje)
    const _BOUNDS_WEST = 17.239541; // Dammen (Nykvarn)
    const _BOUNDS_EAST = 19.116554; // Räfsnäs Brygga (Norrtälje)

    const _MAX_RADIUS = 2000; // default 1000, max 2000 (meters)

    var isRequesting as Boolean = false;

    // request

    function requestNearbyStops(latLon as LatLon) as Void {
        // final check
        if (handleLocationOff()) { return; }

        // check if not positioned
        if (ArrUtil.equals(latLon, [ 0.0d, 0.0d ])) { return; }

        // check if outside bounds, to not make unnecessary calls outside the operator zone
        if (latLon[0] < _BOUNDS_SOUTH || latLon[0] > _BOUNDS_NORTH
            || latLon[1] < _BOUNDS_WEST || latLon[1] > _BOUNDS_EAST) {

            NearbyStopsStorage.setResponseError(new ResponseError(getString(Rez.Strings.msg_i_stops_outside_bounds)));
        }
        else {
            _requestNearbyStops(latLon);
        }
    }

    function _requestNearbyStops(latLon as LatLon) as Void {
        isRequesting = true;

        // transition to new url 2023-12-04--2024-03-15
        var url = "https://journeyplanner.integration.sl.se/v1/nearbystopsv2.json";

        var params = {
            "key" => API_KEY_STOPS,
            "originCoordLat" => latLon[0],
            "originCoordLong" => latLon[1],
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

    function onReceiveNearbyStops(responseCode as Number, data as JsonDict?) as Void {
        isRequesting = false;

        // request error
        if (responseCode != ResponseError.HTTP_OK || data == null) {
            NearbyStopsStorage.setResponseError(new ResponseError(responseCode));

            // auto-refresh if too large
            if (NearbyStopsStorage.shouldAutoRefresh()) {
                requestNearbyStops(Footprint.getLatLonDeg());
            }
        }

        // operator error
        else if (DictUtil.hasValue(data, "StatusCode")) {
            //var msg = data["Message"];
            var statusCode = data["StatusCode"] as Number;
            NearbyStopsStorage.setResponseError(new ResponseError(statusCode));
        }

        // no stops found
        else if (!DictUtil.hasValue(data, "stopLocationOrCoordLocation")) {
            NearbyStopsStorage.setResponse([], [], [], []);
        }

        // success
        else {
            _handleNearbyStopsResponseOk(data["stopLocationOrCoordLocation"]);
        }

        WatchUi.requestUpdate();
    }

    function _handleNearbyStopsResponseOk(stopsData as JsonArray) as Void {
        var stopIds = [];
        var stopNames = [];
        var stopProducts = [];
        var stops = [];

        for (var i = 0; i < stopsData.size(); i++) {
            var stopData = stopsData[i]["StopLocation"] as JsonDict;

            var extId = stopData["mainMastExtId"];
            var id = extId.substring(5, extId.length()).toNumber();
            var name = stopData["name"];
            var products = stopData["products"].toNumber();

            // null if duplicate
            var stop = NearbyStopsStorage.createStop(id, name, products, stops, stopIds, stopNames);
            if (stop == null) {
                continue;
            }

            stopIds.add(id);
            stopNames.add(name);
            stopProducts.add(products);
            stops.add(stop);
        }

        NearbyStopsStorage.setResponse(stopIds, stopNames, stopProducts, stops);
    }

    // tools

    function handleLocationOff() as Boolean {
        // don't request using position if location setting is off
        if (!SettingsStorage.getUseLocation()) {
            NearbyStopsStorage.setResponseError(new ResponseError(ResponseError.CODE_LOCATION_OFF));
            WatchUi.requestUpdate();
            return true;
        }

        return false;
    }

}
