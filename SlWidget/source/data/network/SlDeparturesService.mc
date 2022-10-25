using Toybox.Communications;
using Toybox.WatchUi;
using Toybox.Time;
using Carbon.C14;

class SlDeparturesService {

    // Realtidsinformation 4
    // Bronze: 10_000/month, 30/min

    static private const _RESPONSE_OK = 200;

    private var _stop;

    // init

    function initialize(stop) {
        _stop = stop;
    }

    // request

    function requestDepartures() {
        if (_stop != null) {
            Log.i("Requesting departures for siteId " + _stop.id + " for " + _stop.getTimeWindow() + " min ...");
            _requestDepartures();
        }
    }

    private function _requestDepartures() {
        var url = "https://api.sl.se/api2/realtimedeparturesv4.json";

        var params = {
            "key" => KEY_RI,
            "siteid" => _stop.id,
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
        if (responseCode == _RESPONSE_OK && DictUtil.hasKey(data, "ResponseData")) {
            _handleDeparturesResponseOk(data);
        }
        else {
            Log.i("Departures response error (code " + responseCode + "): " + data);

            var error = new ResponseError(responseCode);
            _stop.setResponse(error);

            // auto rerequest if too large
            if (error.isTooLarge()) {
                requestDepartures();
            }
        }

        WatchUi.requestUpdate();
    }

    private function _handleDeparturesResponseOk(data) {
        var statusCode = data["StatusCode"];

        // SL error
        if (statusCode != 0) {
            Log.i("Departures SL request error (code " + statusCode + ")");

            _stop.setResponse(new ResponseError(statusCode));

            return;
        }

        Log.d("Departures response success: " + data);

        var modes = [ "Metros", "Buses", "Trains", "Trams", "Ships" ];
        var departures = [];

        for (var m = 0; m < modes.size(); m++) {
            var modeData = data["ResponseData"][modes[m]];
            var modeDepartures = [];

            for (var d = 0; d < modeData.size(); d++) {
                var departureData = modeData[d];

                var mode = departureData["TransportMode"];
                var group = DictUtil.get(departureData, "GroupOfLine", "");
                var line = departureData["LineNumber"];
                var destination = departureData["Destination"];
                var direction = departureData["DepartureDirection"];
                var dateTime = departureData["ExpectedDateTime"];
                var hasDeviations = departureData["Deviations"] != null;

                var moment = C14.localIso8601StrToMoment(dateTime);

                modeDepartures.add(new Departure(mode, group, line, destination, direction, moment, hasDeviations));
            }

            // add null because an ampty array is not matched with the equals() removeAll() performes.
            departures.add(modeDepartures.size() != 0 ? modeDepartures : null);
        }

        // swap order of metros and buses
        ArrUtil.swap(departures, 0, 1);
        departures.removeAll(null);

        if (departures.size() != 0) {
            _stop.setResponse(departures);
        }
        else {
            Log.d("Departures response empty of departures");
            _stop.setResponse(rez(Rez.Strings.lbl_i_departures_none));
        }
    }

}
