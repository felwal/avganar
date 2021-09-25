
(:glance)
class Stop {

    public static const NO_ID = -1;

    public var id;
    public var name;
    public var journeys = [];

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

    function toGlanceString() {
        var string = name.toUpper() + "\n";
        for (var j = 0; j < 2 && j < journeys.size(); j++) {
            string += journeys[j].toString() + "\n";
        }
        return string;
    }

    function toDetailString() {
        var string = "";
        for (var j = 0; j < 4 && j < journeys.size(); j++) {
            string += journeys[j].toString() + "\n";
        }
        return string;
    }

}
