using Toybox.Math;
using Toybox.Time;
using Carbon.C14;
using Carbon.Graphene;

class Departure {

    hidden var _mode;
    hidden var _group;
    hidden var _line;
    hidden var _destination;
    hidden var _moment;
    hidden var _deviationLevel;

    // init

    function initialize(mode, group, line, destination, moment, deviationLevel) {
        _mode = mode;
        _group = group;
        _line = line;
        _destination = destination;
        _moment = moment;
        _deviationLevel = deviationLevel;
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
        if (_moment == null) {
            return false;
        }

        // we will keep displaying "now" until 30 seconds after departure
        var margin = new Time.Duration(30);
        return C14.now().greaterThan(_moment.add(margin));
    }

    function getDeviationColor() {
        if (_deviationLevel >= 8) {
            return Graphene.COLOR_RED;
        }
        else if (_deviationLevel >= 6) {
            return Graphene.COLOR_VERMILION;
        }
        else if (_deviationLevel >= 4) {
            return Graphene.COLOR_AMBER;
        }
        else if (_deviationLevel >= 1) {
            return Graphene.COLOR_YELLOW;
        }

        return AppColors.TEXT_PRIMARY;
    }

    function getModeColor() {
        if (_mode.equals("METRO")) {
            if (_group.equals("tunnelbanans röda linje")) {
                return Graphene.COLOR_DR_RED;
            }
            else if (_group.equals("tunnelbanans blå linje")) {
                return Graphene.COLOR_DR_BLUE;
            }
            else if (_group.equals("tunnelbanans gröna linje")) {
                return Graphene.COLOR_DR_GREEN;
            }
            else {
                Log.d("unknown metro group: " + _group);
                return Graphene.COLOR_DK_GRAY;
            }
        }
        else if (_mode.equals("BUS")) {
            if (_group.equals("")) {
                return Graphene.COLOR_RED;
            }
            else if (_group.equals("blåbuss")) {
                return Graphene.COLOR_BLUE;
            }
            else if (_group.equals("Ersättningsbuss")) {
                return Graphene.COLOR_VERMILION;
            }
            else {
                Log.d("unknown bus group: " + _group);
                return Graphene.COLOR_DK_GRAY;
            }
        }
        else if (_mode.equals("TRAIN")) {
            return Graphene.COLOR_MAGENTA;
        }
        else if (_mode.equals("TRAM")) {
            return Graphene.COLOR_AMBER;
        }
        else if (_mode.equals("SHIP")) {
            return Graphene.COLOR_CAPRI;
        }
        else if (_mode.equals("NONE")) {
            return Graphene.COLOR_BLACK;
        }
        else {
            Log.d("unknown mode: " + _mode);
            return Graphene.COLOR_DK_GRAY;
        }
    }

}
