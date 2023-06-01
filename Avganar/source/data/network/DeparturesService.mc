using Toybox.Communications;
using Toybox.WatchUi;

class DeparturesService {

    // Resrobot v2.1 Timetables
    // Bronze: 30_000/month, 45/min

    static hidden const _RESPONSE_OK = 200;

    hidden var _stop;

    static var isRequesting = false;

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
        DeparturesService.isRequesting = true;
        WatchUi.requestUpdate();

        var url = "https://api.resrobot.se/v2.1/departureBoard";

        var params = {
            "accessId" => API_KEY,
            "id" => _stop.getId(),
            "duration" => _stop.getTimeWindow(),
            "maxJourneys" => 2,
            "lang" => "sv",
            "format" => "json"
        };
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :headers => { "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON }
        };

        Communications.makeWebRequest(url, params, options, method(:onReceiveDepartures));
    }

    // receive

    function onReceiveDepartures(responseCode, data) {
        DeparturesService.isRequesting = false;

        if (responseCode == _RESPONSE_OK) {
            _handleDeparturesResponseOk(data);
        }
        else {
            Log.i("Departures response error (code " + responseCode + "): " + data);

            _stop.setResponse(new ResponseError(responseCode));

            // auto rerequest if too large
            if (_stop.shouldAutoRerequest()) {
                requestDepartures();
            }
        }

        WatchUi.requestUpdate();
    }

    hidden function _handleDeparturesResponseOk(data) {
        var errorCode = data["errorCode"];

        // Trafiklab error
        if (errorCode != null) {
            Log.i("Departures operator request error (code " + errorCode + ")");

            _stop.setResponse(new ResponseError(errorCode));

            // auto rerequest if server error
            if (_stop.shouldAutoRerequest()) {
                requestDepartures();
            }

            return;
        }

        //Log.d("Departures response success: " + data);

        // departures

        if (!data.hasKey("Departure") || data["Departure"].size() == 0) {
            Log.i("Departures response empty of departures");
            _stop.setResponse(rez(Rez.Strings.msg_i_departures_none));
            return;
        }

        // taxis and flights are irrelevant
        var modes = [ "BUS", "METRO", "TRAIN", "TRAM", "SHIP" ];
        var modeDepartures = { "BUS" => [], "METRO" => [], "TRAIN" => [], "TRAM" => [], "SHIP" => [] };
        var departuresData = data["Departure"];

        var maxDepartures = SettingsStorage.getMaxDepartures();
        var departureCount = maxDepartures == -1
            ? departuresData.size()
            : MathUtil.min(departuresData.size(), maxDepartures);

        for (var d = 0; d < departureCount; d++) {
            var departureData = departuresData[d];

            var mode = departureData["ProductAtStop"]["catCode"].toNumber();
            var line = departureData["ProductAtStop"]["displayNumber"];
            var destination = departureData["direction"];
            // rtTime and rtDate are realtime data
            var time = departureData.hasKey("rtTime") ? departureData["rtTime"] : DictUtil.get(departureData, "time", null);
            var date = departureData.hasKey("rtDate") ? departureData["rtDate"] : DictUtil.get(departureData, "date", null);

            var moment = TimeUtil.localIso8601StrToMoment(date + "T" + time);

            // remove unneccessary "T-bana"
            var destEndIndex = destination.find(" T-bana");
            if (destEndIndex != null) {
                destination = destination.substring(0, destEndIndex);
            }

            var departure = new Departure(mode, line, destination, moment, 0, false);

            // add to array
            if (ArrUtil.contains(Departure.MODES_BUS, mode)) {
                modeDepartures["BUS"].add(departure);
            }
            else if (mode == Departure.MODE_METRO) {
                modeDepartures["METRO"].add(departure);
            }
            else if (ArrUtil.contains(Departure.MODES_TRAIN, mode)) {
                modeDepartures["TRAIN"].add(departure);
            }
            else if (mode == Departure.MODE_TRAM) {
                modeDepartures["TRAM"].add(departure);
            }
            else if (mode == Departure.MODE_SHIP) {
                modeDepartures["SHIP"].add(departure);
            }
        }

        var departures = [];

        for (var m = 0; m < modes.size(); m++) {
            if (modeDepartures[modes[m]].size() != 0) {
                departures.add(modeDepartures[modes[m]]);
            }
        }

        //Log.d("deps: " + departures);
        _stop.setResponse(departures);
    }

}
