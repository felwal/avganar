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
    // no key, no limit

    hidden var _stop as StopType;
    hidden var _mode as String?;

    static var isRequesting = false;

    // init

    function initialize(stop as StopType) {
        _stop = stop;
    }

    // request

    function requestDepartures(mode as String?) as Void {
        Log.i("Requesting " + mode + " departures for siteId " + _stop.getId() + " for " + _stop.getTimeWindow(mode) + " min ...");
        _mode = mode;
        _requestDepartures(mode);
    }

    hidden function _requestDepartures(mode as String?) as Void {
        DeparturesService.isRequesting = true;
        WatchUi.requestUpdate();

        var url = "https://transport.integration.sl.se/v1/sites/" + _stop.getId() + "/departures";

        var params = {
            // NOTE: the API seems to ignore this whenever it feels like it
            "forecast" => _stop.getTimeWindow(mode)
        };

        // NOTE: migration to 1.8.0
        // no products saved => ´mode´ = null => request all modes
        // (same behaviour as before)
        if (mode != null && !mode.equals(Departure.MODE_ALL)) {
            params["transport"] = mode;
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

        if (responseCode != ResponseError.HTTP_OK || data == null) {
            Log.i("Departures response error (code " + responseCode + "): " + data);

            _stop.setResponse(_mode, new ResponseError(responseCode));

            // auto-refresh if too large
            if (_stop.shouldAutoRefresh(_mode)) {
                requestDepartures(_mode);
            }
        }
        else if (!DictUtil.hasValue(data, "departures")) {
            var errorMsg = DictUtil.get(data, "message", "no error msg");

            Log.i("Departures operator request error (" + errorMsg + ")");

            _stop.setResponse(_mode, new ResponseError(errorMsg));

            // auto-refresh if server error
            // TODO: probably can't happen with new API
            // – but look for messages which might correspond
            // with the previous server errors
            /*if (_stop.shouldAutoRefresh(_mode)) {
                requestDepartures(_mode);
            }*/
        }
        else {
            _handleDeparturesResponseOk(data);
        }

        WatchUi.requestUpdate();
    }

    hidden function _handleDeparturesResponseOk(data as JsonDict) as Void {
        //Log.d("Departures response success: " + data);

        var departuresData = data["departures"] as JsonArray;

        if (departuresData.size() == 0) {
            Log.i("Departures response empty of departures");
            _stop.setResponse(_mode, rez(Rez.Strings.msg_i_departures_none));
        }

        var modes = [
            Departure.MODE_BUS,
            Departure.MODE_METRO,
            Departure.MODE_TRAIN,
            Departure.MODE_TRAM,
            Departure.MODE_SHIP
        ]; // determines ordering of modes
        var modeDepartures = {};

        var maxDepartures = SettingsStorage.getMaxDepartures();
        var departureCount = maxDepartures == -1
            ? departuresData.size()
            : MathUtil.min(departuresData.size(), maxDepartures);

        // departures

        for (var d = 0; d < departureCount; d++) {
            var departureData = departuresData[d] as JsonDict;
            var lineData = departureData["line"] as JsonDict;

            var mode = lineData["transport_mode"];

            // TODO: check if there are other modes we should include.
            // for now, skip them
            if (!ArrUtil.contains(modes, mode)) {
                Log.w("Ignoring mode " + mode);
                continue;
            }

            var group = DictUtil.get(lineData, "group_of_lines", "");
            var line = lineData["designation"]; // TODO: or "id"?
            var destination = departureData["destination"];
            var plannedDateTime = departureData["scheduled"];
            var expectedDateTime = departureData["expected"];
            var deviations = DictUtil.get(departureData, "deviations", []);

            var isRealTime = expectedDateTime != null && !expectedDateTime.equals(plannedDateTime);
            var moment = TimeUtil.localIso8601StrToMoment(expectedDateTime);
            var deviationLevel = 0;
            var deviationMessages = [];
            var cancelled = false;

            // NOTE: API limitation
            // TODO: check if still necessary for new API
            // remove duplicate "subline" in e.g. "571X X Arlandastad"
            if (destination.substring(0, 2).equals(StringUtil.charAt(line, line.length() - 1) + " ")) {
                destination = destination.substring(2, destination.length());
            }

            // departure deviations
            for (var i = 0; i < deviations.size(); i++) {
                var msg = DictUtil.get(deviations[i], "message", null);
                if (msg != null) {
                    msg = _splitDeviationMessageByLang(msg); // (not often the case)
                    deviationMessages.add(msg);
                }

                if ("CANCELLED".equals(deviations[i]["consequence"])) {
                    cancelled = true;
                    // don't let cancelled inform deviationLevel
                    continue;
                }

                var level = deviations[i]["importance_level"];
                if (level != null) {
                    deviationLevel = MathUtil.max(deviationLevel, level);
                }
            }

            var departure = new Departure(mode, group, line, destination, moment,
                deviationLevel, deviationMessages, cancelled, isRealTime);

            if (!modeDepartures.hasKey(mode)) {
                modeDepartures[mode] = [];
            }

            // add to array
            modeDepartures[mode].add(departure);
        }

        for (var m = 0; m < modes.size(); m++) {
            var mode = modes[m];

            if (!modeDepartures.hasKey(mode)) {
                continue;
            }

            if (modeDepartures[mode].size() != 0) {
                _stop.setResponse(mode, modeDepartures[modes[m]]);
            }
            else {
                Log.i("Departures mode response empty of departures");
                _stop.setResponse(mode, rez(Rez.Strings.msg_i_departures_none));
            }
        }

        // stop point deviations

        var stopDeviations = data["stop_deviations"] as JsonArray;
        var stopDeviationMessages = [];

        for (var i = 0; i < stopDeviations.size(); i++) {
            var stopDeviation = stopDeviations[i] as JsonDict;
            var msg = DictUtil.get(stopDeviation, "message", null);

            if (msg == null) {
                continue;
            }

            msg = _splitDeviationMessageByLang(msg);
            msg = _cleanDeviationMessage(msg);

            // NOTE: API limitation
            // TODO: check if still necessary for new API
            // sometimes we get duplicate deviation messages. skip these.
            if (!ArrUtil.contains(stopDeviationMessages, msg)) {
                stopDeviationMessages.add(msg);
            }
        }

        _stop.setDeviation(stopDeviationMessages);
    }

    hidden function _splitDeviationMessageByLang(msg as String) as String {
        // NOTE: API limitation
        // TODO: check if still necessary for new API
        // some messages are in both Swedish and English,
        // separated by a " * "

        var langSeparator = " * ";
        var langSplitIndex = msg.find(langSeparator);

        if (langSplitIndex != null) {
            //Log.d("stop deviation msg: " + msg);
            var isSwe = SystemUtil.isLangSwe();

            msg = msg.substring(
                isSwe ? 0 : langSplitIndex + langSeparator.length(),
                isSwe ? langSplitIndex : msg.length());
        }

        return msg;
    }

    hidden function _cleanDeviationMessage(msg as String) as String {
        // NOTE: API limitation
        // remove references at the end of messages

        var references = [
            "Sök din resa på sl.se eller i appen.",
            "För mer information, se sl.se",
            "Se sl.se eller i appen.",
            "Läs mer på sl.se.",
            "Läs mer på sl.se",
            "Se sl.se.",
            "Se sl.se",
            ", se sl.se",
            "Läs mer på Trafikläget."
        ];

        for (var j = 0; j < references.size(); j++) {
            var refStartIndex = msg.find(references[j]);

            if (refStartIndex != null) {
                // the reference is always at the end
                msg = msg.substring(0, refStartIndex);
                // each message will contain max one reference
                break;
            }
        }

        // remove space and (less common) newline endings
        if (ArrUtil.contains([" ", "\n"], StringUtil.charAt(msg, msg.length() - 1))) {
            msg = msg.substring(0, msg.length() - 1);
        }

        return msg;
    }

}
