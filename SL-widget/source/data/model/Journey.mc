using Carbon.Graphene;

(:glance)
class Journey {

    public var mode;
    public var line;
    public var destination;
    public var direction;
    public var displayTime;

    function initialize(mode, line, destination, direction, displayTime) {
        self.mode = mode;
        self.line = line;
        self.destination = destination;
        self.direction = direction;
        self.displayTime = displayTime;
    }

    function print() {
        return displayTime + " " + line + " " + destination;
    }

    function getColor() {
        switch (mode) {
            case "METRO": return Graphene.COLOR_VERMILION;
            case "BUS": return Graphene.COLOR_RED;
            case "TRAIN": return Graphene.COLOR_MAGENTA;
            case "TRAM": return Graphene.COLOR_CAPRI;
            case "SHIP": return Graphene.COLOR_CYAN;
            default: return Graphene.COLOR_LT_GRAY;
        }
    }

}
