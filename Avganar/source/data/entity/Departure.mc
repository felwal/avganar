using Toybox.Math;
using Toybox.Time;

class Departure {

    static hidden const _MODE_BUS_LOCAL = 7;
    static hidden const _MODE_BUS_EXPRESS = 3;
    static hidden const _MODE_METRO = 5;
    static hidden const _MODE_TRAIN_LOCAL = 4;
    static hidden const _MODE_TRAIN_REGIONAL = 2;
    static hidden const _MODE_TRAIN_EXPRESS = 1;
    static hidden const _MODE_TRAM = 6;
    static hidden const _MODE_SHIP = 8;

    hidden var _mode;
    hidden var _line;
    hidden var _destination;
    hidden var _moment;
    hidden var _deviationLevel;

    var cancelled;

    // init

    function initialize(mode, line, destination, moment, deviationLevel, cancelled) {
        _mode = mode;
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
        if (_mode == _MODE_BUS_LOCAL || _mode == _MODE_BUS_EXPRESS) {
            return "B";
        }
        else if (_mode == _MODE_METRO) {
            return "T";
        }
        else if (_mode == _MODE_TRAIN_LOCAL || _mode == _MODE_TRAIN_REGIONAL || _mode == _MODE_TRAIN_EXPRESS) {
            return "J";
        }
        else if (_mode == _MODE_TRAM) {
            return "L";
        }
        else if (_mode == _MODE_SHIP) {
            return "F";
        }
        else {
            Log.w("unknown mode: " + _mode);
            return "?";
        }
    }

    function getModeColor() {
        if (_mode == _MODE_BUS_LOCAL) {
            return AppColors.DEPARTURE_BUS_LOCAL;
        }
        else if (_mode == _MODE_BUS_EXPRESS) {
            return AppColors.DEPARTURE_BUS_EXPRESS;
        }
        else if (_mode == _MODE_METRO) {
           return AppColors.DEPARTURE_METRO;
        }
        else if (_mode == _MODE_TRAIN_LOCAL) {
            return AppColors.DEPARTURE_TRAIN_LOCAL;
        }
        else if (_mode == _MODE_TRAIN_REGIONAL) {
            return AppColors.DEPARTURE_TRAIN_REGIONAL;
        }
        else if (_mode == _MODE_TRAIN_EXPRESS) {
            return AppColors.DEPARTURE_TRAIN_EXPRESS;
        }
        else if (_mode == _MODE_TRAM) {
            return AppColors.DEPARTURE_TRAM;
        }
        else if (_mode == _MODE_SHIP) {
            return AppColors.DEPARTURE_SHIP;
        }
        else {
            Log.w("unknown mode: " + _mode);
            return AppColors.DEPARTURE_UNKNOWN;
        }
    }

}
