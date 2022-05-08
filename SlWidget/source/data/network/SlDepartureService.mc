using Toybox.Communications;
using Toybox.Lang;
using Toybox.WatchUi;
using Carbon.Footprint;

class SlDepartureService {

    private static const _RESPONSE_OK = 200;

    // departures max departures
    private static const _MAX_DEPARTURES = 15;
    // departures time window (max = 60)
    private static const _TIME_WINDOW = 60;
    private static const _TIME_WINDOW_SHORT = 10;

    private var _stop;
    private var _maxDepartures;
    private var _timeWindow;

    // init

    function initialize(stop, shortTimeWindow) {
        _stop = stop;
        _maxDepartures = _MAX_DEPARTURES;
        _timeWindow = shortTimeWindow ? _TIME_WINDOW_SHORT : _TIME_WINDOW;
    }

    // departures (Realtidsinformation 4)
    // bronze: 10_000/month, 30/min
    // TODO: only call these when the time diff is > x s

    function requestDepartures() {
        if (_stop != null && _stop.id != Stop.NO_ID) {
            Log.i("Requesting departures for siteId " + _stop.id + " ...");
            _requestDepartures();
        }
    }

    private function _requestDepartures() {
        var url = "https://api.sl.se/api2/realtimedeparturesv4.json";

        var params = {
            "key" => KEY_RI,
            "siteid" => _stop.id.toNumber(),
            "timewindow" => _timeWindow
        };

        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            // TODO: url doesnt work without .json
            //:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
            :headers => { "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON }
        };

        Communications.makeWebRequest(url, params, options, method(:onReceiveDepartures));
    }

    function onReceiveDepartures(responseCode, data) {
        if (responseCode == _RESPONSE_OK && DictCompat.hasKey(data, "ResponseData")) {
            _handleDeparturesResponseOk(data);
        }
        else {
            _handleDeparturesResponseError(responseCode, data);
        }

        WatchUi.requestUpdate();
    }

    private function _handleDeparturesResponseOk(data) {
        Log.d("Departures response success: " + data);

        var modes = [ "Metros", "Buses", "Trains", "Trams", "Ships" ];
        var departures = [];

        for (var m = 0; m < modes.size(); m++) {
            var modeData = data["ResponseData"][modes[m]];
            var modeDepartures = [];

            for (var d = 0; d < modeData.size() && modeDepartures.size() < _MAX_DEPARTURES; d++) {
                var departureData = modeData[d];

                var mode = departureData["TransportMode"];
                var group = DictCompat.get(departureData, "GroupOfLine", "");
                var line = departureData["LineNumber"];
                var destination = departureData["Destination"];
                var direction = departureData["DepartureDirection"];
                var displayTime = departureData["DisplayTime"];

                modeDepartures.add(new Departure(mode, group, line, destination, direction, displayTime));
            }

            // add null because an ampty array is not matched with the equals() removeAll() performes.
            departures.add(modeDepartures.size() != 0 ? modeDepartures : null);
        }

        // swap order of metros and buses
        ArrCompat.swap(departures, 0, 1);
        departures.removeAll(null);

        if (departures.size() != 0) {
            _stop.setDepartures(departures);
        }
        else {
            Log.d("Departures response empty of departures");
            _stop.setDeparturesPlaceholder(null, rez(Rez.Strings.lbl_i_departures_none_found));
        }
    }

    private function _handleDeparturesResponseError(responseCode, data) {
        var message;

        if (responseCode == _RESPONSE_OK) {
           message = rez(Rez.Strings.lbl_e_null_data);
        }
        else if (responseCode == Communications.BLE_CONNECTION_UNAVAILABLE) {
            // no bluetooth
            message = rez(Rez.Strings.lbl_e_connection);
        }
        else if (responseCode == Communications.NETWORK_REQUEST_TIMED_OUT) {
            // no internet
            message = rez(Rez.Strings.lbl_e_connection);
        }
        else if (responseCode == Communications.NETWORK_RESPONSE_OUT_OF_MEMORY) {
            message = rez(Rez.Strings.lbl_e_memory);
        }
        else if (responseCode == Communications.BLE_QUEUE_FULL) {
            message = rez(Rez.Strings.lbl_e_queue_full);
        }
        else if (responseCode == Communications.NETWORK_RESPONSE_TOO_LARGE) {
            message = rez(Rez.Strings.lbl_e_response_size);
        }
        else if (responseCode == Communications.BLE_REQUEST_CANCELLED || responseCode == Communications.REQUEST_CANCELLED) {
            message = rez(Rez.Strings.lbl_e_cancelled);
        }
        else {
            Log.i("Departures response error (code " + responseCode + "): " + data);
            message = rez(Rez.Strings.lbl_e_general) + " " + responseCode;
        }

        _stop.setDeparturesPlaceholder(responseCode, message);
    }

}
