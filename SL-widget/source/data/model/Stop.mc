
(:glance)
class Stop {

    public var id;
    public var name;
    public var journeys = [];

    function initialize(id, name) {
        self.id = id;
        self.name = name;
    }

    function equals(stop) {
        return id == stop.id;
    }

    function printForGlance() {
        var string = name.toUpper() + "\n";
        for (var j = 0; j < 2 && j < journeys.size(); j++) {
            string += journeys[j].print() + "\n";
        }
        return string;
    }

    function printForView() {
        var string = "";
        for (var j = 0; j < 4 && j < journeys.size(); j++) {
            string += journeys[j].print() + "\n";
        }
        return string;
    }

}
