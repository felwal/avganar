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

//! Requests and handles departure data.
class DeparturesService {

    // Resrobot v2.1 Timetables
    // https://www.trafiklab.se/api/trafiklab-apis/resrobot-v21/timetables/
    // Bronze: 30_000/month, 45/min

    static var isRequesting as Boolean = false;

    private var _stop as StopType;
    private var _modeKey as Number = Mode.KEY_ALL;

    // init

    function initialize(stop as StopType) {
        _stop = stop;
    }

    // request

    function requestDepartures(modeKey as Number) as Void {
        _modeKey = modeKey;
        _requestDepartures(modeKey);
    }

    private function _requestDepartures(modeKey as Number) as Void {
        DeparturesService.isRequesting = true;

        var url = "https://api.resrobot.se/v2.1/departureBoard";

        var params = {
            "accessId" => API_KEY,
            "id" => _stop.getId(),
            "duration" => _stop.getMode(modeKey).getTimeWindow(),
            "lang" => getString(Rez.Strings.lang_code),
            "format" => "json"
        };

        // NOTE: migration to 1.8.0
        // no products saved => ´mode´ = Mode.KEY_ALL => request all modes
        // (same behaviour as before)
        if (modeKey != Mode.KEY_ALL) {
            params["products"] = modeKey;
        }

        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :headers => { "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON }
        };

        Communications.makeWebRequest(url, params, options, method(:onReceiveDepartures));
    }

    // receive

    function onReceiveDepartures(responseCode as Number, data as JsonDict?) as Void {
        DeparturesService.isRequesting = false;
        var errorCode = DictUtil.get(data, "errorCode", null);

        // request error
        if (responseCode != ResponseError.HTTP_OK || data == null) {
            _stop.setDeparturesResponse(_modeKey, new ResponseError(responseCode, errorCode));

            // auto-refresh if too large
            if (_stop.getMode(_modeKey).shouldAutoRefresh()) {
                requestDepartures(_modeKey);
            }
        }

        // operator error / no departures found
        else if (!DictUtil.hasValue(data, "Departure") || data["Departure"].size() == 0) {
            if (errorCode != null) {
                _stop.setDeparturesResponse(_modeKey, new ResponseError(responseCode, errorCode));
            }
            else {
                _stop.setDeparturesResponse(_modeKey, []);
            }
        }

        // success
        else {
            _handleDeparturesResponseOk(data["Departure"]);
        }

        WatchUi.requestUpdate();
    }

    private function _handleDeparturesResponseOk(departuresData as JsonArray) as Void {
        // taxis and flights are irrelevant
        // determines ordering of modes
        var modesKeys = [ Mode.KEY_BUS_LOCAL, Mode.KEY_BUS_EXPRESS, Mode.KEY_METRO,
            Mode.KEY_TRAIN_LOCAL, Mode.KEY_TRAIN_REGIONAL, Mode.KEY_TRAIN_EXPRESS,
            Mode.KEY_TRAM, Mode.KEY_SHIP ];

        var departures = {};

        for (var i = 0; i < departuresData.size(); i++) {
            var departureData = departuresData[i] as JsonDict;
            var productData = departureData["ProductAtStop"] as JsonDict;

            var modeKey = productData["cls"].toNumber();

            // add any potential "other" modes to the end of the list
            if (!ArrUtil.contains(modesKeys, modeKey)) {
                modesKeys.add(modeKey);
            }

            var line = productData["displayNumber"];
            var destination = departureData["direction"];
            // rtTime and rtDate are realtime data
            var time = departureData.hasKey("rtTime") ? departureData["rtTime"] : DictUtil.get(departureData, "time", null);
            var date = departureData.hasKey("rtDate") ? departureData["rtDate"] : DictUtil.get(departureData, "date", null);

            var moment = TimeUtil.localIso8601StrToMoment(date + "T" + time);

            // NOTE: API limitation
            destination = _cleanDepartureDestination(destination);

            var departure = new Departure(modeKey, line, destination, moment);

            if (!departures.hasKey(modeKey)) {
                departures[modeKey] = [];
            }

            // add to array
            departures[modeKey].add(departure);
        }

        // set stop response

        if (departures.size() == 0) {
            _stop.setDeparturesResponse(_modeKey, []);
            return;
        }

        for (var i = 0; i < modesKeys.size(); i++) {
            var modeKey = modesKeys[i];

            if (departures.hasKey(modeKey)) {
                _stop.setDeparturesResponse(modeKey, departures[modeKey]);
            }
        }
    }

    // tools

    function _cleanDepartureDestination(destination as String) as String {
        // remove e.g. "(Stockholm kn)"
        var destEndIndex = destination.find("(");
        if (destEndIndex != null) {
            destination = destination.substring(0, destEndIndex);
        }

        // remove unneccessary "T-bana"
        destEndIndex = destination.find(" T-bana");
        if (destEndIndex != null) {
            destination = destination.substring(0, destEndIndex);
        }

        return destination;
    }

}
