using Carbon.Graphene;

(:glance)
class Departure {

    private static const _MODE_METRO = "METRO";
    private static const _MODE_BUS = "BUS";
    private static const _MODE_TRAIN = "TRAIN";
    private static const _MODE_TRAM = "TRAM";
    private static const _MODE_SHIP = "SHIP";
    private static const _MODE_NONE = "NONE";

    private static const _GROUP_METRO_RED = "tunnelbanans röda linje";
    private static const _GROUP_METRO_BLUE = "tunnelbanans blå linje";
    private static const _GROUP_METRO_GREEN = "tunnelbanans gröna linje";
    private static const _GROUP_BUS_RED = "";
    private static const _GROUP_BUS_BLUE = "blåbuss";

    private var _mode;
    private var _group;
    private var _line;
    private var _destination;
    private var _direction;
    private var _displayTime;

    // init

    function initialize(mode, group, line, destination, direction, displayTime) {
        _mode = mode;
        _group = group;
        _line = line;
        _destination = destination;
        _direction = direction;
        _displayTime = displayTime;
    }

    static function placeholder(msg) {
        return new Departure(_MODE_NONE, "", "", "", "", msg);
    }

    // get

    function toString() {
        return _displayTime + " " + _line + " " + _destination;
    }

    function getColor() {
        switch (_mode) {
            case _MODE_METRO:
                switch (_group) {
                    case _GROUP_METRO_RED: return Graphene.COLOR_DK_RED;
                    case _GROUP_METRO_BLUE: return Graphene.COLOR_CERULIAN;
                    case _GROUP_METRO_GREEN: return Graphene.COLOR_DK_GREEN;
                    default: return Graphene.COLOR_LT_GRAY;
                }

            case _MODE_BUS:
                switch (_group) {
                    case _GROUP_BUS_RED: return Graphene.COLOR_RED;
                    case _GROUP_BUS_BLUE: return Graphene.COLOR_LT_AZURE;
                    default: return Graphene.COLOR_LT_GRAY;
                }

            case _MODE_TRAIN:
                var lastChar = _line.substring(_line.length() - 1, _line.length());
                if (lastChar.equals("X")) {
                    return Graphene.COLOR_PURPLE;
                }
                return Graphene.COLOR_MAGENTA;

            case _MODE_TRAM:
                return Graphene.COLOR_AMBER;

            case _MODE_SHIP:
                return Graphene.COLOR_CAPRI;

            case _MODE_NONE:
                return Graphene.COLOR_BLACK;

            default:
                return Graphene.COLOR_LT_GRAY;
        }
    }

    function hasConnection() {
        return !_displayTime.equals(rez(Rez.Strings.lbl_e_connection));
    }

}
