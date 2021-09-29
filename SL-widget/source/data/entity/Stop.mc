
(:glance)
class Stop {

    public static const NO_ID = -1;

    public var id;
    public var name;
    public var journeys = [ [ Journey.placeholder("Searching departures ...") ] ];

    //

    function initialize(id, name) {
        self.id = id;
        self.name = name;
    }

    static function placeholder(name) {
        return new Stop(NO_ID, name);
    }

    //

    function equals(object) {
        return id == object.id;
    }

    function getModeCount() {
        return journeys.size();
    }

    function toGlanceString() {
        // TODO: first of any mode
        var mode = 0;
        var string = name.toUpper() + "\n";

        for (var j = 0; j < 2 && j < journeys[mode].size(); j++) {
            string += journeys[mode][j].toString() + "\n";
        }

        return string;
    }

    function toDetailString(mode) {
        var string = "";

        for (var j = 0; j < 4 && j < journeys[mode].size(); j++) {
            string += journeys[mode][j].toString() + "\n";
        }

        return string;
    }

}
