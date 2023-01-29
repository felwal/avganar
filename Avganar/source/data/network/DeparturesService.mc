using Toybox.Communications;
using Toybox.WatchUi;
using Carbon.C14;
using Carbon.Chem;

class DeparturesService {

    // Realtidsinformation 4
    // Bronze: 10_000/month, 30/min

    static hidden const _RESPONSE_OK = 200;

    hidden var _stop;

    // init

    function initialize(stop) {
        _stop = stop;
    }

    // request

    function requestDepartures() {
        if (_stop != null) {
            Log.i("Requesting departures for siteId " + _stop.getId() + " for " + _stop.getTimeWindow() + " min ...");
            _requestDepartures();
        }
    }

    hidden function _requestDepartures() {
        var url = "https://api.sl.se/api2/realtimedeparturesv4.json";

        var params = {
            "key" => API_KEY_DEPARTURES,
            "siteid" => _stop.getId(),
            "timewindow" => _stop.getTimeWindow()
        };
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            // NOTE: url doesnt work without ".json"; set type there instead of here
            //:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
            :headers => { "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON }
        };

        Communications.makeWebRequest(url, params, options, method(:onReceiveDepartures));
    }

    // receive

    function onReceiveDepartures(responseCode, data) {
        if (responseCode == _RESPONSE_OK && DictUtil.hasValue(data, "ResponseData")) {
            _handleDeparturesResponseOk(data);
        }
        else {
            Log.i("Departures response error (code " + responseCode + "): " + data);

            var error = new ResponseError(responseCode);
            _stop.setResponse(error);

            // auto rerequest if too large
            // – but don't go below 1 min timewindow
            if (error.isTooLarge() && _stop.getTimeWindow() >= 1) {
                requestDepartures();
            }
        }

        WatchUi.requestUpdate();
    }

    hidden function _handleDeparturesResponseOk(data) {
        var statusCode = data["StatusCode"];

        // Trafiklab error
        if (statusCode != 0) {
            Log.i("Departures SL request error (code " + statusCode + ")");

            _stop.setResponse(new ResponseError(statusCode));

            return;
        }

        //Log.d("Departures response success: " + data);

        // departure count per mode

        var modes = [ "Metros", "Buses", "Trains", "Trams", "Ships" ];
        var modeCount = 0;

        var maxDepartures = SettingsStorage.getMaxDepartures();
        var maxDeparturesPerMode = null;

        if (maxDepartures != -1) {
            // get the number of active modes
            // in order to calculate `maxDeparturesPerMode`
            for (var m = 0; m < modes.size(); m++) {
                var modeData = data["ResponseData"][modes[m]];

                if (modeData.size() > 0) {
                    modeCount++;
                }
            }

            maxDeparturesPerMode = modeCount != 0
                ? maxDepartures / modeCount
                : 0;
        }

        // departures

        var departures = [];

        for (var m = 0; m < modes.size(); m++) {
            var modeData = data["ResponseData"][modes[m]];
            var modeDepartures = [];

            var departureCount = maxDeparturesPerMode == null
                ? modeData.size()
                : Chem.min(maxDeparturesPerMode, modeData.size());

            for (var d = 0; d < departureCount; d++) {
                var departureData = modeData[d];

                var mode = departureData["TransportMode"];
                var group = DictUtil.get(departureData, "GroupOfLine", "");
                var line = departureData["LineNumber"];
                var destination = departureData["Destination"];
                var dateTime = departureData["ExpectedDateTime"];
                var deviations = DictUtil.get(departureData, "Deviations", []);

                var moment = C14.localIso8601StrToMoment(dateTime);
                var deviationLevel = 0;

                for (var i = 0; i < deviations.size(); i++) {
                    if (deviations[i]["Consequence"] == "CANCELLED") {
                        deviationLevel = Departure.CANCELLED;
                        break;
                    }

                    deviationLevel = Chem.max(deviationLevel, deviations[i]["ImportanceLevel"]);
                }

                modeDepartures.add(new Departure(mode, group, line, destination, moment, deviationLevel));
            }

            // add null because an ampty array is not matched with the `equals()` that `removeAll()` performs.
            departures.add(modeDepartures.size() != 0 ? modeDepartures : null);
        }

        // swap order of metros and buses
        ArrUtil.swap(departures, 0, 1);
        departures.removeAll(null);

        if (departures.size() != 0) {
            _stop.setResponse(departures);
        }
        else {
            Log.i("Departures response empty of departures");
            _stop.setResponse(rez(Rez.Strings.lbl_i_departures_none));
        }

        // stop point deviation

        var stopDeviations = data["ResponseData"]["StopPointDeviations"];
        var stopDeviationLevel = 0;

        for (var i = 0; i < stopDeviations.size(); i++) {
            stopDeviationLevel = Chem.max(
                stopDeviationLevel,
                DictUtil.get(DictUtil.get(stopDeviations[i], "Deviation", null), "ImportanceLevel", 0));
        }

        _stop.setDeviationLevel(stopDeviationLevel);
    }

}
