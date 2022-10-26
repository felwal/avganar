using Toybox.Math;
using Toybox.Time;
using Carbon.C14;

class Departure {

    static hidden const _MODE_METRO = "METRO";
    static hidden const _MODE_BUS = "BUS";
    static hidden const _MODE_TRAIN = "TRAIN";
    static hidden const _MODE_TRAM = "TRAM";
    static hidden const _MODE_SHIP = "SHIP";
    static hidden const _MODE_NONE = "NONE";

    static hidden const _GROUP_METRO_RED = "tunnelbanans röda linje";
    static hidden const _GROUP_METRO_BLUE = "tunnelbanans blå linje";
    static hidden const _GROUP_METRO_GREEN = "tunnelbanans gröna linje";
    static hidden const _GROUP_BUS_RED = "";
    static hidden const _GROUP_BUS_BLUE = "blåbuss";
    static hidden const _GROUP_BUS_REPLACEMENT = "Ersättningsbuss";

    var hasDeviations = false;

    hidden var _mode;
    hidden var _group;
    hidden var _line;
    hidden var _destination;
    hidden var _direction;
    hidden var _moment;

    // init

    function initialize(mode, group, line, destination, direction, moment, hasDeviations) {
        _mode = mode;
        _group = group;
        _line = line;
        _destination = destination;
        _direction = direction;
        _moment = moment;
        me.hasDeviations = hasDeviations;
    }

    // get

    function toString() {
        return _displayTime() + " " + _line + " " + _destination;
    }

    hidden function _displayTime() {
        if (_moment == null) {
            return "-";
        }

        var now = C14.now();
        var duration = now.subtract(_moment);
        var minutes = Math.round(duration.value() / 60.0).toNumber();

        // NOTE: `Moment#subtract` returns a positive value. we don't need to
        // negate it here, however, because the departure is removed in
        // `Stop#_removeDepartedDepartures` after 30 seconds, i.e. before it should be negative.

        return minutes == 0
            ? rez(Rez.Strings.lbl_detail_now)
            : (minutes + rez(Rez.Strings.lbl_detail_minutes));
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
