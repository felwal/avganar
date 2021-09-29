using Toybox.Lang;
using Toybox.Application;

(:glance)
class Stop {

    public static const NO_ID = -1;

    public var id = NO_ID;
    public var name;
    private var _journeys = [ [ Journey.placeholder(Application.loadResource(Rez.Strings.lbl_i_departures_searching)) ] ];

    //

    function initialize(id, name) {
        self.id = id;
        self.name = name;
    }

    static function placeholder(name) {
        return new Stop(NO_ID, name);
    }

    //

    function setJourneys(journeys) {
        // don't put journey placeholders in placeholder stops
        if (id != NO_ID) {
            _journeys = journeys;
        }
    }

    //

    function equals(object) {
        return id == object.id;
    }

    function getModeCount() {
        return _journeys.size();
    }

    function getJourneyCount(mode) {
        if (mode < 0 || mode >= _journeys.size()) {
            Log.w("getJourneyCount 'mode' (" + mode + ") out of range [0," + _journeys.size() + "]; returning 0");
            return 0;
        }
        else if (!(_journeys[mode] instanceof Lang.Array)) {
            Log.w("journeys[" + mode + "] (not Array): " + _journeys[mode] + "; returning 0");
            return 0;
        }
        return _journeys[mode].size();
    }

    function getJourneys(mode) {
        if (mode >= 0 && mode < _journeys.size()) {
            return _journeys[mode];
        }
        else {
            Log.w("getJourneys 'mode' (" + mode + ") out of range [0," + _journeys.size() + "]; returning []");
            return [];
        }
    }

    function getAllJourneys() {
        return _journeys;
    }

    function toGlanceString() {
        // TODO: first of any mode
        var mode = 0;
        var string = name.toUpper() + "\n";

        for (var j = 0; j < 2 && j < _journeys[mode].size(); j++) {
            string += _journeys[mode][j].toString() + "\n";
        }

        return string;
    }

    function toDetailString(mode) {
        var string = "";

        for (var j = 0; j < 4 && j < _journeys[mode].size(); j++) {
            string += _journeys[mode][j].toString() + "\n";
        }

        return string;
    }

}
