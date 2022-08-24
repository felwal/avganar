using Toybox.Time;
using Toybox.Math;
using Carbon.C14;

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
    private static const _GROUP_BUS_REPLACEMENT = "Ersättningsbuss";

    var hasDeviations = false;

    private var _mode;
    private var _group;
    private var _line;
    private var _destination;
    private var _direction;
    private var _moment;

    // init

    function initialize(mode, group, line, destination, direction, moment, hasDeviations) {
        _mode = mode;
        _group = group;
        _line = line;
        _destination = destination;
        _direction = direction;
        _moment = moment;
        self.hasDeviations = hasDeviations;
    }

    // get

    function toString() {
        return _displayTime() + " " + _line + " " + _destination;
    }

    private function _displayTime() {
        if (_moment == null) {
            return "-";
        }

        var now = C14.now();
        var duration = now.subtract(_moment);
        var minutes = Math.round(duration.value() / 60.0).toNumber();

        // NOTE: `Moment#subtract` returns a positive value. we don't need to
        // negate it here, however, because the departure is removed in
        // `Stop#_removeDepartedDepartures` after 30 seconds, i.e. before it should be negative.

        return minutes == 0 ? "Nu" : (minutes + " min");
    }

    function hasDeparted() {
        // we will keep displayig "now" until 30 seconds after departure
        var margin = new Time.Duration(30);
        return C14.now().greaterThan(_moment.add(margin));
    }

    function getColor() {
        switch (_mode) {
            case _MODE_METRO:
                switch (_group) {
                    case _GROUP_METRO_RED: return Color.DEPARTURE_METRO_RED;
                    case _GROUP_METRO_BLUE: return Color.DEPARTURE_METRO_BLUE;
                    case _GROUP_METRO_GREEN: return Color.DEPARTURE_METRO_GREEN;
                    default:
                        Log.d("unknown metro group: " + _group);
                        return Color.DEPARTURE_UNKNOWN;
                }

            case _MODE_BUS:
                switch (_group) {
                    case _GROUP_BUS_RED: return Color.DEPARTURE_BUS_RED;
                    case _GROUP_BUS_BLUE: return Color.DEPARTURE_BUS_BLUE;
                    case _GROUP_BUS_REPLACEMENT: return Color.DEPARTURE_BUS_REPLACEMENT;
                    default:
                        Log.d("unknown bus group: " + _group);
                        return Color.DEPARTURE_UNKNOWN;
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
                Log.d("unknown mode: " + _mode);
                return Color.DEPARTURE_UNKNOWN;
        }
    }

}
