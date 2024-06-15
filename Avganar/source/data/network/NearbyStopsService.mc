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

    // Resrobot v2.1 Nearby stops
    // https://www.trafiklab.se/api/trafiklab-apis/resrobot-v21/nearby-stops/
    // Bronze: 30_000/month, 45/min

    // edges of the operator zone
    const _BOUNDS_SOUTH = 55.33; // Smygehuk (Trelleborg)
    const _BOUNDS_NORTH = 69.06; // Treriksröset (Kiruna)
    const _BOUNDS_WEST = 10.95; // Stora Drammen (Strömstad)
    const _BOUNDS_EAST = 24.16; // Kataja (Haparanda)

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

            NearbyStopsStorage.setResponseError(
                new ResponseError(getString(Rez.Strings.msg_i_stops_outside_bounds), null));
        }
        else {
            _requestNearbyStops(latLon);
        }
    }

    function _requestNearbyStops(latLon as LatLon) as Void {
        isRequesting = true;

        var url = "https://api.resrobot.se/v2.1/location.nearbystops";

        var params = {
            "accessId" => API_KEY,
            "originCoordLat" => latLon[0],
            "originCoordLong" => latLon[1],
            "r" => _MAX_RADIUS,
            "maxNo" => def(NearbyStopsStorage.maxStops, SettingsStorage.getMaxStops()),
            "lang" => getString(Rez.Strings.lang_code),
            "format" => "json"
        };
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :headers => { "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON }
        };

        Communications.makeWebRequest(url, params, options, new Lang.Method(NearbyStopsService, :onReceiveNearbyStops));
        //Log.i("Requesting " + NearbyStopsStorage.maxStops + " stops for coords (" + latLon[0] + ", " + latLon[1] + ") ...");
    }

    // receive

    function onReceiveNearbyStops(responseCode as Number, data as JsonDict?) as Void {
        isRequesting = false;
        //Log.d("Stops response (" + responseCode + "): " + data);

        // request error
        if (responseCode != ResponseError.HTTP_OK || data == null) {
            NearbyStopsStorage.setResponseError(new ResponseError(responseCode, null));

            // auto-refresh if too large
            if (NearbyStopsStorage.shouldAutoRefresh()) {
                requestNearbyStops(Footprint.getLatLonDeg());
            }
        }

        // operator error
        else if (DictUtil.hasValue(data, "errorCode")) {
            var errorCode = data["errorCode"];
            NearbyStopsStorage.setResponseError(new ResponseError(responseCode, errorCode));
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

            var id = stopData["extId"].toNumber();
            var name = stopData["name"];
            var products = stopData["products"].toNumber();

            // NOTE: API limitation
            name = _cleanStopName(name);

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

    function _cleanStopName(name as String) as String {
        // NOTE: API limitation

        name = StringUtil.removeEnding(name, "("); // remove e.g. "(Stockholm kn)"
        name = StringUtil.remove(name, " station");

        return name;
    }

    function handleLocationOff() as Boolean {
        // don't request using position if location setting is off
        if (!SettingsStorage.getUseLocation()) {
            NearbyStopsStorage.setResponseError(new ResponseError(ResponseError.CODE_LOCATION_OFF, null));
            WatchUi.requestUpdate();
            return true;
        }

        return false;
    }

}
