import Toybox.Lang;

(:glance)
class Stop {

    public static const NO_ID = -1;

    public var id as Number;
    public var name as String;
    public var journeys as Array<Array> = [ [ Journey.placeholder("Searching departures ...") ] ];

    //

    function initialize(id as Number, name as String) as Void {
        self.id = id;
        self.name = name;
    }

    static function placeholder(name as String) as Stop {
        return new Stop(NO_ID, name);
    }

    //

    function equals(object as Any) as Boolean {
        if (object instanceof Stop) {
            return id == object.id;
        }
        return false;
    }

    function getModeCount() as Number {
        return journeys.size();
    }

    function toGlanceString() as String {
        // TODO: first of any mode
        var mode = 0;
        var string = name.toUpper() + "\n";

        for (var j = 0; j < 2 && j < journeys[mode].size(); j++) {
            string += journeys[mode][j].toString() + "\n";
        }

        return string;
    }

    function toDetailString(mode) as String {
        var string = "";

        for (var j = 0; j < 4 && j < journeys[mode].size(); j++) {
            string += journeys[mode][j].toString() + "\n";
        }

        return string;
    }

}
