using Carbon.Graphene;

(:glance)
class Departure {

    private static const _MODE_METRO = "METRO";
    private static const _MODE_BUS = "BUS";
    private static const _MODE_TRAIN = "TRAIN";
    private static const _MODE_TRAM = "TRAM";
    private static const _MODE_SHIP = "SHIP";
    private static const _MODE_NONE = "NONE";

    private var _mode;
    private var _line;
    private var _destination;
    private var _direction;
    private var _displayTime;

    // init

    function initialize(mode, line, destination, direction, displayTime) {
        _mode = mode;
        _line = line;
        _destination = destination;
        _direction = direction;
        _displayTime = displayTime;

    }

    static function placeholder(msg) {
        return new Departure(_MODE_NONE, "", "", "", msg);
    }

    // get

    function toString() {
        return _displayTime + " " + _line + " " + _destination;
    }

    function getColor() {
        switch (_mode) {
            case _MODE_METRO: return Graphene.COLOR_DK_GREEN;
            case _MODE_BUS: return Graphene.COLOR_RED;
            case _MODE_TRAIN: return Graphene.COLOR_MAGENTA;
            case _MODE_TRAM: return Graphene.COLOR_AMBER;
            case _MODE_SHIP: return Graphene.COLOR_CAPRI;
            case _MODE_NONE: return Graphene.COLOR_BLACK;
            default: return Graphene.COLOR_LT_GRAY;
        }
    }

}
