using Toybox.Math;
using Toybox.Time;

class Departure {

    static hidden const _MODE_BUS = "BUS";
    static hidden const _MODE_METRO = "METRO";
    static hidden const _MODE_TRAIN = "TRAIN";
    static hidden const _MODE_TRAM = "TRAM";
    static hidden const _MODE_SHIP = "SHIP";
    static hidden const _MODE_NONE = "NONE";

    static hidden const _GROUP_BUS_RED = "";
    static hidden const _GROUP_BUS_BLUE = "blåbuss";
    static hidden const _GROUP_BUS_REPLACEMENT = "Ersättningsbuss";

    static hidden const _GROUP_METRO_RED = "tunnelbanans röda linje";
    static hidden const _GROUP_METRO_BLUE = "tunnelbanans blå linje";
    static hidden const _GROUP_METRO_GREEN = "tunnelbanans gröna linje";

    static hidden const _GROUP_TRAM_SPÅRVÄGCITY = "Spårväg City";
    static hidden const _GROUP_TRAM_NOCKEBYBANAN = "Nockebybanan";
    static hidden const _GROUP_TRAM_LIDINGÖBANAN = "Lidingöbanan";
    static hidden const _GROUP_TRAM_TVÄRBANAN = "Tvärbanan";
    static hidden const _GROUP_TRAM_SALTSJÖBANAN = "Saltsjöbanan";
    static hidden const _GROUP_TRAM_ROSLAGSBANAN = "Roslagsbanan";

    hidden var _mode;
    hidden var _group;
    hidden var _line;
    hidden var _destination;
    hidden var _moment;
    hidden var _deviationLevel;

    var cancelled;

    // init

    function initialize(mode, group, line, destination, moment, deviationLevel, cancelled) {
        _mode = mode;
        _group = group;
        _line = line;
        _destination = destination;
        _moment = moment;
        _deviationLevel = deviationLevel;
        me.cancelled = cancelled;
    }

    // get

    function toString() {
        return _displayTime() + " " + _line + " " + _destination;
    }

    hidden function _displayTime() {
        if (_moment == null) {
            return rez(Rez.Strings.itm_detail_departure_null);
        }

        var now = TimeUtil.now();
        var duration = now.subtract(_moment);
        var minutes = Math.round(duration.value() / 60.0).toNumber();

        // NOTE: `Moment#subtract` returns a positive value. we don't need to
        // negate it here, however, because the departure is removed in
        // `Stop#_removeDepartedDepartures` after 30 seconds, i.e. before it should be negative.

        return minutes == 0
            ? rez(Rez.Strings.itm_detail_departure_now)
            : (minutes + SettingsStorage.getMinuteSymbol());
    }

    function hasDeparted() {
        if (_moment == null) {
            return false;
        }

        // we will keep displaying "now" until 30 seconds after departure
        var margin = new Time.Duration(30);
        return TimeUtil.now().greaterThan(_moment.add(margin));
    }

    function getTextColor() {
        if (_deviationLevel >= 8) {
            return Graphene.COLOR_RED;
        }
        else if (_deviationLevel >= 6) {
            return Graphene.COLOR_VERMILION;
        }
        else if (_deviationLevel >= 4) {
            return Graphene.COLOR_AMBER;
        }
        else if (_deviationLevel >= 3) {
            return Graphene.COLOR_YELLOW;
        }
        else if (_deviationLevel >= 2) {
            return Graphene.COLOR_LT_YELLOW;
        }
        else if (_deviationLevel >= 1) {
            return Graphene.COLOR_LR_YELLOW;
        }

        return AppColors.TEXT_PRIMARY;
    }

    function getModeSymbol() {
        if (_mode.equals(_MODE_BUS)) {
            return "B";
        }
        else if (_mode.equals(_MODE_METRO)) {
            return "T";
        }
        else if (_mode.equals(_MODE_TRAIN)) {
            return "J";
        }
        else if (_mode.equals(_MODE_TRAM)) {
            return "L";
        }
        else if (_mode.equals(_MODE_SHIP)) {
            return "F";
        }
        else {
            Log.w("unknown mode: " + _mode);
            return "?";
        }
    }

    function getModeColor() {
        if (_mode.equals(_MODE_BUS)) {
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
                Log.w("unknown bus group: " + _group);
                return AppColors.DEPARTURE_UNKNOWN;
            }
        }
        else if (_mode.equals(_MODE_METRO)) {
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
                Log.w("unknown metro group: " + _group);
                return AppColors.DEPARTURE_UNKNOWN;
            }
        }
        else if (_mode.equals(_MODE_TRAIN)) {
            return AppColors.DEPARTURE_TRAIN;
        }
        else if (_mode.equals(_MODE_TRAM)) {
            if (_group.equals(_GROUP_TRAM_SPÅRVÄGCITY)) {
                return AppColors.DEPARTURE_TRAM_SPÅRVÄGCITY;
            }
            else if (_group.equals(_GROUP_TRAM_NOCKEBYBANAN)) {
                return AppColors.DEPARTURE_TRAM_NOCKEBYBANAN;
            }
            else if (_group.equals(_GROUP_TRAM_LIDINGÖBANAN)) {
                return AppColors.DEPARTURE_TRAM_LIDINGÖBANAN;
            }
            else if (_group.equals(_GROUP_TRAM_TVÄRBANAN)) {
                return AppColors.DEPARTURE_TRAM_TVÄRBANAN;
            }
            else if (_group.equals(_GROUP_TRAM_SALTSJÖBANAN)) {
                return AppColors.DEPARTURE_TRAM_SALTSJÖBANAN;
            }
            else if (_group.equals(_GROUP_TRAM_ROSLAGSBANAN)) {
                return AppColors.DEPARTURE_TRAM_ROSLAGSBANAN;
            }
            else {
                Log.w("unknown tram group: " + _group);
                return AppColors.DEPARTURE_UNKNOWN;
            }
        }
        else if (_mode.equals(_MODE_SHIP)) {
            return AppColors.DEPARTURE_SHIP;
        }
        else if (_mode.equals(_MODE_NONE)) {
            return AppColors.DEPARTURE_NONE;
        }
        else {
            Log.w("unknown mode: " + _mode);
            return AppColors.DEPARTURE_UNKNOWN;
        }
    }

}
