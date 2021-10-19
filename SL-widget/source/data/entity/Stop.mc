using Toybox.Lang;

(:glance)
class Stop {

    static const NO_ID = -1;

    var errorCode = null;
    var id;
    var name;

    private var _departures = [ [ Departure.placeholder(null, rez(Rez.Strings.lbl_i_departures_searching)) ] ];

    // init

    function initialize(id, name) {
        self.id = id;
        self.name = name;
    }

    static function placeholder(errorCode, msg) {
        var stop = new Stop(NO_ID, msg);
        stop.errorCode = errorCode;
        return stop;
    }

    // set

    function setDepartures(departures) {
        // don't put departure placeholders in placeholder stops
        if (id != NO_ID) {
            _departures = departures;
        }
    }

    // get

    function equals(object) {
        return id == object.id;
    }

    function getModeCount() {
        return _departures.size();
    }

    function getDepartureCount(mode) {
        if (mode < 0 || mode >= _departures.size()) {
            Log.w("getDepartureCount 'mode' (" + mode + ") out of range [0," + _departures.size() + "]; returning 0");
            return 0;
        }
        else if (!(_departures[mode] instanceof Lang.Array)) {
            Log.w("departures[" + mode + "] (not Array): " + _departures[mode] + "; returning 0");
            return 0;
        }
        return _departures[mode].size();
    }

    function getDepartures(mode) {
        if (mode >= 0 && mode < _departures.size()) {
            return _departures[mode];
        }
        else {
            Log.w("getDepartures 'mode' (" + mode + ") out of range [0," + _departures.size() + "]; returning []");
            return [];
        }
    }

    function getAllDepartures() {
        return _departures;
    }

    function getFirstDeparture() {
        return _departures[0][0];
    }

    function toDetailString(mode) {
        var string = "";

        for (var d = 0; d < 4 && d < _departures[mode].size(); d++) {
            string += _departures[mode][d].toString() + "\n";
        }

        return string;
    }

    function hasConnection() {
        return errorCode != Communications.BLE_CONNECTION_UNAVAILABLE
            && errorCode != Communications.NETWORK_REQUEST_TIMED_OUT
            && getFirstDeparture().hasConnection();
    }

    function areStopsRerequestable() {
        return id == NO_ID
            && errorCode != null
            && errorCode != Communications.BLE_CONNECTION_UNAVAILABLE;
    }

    function areDeparturesRerequestable() {
        return getFirstDeparture().areDeparturesRerequestable();
    }

}
