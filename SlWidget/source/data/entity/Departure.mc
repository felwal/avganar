using Toybox.Time;
using Toybox.Math;
using Carbon.C14;

class Departure {

    static private const _MODE_METRO = "METRO";
    static private const _MODE_BUS = "BUS";
    static private const _MODE_TRAIN = "TRAIN";
    static private const _MODE_TRAM = "TRAM";
    static private const _MODE_SHIP = "SHIP";
    static private const _MODE_NONE = "NONE";

    static private const _GROUP_METRO_RED = "tunnelbanans röda linje";
    static private const _GROUP_METRO_BLUE = "tunnelbanans blå linje";
    static private const _GROUP_METRO_GREEN = "tunnelbanans gröna linje";
    static private const _GROUP_BUS_RED = "";
    static private const _GROUP_BUS_BLUE = "blåbuss";
    static private const _GROUP_BUS_REPLACEMENT = "Ersättningsbuss";

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

        return minutes == 0 ? "Nu" : (minutes + "'");
    }

    function hasDeparted() {
        // we will keep displayig "now" until 30 seconds after departure
        var margin = new Time.Duration(30);
        return C14.now().greaterThan(_moment.add(margin));
    }

    function getColor() {
        if (_mode.equals(_MODE_METRO)) {
            if (_group.equals(_GROUP_METRO_RED)) {
                return AppColors.DEPARTURE_METRO_RED;
            }
            else if (_group.equals(_GROUP_METRO_BLUE)) {
                return AppColors.DEPARTURE_METRO_BLUE;
            }
            else if (_group.equals(_GROUP_METRO_GREEN)) {
                return AppColors.DEPARTURE_METRO_GREEN;
            }
            else {
                Log.d("unknown metro group: " + _group);
                return AppColors.DEPARTURE_UNKNOWN;
            }
        }
        else if (_mode.equals(_MODE_BUS)) {
            if (_group.equals(_GROUP_BUS_RED)) {
                return AppColors.DEPARTURE_BUS_RED;
            }
            else if (_group.equals(_GROUP_BUS_BLUE)) {
                return AppColors.DEPARTURE_BUS_BLUE;
            }
            else if (_group.equals(_GROUP_BUS_REPLACEMENT)) {
                return AppColors.DEPARTURE_BUS_REPLACEMENT;
            }
            else {
                Log.d("unknown bus group: " + _group);
                return AppColors.DEPARTURE_UNKNOWN;
            }
        }
        else if (_mode.equals(_MODE_TRAIN)) {
            return AppColors.DEPARTURE_TRAIN;
        }
        else if (_mode.equals(_MODE_TRAM)) {
            return AppColors.DEPARTURE_TRAM;
        }
        else if (_mode.equals(_MODE_SHIP)) {
            return AppColors.DEPARTURE_SHIP;
        }
        else if (_mode.equals(_MODE_NONE)) {
            return AppColors.DEPARTURE_NONE;
        }
        else {
            Log.d("unknown mode: " + _mode);
            return AppColors.DEPARTURE_UNKNOWN;
        }
    }

}
