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

    // API: SL Transport 1
    // https://www.trafiklab.se/api/trafiklab-apis/sl/transport/
    // no key, no limit

    static var isRequesting as Boolean = false;

    private var _stop as StopType;
    private var _modeKey as String = Mode.KEY_ALL;

    // init

    function initialize(stop as StopType) {
        _stop = stop;
    }

    // request

    function requestDepartures(modeKey as String) as Void {
        _modeKey = modeKey;
        _requestDepartures(modeKey);
    }

    private function _requestDepartures(modeKey as String) as Void {
        isRequesting = true;

        var url = "https://transport.integration.sl.se/v1/sites/" + _stop.getId() + "/departures";

        var params = {
            // NOTE: the API seems to ignore this whenever it feels like it
            "forecast" => _stop.getMode(modeKey).getTimeWindow()
        };

        // NOTE: migration to 1.8.0
        // no products saved => ´mode´ = null => request all modes
        // (same behaviour as before)
        if (!modeKey.equals(Mode.KEY_ALL)) {
            params["transport"] = modeKey;
        }

        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :headers => { "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON }
        };

        Communications.makeWebRequest(url, params, options, method(:onReceiveDepartures));
        //Log.i("Requesting " + modeKey + " departures for siteId " + _stop.getId() + " for " + _stop.getMode(modeKey).getTimeWindow() + " min ...");
    }

    // receive

    function onReceiveDepartures(responseCode as Number, data as CommResponseData) as Void {
        isRequesting = false;
        //Log.d("Departures response (" + responseCode + "): " + data);

        // request error
        if (responseCode != ResponseError.HTTP_OK || data == null) {
            _stop.setDeparturesResponse(_modeKey, new ResponseError(responseCode, null));

            // auto-refresh if too large
            if (_stop.getMode(_modeKey).shouldAutoRefresh()) {
                requestDepartures(_modeKey);
            }
        }

        // operator error / no departures found
        else if (!DictUtil.hasValue(data, "departures") || data["departures"].size() == 0) {
            if (DictUtil.hasValue(data, "message")) {
                _stop.setDeparturesResponse(_modeKey, new ResponseError(data["message"], null));
            }
            else {
                _stop.setDeparturesResponse(_modeKey, []);
            }
        }

        // success
        else {
            _handleDeparturesResponseOk(data["departures"]);
        }

        // stop deviations
        if (DictUtil.hasValue(data, "stop_deviations")) {
            _handleStopDeviations(data["stop_deviations"]);
        }

        WatchUi.requestUpdate();
    }

    private function _handleDeparturesResponseOk(departuresData as JsonArray) as Void {
        var modesKeys = [ Mode.KEY_BUS, Mode.KEY_METRO, Mode.KEY_TRAIN,
            Mode.KEY_TRAM, Mode.KEY_SHIP ]; // determines ordering of modes

        var departures = {};

        for (var i = 0; i < departuresData.size(); i++) {
            var departureData = departuresData[i] as JsonDict;
            var lineData = departureData["line"] as JsonDict;

            var modeKey = lineData["transport_mode"];

            // add any potential "other" modes to the end of the list
            if (!ArrUtil.contains(modesKeys, modeKey)) {
                modesKeys.add(modeKey);
            }

            var group = DictUtil.get(lineData, "group_of_lines", "");
            var line = lineData["designation"];
            var destination = departureData["destination"];
            var plannedDateTime = DictUtil.get(departureData, "scheduled", null);
            var expectedDateTime = DictUtil.get(departureData, "expected", null);
            var deviation = _getDepartureDeviation(DictUtil.get(departureData, "deviations", []));

            var isRealTime = expectedDateTime != null && !expectedDateTime.equals(plannedDateTime);
            var moment = TimeUtil.localIso8601StrToMoment(expectedDateTime);
            // expectedDateTime == null => "–"

            // NOTE: API limitation
            // remove duplicate "subline" in e.g. "571X X Arlandastad"
            if (destination.substring(0, 2).equals(StringUtil.charAt(line, line.length() - 1) + " ")) {
                destination = destination.substring(2, destination.length());
            }

            // NOTE: API limitation
            destination = NearbyStopsService.cleanStopName(destination);

            var departure = new Departure(modeKey, group, line, destination, moment,
                deviation, isRealTime);

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

    private function _getDepartureDeviation(deviations as JsonArray) as DepartureDeviation {
        var maxLevel = 0;
        var messages = [];
        var cancelled = false;

        for (var i = 0; i < deviations.size(); i++) {
            var msg = DictUtil.get(deviations[i], "message", null);
            if (msg != null) {
                msg = _splitDeviationMessageByLang(msg); // (not often the case)
                messages.add(msg);
            }

            if ("CANCELLED".equals(deviations[i]["consequence"])) {
                cancelled = true;
                // don't let cancelled inform level
                continue;
            }

            var level = deviations[i]["importance_level"];
            if (level != null && level > maxLevel) {
                maxLevel = level;
            }
        }

        return [ maxLevel, messages, cancelled ];
    }

    private function _handleStopDeviations(stopDeviations as JsonArray) as Void {
        var stopDeviationMessages = [];

        for (var i = 0; i < stopDeviations.size(); i++) {
            var stopDeviation = stopDeviations[i] as JsonDict;
            var msg = DictUtil.get(stopDeviation, "message", null);

            if (msg == null) { continue; }

            msg = _splitDeviationMessageByLang(msg);
            msg = _cleanDeviationMessage(msg);

            // NOTE: API limitation
            // sometimes we get duplicate deviation messages. skip these.
            if (!ArrUtil.contains(stopDeviationMessages, msg)) {
                stopDeviationMessages.add(msg);
            }
        }

        _stop.setDeviationMessages(stopDeviationMessages);
    }

    // tools

    private function _splitDeviationMessageByLang(msg as String) as String {
        // NOTE: API limitation
        // some messages are in both Swedish and English,
        // separated by a " * "

        var langSeparator = " * ";
        var langSplitIndex = msg.find(langSeparator);

        if (langSplitIndex != null) {
            var isSwe = SystemUtil.isLangSwe();

            msg = msg.substring(
                isSwe ? 0 : langSplitIndex + langSeparator.length(),
                isSwe ? langSplitIndex : msg.length());
        }

        return msg;
    }

    private function _cleanDeviationMessage(msg as String) as String {
        // NOTE: API limitation
        // remove references at the end of messages (to save space)

        var references = [
            ", sök din resa i SL-appen eller på sl.se.",
            ", plan your trip at sl.se",
            "Sök din resa och läs mer på sl.se eller i SL-appen.",
            "Sök din resa på sl.se eller i appen.",
            "Sök din resa i SL-appen.",
            "Plan your trip at sl.se.",
            "För mer information, se sl.se",
            "More information at sl.se or in the SL-app.",
            "Mer info på sl.se eller i SL-appen.",
            "More info in the SL-app.",
            "Mer info i SL-appen.",
            "Se sl.se eller i appen.",
            "Läs mer på Trafikläget.",
            "Read more at sl.se.",
            ", läs mer på sl.se",
            "Läs mer på sl.se.",
            "Läs mer på sl.se",
            "Se mer på sl.se",
            ", se sl.se",
            "Se sl.se.",
            "Se sl.se"
        ];

        for (var i = 0; i < references.size(); i++) {
            var refStartIndex = msg.find(references[i]);

            if (refStartIndex != null) {
                // the reference is always at the end
                msg = msg.substring(0, refStartIndex);
                // each message will contain max one reference
                break;
            }
        }

        // remove space and (less common) newline endings
        msg = StringUtil.trim(msg);

        return msg;
    }

}
