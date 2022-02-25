using Toybox.Communications;
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

    var errorCode = null;

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

    static function placeholder(errorCode, msg) {
        var departure = new Departure(_MODE_NONE, "", "", "", "", msg);
        departure.errorCode = errorCode;
        return departure;
    }

    // get

    function toString() {
        return _displayTime + " " + _line + " " + _destination;
    }

    function getColor() {
        switch (_mode) {
            case _MODE_METRO:
                switch (_group) {
                    case _GROUP_METRO_RED: return Color.DEPARTURE_METRO_RED;
                    case _GROUP_METRO_BLUE: return Color.DEPARTURE_METRO_BLUE;
                    case _GROUP_METRO_GREEN: return Color.DEPARTURE_METRO_GREEN;
                    default: return Color.DEPARTURE_UNKNOWN;
                }

            case _MODE_BUS:
                switch (_group) {
                    case _GROUP_BUS_RED: return Color.DEPARTURE_BUS_RED;
                    case _GROUP_BUS_BLUE: return Color.DEPARTURE_BUS_BLUE;
                    default: return Color.DEPARTURE_UNKNOWN;
                }

            case _MODE_TRAIN:
                return Color.DEPARTURE_TRAIN;

            case _MODE_TRAM:
                return Color.DEPARTURE_TRAM;

            case _MODE_SHIP:
                return Color.DEPARTURE_SHIP;

            case _MODE_NONE:
                return Color.DEPARTURE_NONE;

            default:
                return Color.DEPARTURE_UNKNOWN;
        }
    }

    function hasConnection() {
        return errorCode != Communications.BLE_CONNECTION_UNAVAILABLE
            && errorCode != Communications.NETWORK_REQUEST_TIMED_OUT;
    }

    function areDeparturesRerequestable() {
        return _mode == _MODE_NONE
            && errorCode != null
            && errorCode != Communications.BLE_CONNECTION_UNAVAILABLE;
    }

}
