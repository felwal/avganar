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

//! Requests and handles conversion between national and local stops.
class LocalStopsService {

    static var isRequesting as Boolean = false;

    private var _siteIds = [];
    private var _stopNames = [];
    private var _nationalIds as Array<Number>;
    private var _stopProducts as Array<Number>;
    private var _i = 0;

    // init

    function initialize(nationalIds as Array<Number>, stopProducts as Array<Number>) {
        _nationalIds = nationalIds;
        _stopProducts = stopProducts;
    }

    // request

    function requestStopsIds() {
        isRequesting = true;
        _requestStopIds(_nationalIds[0]);
    }

    private function _requestStopIds(nationalId as Number) as Void {
        var url = "https://api.avganar.felixwallin.se/sl-national-stops/" + nationalId + ".json";

        var params = {};
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :headers => { "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON }
        };

        Communications.makeWebRequest(url, params, options, method(:onReceiveStopIds));
        //Log.i("Requesting siteId for nationalId " + nationalId);
    }

    // receive

    function onReceiveStopIds(responseCode as Number, data as CommResponseData) as Void {
        //Log.d("Id response (" + responseCode + "): " + data);

        if (responseCode == ResponseError.HTTP_OK) {
            var name = data["name"];

            // NOTE: API limitation
            name = NearbyStopsService.cleanStopName(name);

            _siteIds.add(data["site_id"]);
            _stopNames.add(name);
        }
        else if (responseCode == ResponseError.HTTP_NOT_FOUND) {
            _siteIds.add(null);
            _stopNames.add(null);
            //Log.w("No mapping from national id " + _nationalIds[_i] + " to site id");
        }
        else {
            isRequesting = false;
            NearbyStopsStorage.setResponseError(new ResponseError(responseCode, null));
            WatchUi.requestUpdate();
            return;
        }

        _i += 1;

        if (_i < _nationalIds.size()) {
            _requestStopIds(_nationalIds[_i]);
        }
        else {
            _handleAllStopsIdsReceived();
        }
    }

    private function _handleAllStopsIdsReceived() {
        isRequesting = false;
        //Log.d("Ids responses: " + _siteIds);

        var stopIds = [];
        var stopNames = [];
        var stopProducts = [];
        var stops = [];

        for (var i = 0; i < _siteIds.size(); i++) {
            if (_siteIds[i] == null) {
                continue;
            }

            // null if duplicate
            var stop = NearbyStopsStorage.createStop(_siteIds[i], _stopNames[i], _stopProducts[i], stops, stopIds, stopNames);
            if (stop == null) {
                continue;
            }

            // create new lists to avoid saving ids etc for duplicate stops
            stopIds.add(_siteIds[i]);
            stopNames.add(_stopNames[i]);
            stopProducts.add(_stopProducts[i]);
            stops.add(stop);
        }

        NearbyStopsStorage.setResponse(stopIds, stopNames, stopProducts, stops);
        WatchUi.requestUpdate();
    }

}
