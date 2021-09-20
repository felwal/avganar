using Carbon.Graphene;

(:glance)
class Journey {

    private static const _MODE_METRO = "METRO";
    private static const _MODE_BUS = "BUS";
    private static const _MODE_TRAIN = "TRAIN";
    private static const _MODE_TRAM = "TRAM";
    private static const _MODE_SHIP = "SHIP";

    public var mode;
    public var line;
    public var destination;
    public var direction;
    public var displayTime;

    //

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
            case _MODE_METRO: return Graphene.COLOR_DK_GREEN;
            case _MODE_BUS: return Graphene.COLOR_RED;
            case _MODE_TRAIN: return Graphene.COLOR_MAGENTA;
            case _MODE_TRAM: return Graphene.COLOR_AMBER;
            case _MODE_SHIP: return Graphene.COLOR_CAPRI;
            default: return Graphene.COLOR_LT_GRAY;
        }
    }

}
