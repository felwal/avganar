using Toybox.Lang;

(:glance)
class Stop {

    public static const NO_ID = -1;

    public var id = NO_ID;
    public var name;
    private var _departures = [ [ Departure.placeholder(rez(Rez.Strings.lbl_i_departures_searching)) ] ];

    // init

    function initialize(id, name) {
        self.id = id;
        self.name = name;
    }

    static function placeholder(name) {
        return new Stop(NO_ID, name);
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

    function toGlanceString() {
        // TODO: first of any mode
        var mode = 0;
        var string = name.toUpper() + "\n";

        for (var d = 0; d < 2 && d < _departures[mode].size(); d++) {
            string += _departures[mode][d].toString() + "\n";
        }

        return string;
    }

    function toDetailString(mode) {
        var string = "";

        for (var d = 0; d < 4 && d < _departures[mode].size(); d++) {
            string += _departures[mode][d].toString() + "\n";
        }

        return string;
    }

    function hasConnection() {
        return !name.equals(rez(Rez.Strings.lbl_e_connection)) && _departures[0][0].hasConnection();
    }

}
