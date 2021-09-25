using Carbon.Graphene;

(:glance)
class Journey {

    private static const _MODE_METRO = "METRO";
    private static const _MODE_BUS = "BUS";
    private static const _MODE_TRAIN = "TRAIN";
    private static const _MODE_TRAM = "TRAM";
    private static const _MODE_SHIP = "SHIP";

    private var _mode;
    private var _line;
    private var _destination;
    private var _direction;
    private var _displayTime;

    //

    function initialize(mode, line, destination, direction, displayTime) {
        self._mode = mode;
        self._line = line;
        self._destination = destination;
        self._direction = direction;
        self._displayTime = displayTime;
    }

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
            default: return Graphene.COLOR_LT_GRAY;
        }
    }

}
