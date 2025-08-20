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
    // Bronze: 25_000/month, 45/min

    // edges of the operator zone, with an extra 2 km offset
    const _BOUNDS_SOUTH = 58.783223; // Ankarudden (Nynäshamn)
    const _BOUNDS_NORTH = 60.225171; // Ellans Vändplan (Norrtälje)
    const _BOUNDS_WEST = 17.239541; // Dammen (Nykvarn)
    const _BOUNDS_EAST = 19.116554; // Räfsnäs Brygga (Norrtälje)

    const _MAX_RADIUS = 2000; // default 1000, max 2000 (meters)

    var isRequesting as Boolean = false;

    var _localStopsService as LocalStopsService? = null;

    // request

    function requestNearbyStops(latLon as LatLon) as Void {
        // final check
        if (handleLocationOff()) { return; }

        // check if not positioned
        if (ArrUtil.equals(latLon, [ 0.0d, 0.0d ])) { return; }

        // check if outside bounds, to not make unnecessary calls outside the operator zone
        if (latLon[0] < _BOUNDS_SOUTH || latLon[0] > _BOUNDS_NORTH
            || latLon[1] < _BOUNDS_WEST || latLon[1] > _BOUNDS_EAST) {

            NearbyStopsStorage.setResponseError(new ResponseError(getString(Rez.Strings.msg_i_stops_outside_bounds), null));
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

    function onReceiveNearbyStops(responseCode as Number, data as CommResponseData) as Void {
        isRequesting = false;
        //Log.d("Stops response (" + responseCode + "): " + data);

        // request error
        if (responseCode != ResponseError.HTTP_OK || data == null) {
            NearbyStopsStorage.setResponseError(new ResponseError(responseCode, null));

            // auto-refresh if too large
            if (NearbyStopsStorage.shouldAutoRefresh()) {
                requestNearbyStops(PosUtil.getLatLonDeg());
            }
        }

        // operator error
        else if (DictUtil.hasValue(data, "errorCode")) {
            //var msg = data["Message"];
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
        var stopNationalIds = [];
        var stopProducts = [];

        for (var i = 0; i < stopsData.size(); i++) {
            var stopData = stopsData[i]["StopLocation"] as JsonDict;

            var nationalId = stopData["extId"].toNumber();
            // products can't be correctly mapped between the apis; skip for now
            var products = null;//stopData["products"].toNumber();

            stopNationalIds.add(nationalId);
            stopProducts.add(products);
        }

        _localStopsService = new LocalStopsService(stopNationalIds, stopProducts);
        _localStopsService.requestStopsIds();
        WatchUi.requestUpdate();
    }

    // tools

    function cleanStopName(name as String) as String {
        // NOTE: API limitation

        name = StringUtil.replaceWord(name, "station", "stn");

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

    function getRequestLevel() as Number {
        if (_localStopsService == null) {
            return isRequesting ? 0 : -1;
        }
        else if (_localStopsService.isRequesting) {
            return 1;
        }
        else {
            _localStopsService = null;
            return -1;
        }
    }

}
