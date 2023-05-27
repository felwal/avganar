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

        var maxDepartures = SettingsStorage.getMaxDepartures(); // -1
        var modes = [ "BUS", "METRO", "TRAIN", "TRAM", "SHIP" ];
        var modeDepartures = { "BUS" => [], "METRO" => [], "TRAIN" => [], "TRAM" => [], "SHIP" => [] };
        var departuresData = data["Departure"];

        for (var d = 0; d < departuresData.size(); d++) {
            var departureData = departuresData[d];

            var mode = departureData["ProductAtStop"]["catCode"].toNumber();
            var line = departureData["ProductAtStop"]["displayNumber"];
            var destination = departureData["direction"];
            var time = departureData["time"];
            var date = departureData["date"];

            var dateTime = date + "T" + time;
            var moment = TimeUtil.localIso8601StrToMoment(dateTime);

            var departure = new Departure(mode, line, destination, moment, 0, false);

            if (mode == 3 || mode == 7) {
                modeDepartures["BUS"].add(departure);
            }
            else if (mode == 5) {
                modeDepartures["METRO"].add(departure);
            }
            else if (mode == 1 || mode == 2 || mode == 4) {
                modeDepartures["TRAIN"].add(departure);
            }
            else if (mode == 6) {
                modeDepartures["TRAM"].add(departure);
            }
            else if (mode == 8) {
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
