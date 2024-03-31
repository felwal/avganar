// This file is part of Avgånär.
//
// Avgånär is free software: you can redistribute it and/or modify it under the terms of
// the GNU General Public License as published by the Free Software Foundation,
// either version 3 of the License, or (at your option) any later version.
//
// Avgånär is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
// without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with Avgånär.
// If not, see <https://www.gnu.org/licenses/>.

using Toybox.Math;
using Toybox.Time;

class Departure {

    static const BIT_BUS = 8;
    static const BIT_METRO = 2;
    static const BIT_TRAIN = 1;
    static const BIT_TRAM = 4;
    static const BIT_SHIP = 64;

    static const MODE_BUS = "BUS";
    static const MODE_METRO = "METRO";
    static const MODE_TRAIN = "TRAIN";
    static const MODE_TRAM = "TRAM";
    static const MODE_SHIP = "SHIP";
    static const MODE_NONE = "NONE";

    static const MODE_TO_BIT = {
        MODE_BUS => BIT_BUS,
        MODE_METRO => BIT_METRO,
        MODE_TRAIN => BIT_TRAIN,
        MODE_TRAM => BIT_TRAM,
        MODE_SHIP => BIT_SHIP,
    };

    static hidden const _GROUP_BUS_RED = "";
    static hidden const _GROUP_BUS_BLUE = "Blåbuss";
    static hidden const _GROUP_BUS_REPLACEMENT = "Ersättningsbuss";

    static hidden const _GROUP_METRO_RED = "Tunnelbanans röda linje";
    static hidden const _GROUP_METRO_BLUE = "Tunnelbanans blå linje";
    static hidden const _GROUP_METRO_GREEN = "Tunnelbanans gröna linje";

    static hidden const _GROUP_TRAM_SPÅRVÄGCITY = "Spårväg City";
    static hidden const _GROUP_TRAM_NOCKEBYBANAN = "Nockebybanan";
    static hidden const _GROUP_TRAM_LIDINGÖBANAN = "Lidingöbanan";
    static hidden const _GROUP_TRAM_TVÄRBANAN = "Tvärbanan";
    static hidden const _GROUP_TRAM_SALTSJÖBANAN = "Saltsjöbanan";
    static hidden const _GROUP_TRAM_ROSLAGSBANAN = "Roslagsbanan";

    var mode;
    hidden var _group;
    hidden var _line;
    hidden var _destination;
    hidden var _moment;
    hidden var _deviationLevel;
    hidden var _deviationMessages = [];

    var cancelled;
    var isRealTime;

    // init

    function initialize(mode, group, line, destination, moment, deviationLevel, deviationMessages,
        cancelled, isRealTime) {

        me.mode = mode;
        _group = group;
        _line = line;
        _destination = destination;
        _moment = moment;
        _deviationLevel = deviationLevel;
        _deviationMessages = deviationMessages;

        me.cancelled = cancelled;
        me.isRealTime = isRealTime;
    }

    static function getModesKeysByBits(bits) {
        var modes = [];

        if (bits&BIT_BUS != 0) {
            modes.add(MODE_BUS);
        }
        if (bits&BIT_METRO != 0) {
            modes.add(MODE_METRO);
        }
        if (bits&BIT_TRAIN != 0) {
            modes.add(MODE_TRAIN);
        }
        if (bits&BIT_TRAM != 0) {
            modes.add(MODE_TRAM);
        }
        if (bits&BIT_SHIP != 0) {
            modes.add(MODE_SHIP);
        }

        return modes;
    }

    static function getModesStringsByBits(bits) {
        var modes = [];

        if (bits&BIT_BUS != 0) {
            modes.add(rez(Rez.Strings.itm_modes_bus));
        }
        if (bits&BIT_METRO != 0) {
            modes.add(rez(Rez.Strings.itm_modes_metro));
        }
        if (bits&BIT_TRAIN != 0) {
            modes.add(rez(Rez.Strings.itm_modes_train));
        }
        if (bits&BIT_TRAM != 0) {
            modes.add(rez(Rez.Strings.itm_modes_tram));
        }
        if (bits&BIT_SHIP != 0) {
            modes.add(rez(Rez.Strings.itm_modes_ship));
        }

        return modes;
    }

    // get

    function toString() {
        return displayTime() + " " + _line + " " + _destination;
    }

    function displayTime() {
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

    function getModeLetter() {
        if (mode.equals(MODE_BUS)) {
            return rez(Rez.Strings.lbl_detail_mode_letter_bus);
        }
        else if (mode.equals(MODE_METRO)) {
            return rez(Rez.Strings.lbl_detail_mode_letter_metro);
        }
        else if (mode.equals(MODE_TRAIN)) {
            return rez(Rez.Strings.lbl_detail_mode_letter_train);
        }
        else if (mode.equals(MODE_TRAM)) {
            return rez(Rez.Strings.lbl_detail_mode_letter_tram);
        }
        else if (mode.equals(MODE_SHIP)) {
            return rez(Rez.Strings.lbl_detail_mode_letter_ship);
        }
        else {
            return rez(Rez.Strings.lbl_detail_mode_letter_unknown);
        }
    }

    function getModeColor() {
        if (mode.equals(MODE_BUS)) {
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
                return AppColors.DEPARTURE_UNKNOWN;
            }
        }
        else if (mode.equals(MODE_METRO)) {
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
                return AppColors.DEPARTURE_UNKNOWN;
            }
        }
        else if (mode.equals(MODE_TRAIN)) {
            return AppColors.DEPARTURE_TRAIN;
        }
        else if (mode.equals(MODE_TRAM)) {
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
                return AppColors.DEPARTURE_UNKNOWN;
            }
        }
        else if (mode.equals(MODE_SHIP)) {
            return AppColors.DEPARTURE_SHIP;
        }
        else if (mode.equals(MODE_NONE)) {
            return AppColors.DEPARTURE_NONE;
        }
        else {
            return AppColors.DEPARTURE_UNKNOWN;
        }
    }

    function getDeviationMessages() {
        return _deviationMessages;
    }

}
