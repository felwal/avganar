using Toybox.Lang;

(:glance)
class Stop {

    static const NO_ID = -1;
    static const ERROR_CODE_NO_STOPS = -2000;
    static const ERROR_CODE_OUTSIDE_BOUNDS = -2001;

    var errorCode = null;
    var id;
    var name;

    private var _departures = [ [] ];

    // init

    function initialize(id, name) {
        self.id = id;
        self.name = name;

        // set searching placeholder
        setDeparturesPlaceholder(null, rez(Rez.Strings.lbl_i_departures_searching));
    }

    static function placeholder(errorCode, msg) {
        var stop = new Stop(NO_ID, msg);
        stop.errorCode = errorCode;
        stop.setDepartures([ [] ]);

        return stop;
    }

    // set

    function setDepartures(departures) {
        // don't put departure placeholders in placeholder stops
        if (!isPlaceholder()) {
            _departures = departures;
        }
    }

    function setDeparturesPlaceholder(errorCode, msg) {
        setDepartures(getDeparturesPlaceholder(errorCode, msg));
    }

    // get

    function equals(object) {
        return id == object.id;
    }

    function isPlaceholder() {
        return id == NO_ID;
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

    function hasDepartures() {
        return _departures.size() > 0 && _departures[0].size() > 0;
    }

    function getFirstDeparture() {
        Log.d("departures shape: (" + _departures.size() + ", " + (_departures.size() > 0 ? _departures[0].size() : "") + ")");
        return hasDepartures() ? _departures[0][0] : null;
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
            && (!hasDepartures() || getFirstDeparture().hasConnection());
    }

    function areStopsRerequestable() {
        return id == NO_ID
            && errorCode != null
            && errorCode != Communications.BLE_CONNECTION_UNAVAILABLE;
    }

    function areDeparturesRerequestable() {
        return hasDepartures() && getFirstDeparture().areDeparturesRerequestable();
    }

    // tools

    private function getDeparturesPlaceholder(errorCode, msg) {
        return [ [ Departure.placeholder(errorCode, msg) ] ];
    }

}
