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

import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Time;

using Toybox.Math;

class Departure {

    static hidden const _GROUP_BUS_RED = "";
    static hidden const _GROUP_BUS_BLUE = "Blåbuss";
    static hidden const _GROUP_BUS_REPLACEMENT = "Ersättningsbuss";

    static hidden const _GROUP_METRO_RED = "Tunnelbanans röda linje";
    static hidden const _GROUP_METRO_BLUE = "Tunnelbanans blå linje";
    static hidden const _GROUP_METRO_GREEN = "Tunnelbanans gröna linje";

    static hidden const _GROUP_TRAM_SPARVAGCITY = "Spårväg City";
    static hidden const _GROUP_TRAM_NOCKEBYBANAN = "Nockebybanan";
    static hidden const _GROUP_TRAM_LIDINGOBANAN = "Lidingöbanan";
    static hidden const _GROUP_TRAM_TVARBANAN = "Tvärbanan";
    static hidden const _GROUP_TRAM_SALTSJOBANAN = "Saltsjöbanan";
    static hidden const _GROUP_TRAM_ROSLAGSBANAN = "Roslagsbanan";

    var cancelled as Boolean;
    var isRealTime as Boolean;

    hidden var _modeKey as String;
    hidden var _group as String;
    hidden var _line as String;
    hidden var _destination as String;
    hidden var _moment as Moment?;
    hidden var _deviationLevel as Number;
    hidden var _deviationMessages as Array<String> = [];

    // init

    function initialize(modeKey as String, group as String, line as String, destination as String,
        moment as Moment?, deviationLevel as Number, deviationMessages as Array<String>,
        cancelled as Boolean, isRealTime as Boolean) {

        me.cancelled = cancelled;
        me.isRealTime = isRealTime;

        _modeKey = modeKey;
        _group = group;
        _line = line;
        _destination = destination;
        _moment = moment;
        _deviationLevel = deviationLevel;
        _deviationMessages = deviationMessages;
    }

    // get

    function toString() as String {
        return displayTime() + " " + _line + " " + _destination;
    }

    function displayTime() as String {
        if (_moment == null) {
            return getString(Rez.Strings.itm_detail_departure_null);
        }

        var now = TimeUtil.now();
        var duration = now.subtract(_moment);
        var minutes = Math.round(duration.value() / 60.0).toNumber();

        // NOTE: `Moment#subtract` returns a positive value. we don't need to
        // negate it here, however, because the departure is removed in
        // `Stop#_removeDepartedDepartures` after 30 seconds, i.e. before it should be negative.

        return minutes == 0
            ? getString(Rez.Strings.itm_detail_departure_now)
            : (minutes + SettingsStorage.getMinuteSymbol());
    }

    function hasDeparted() as Boolean {
        if (_moment == null) {
            return false;
        }

        // we will keep displaying "now" until 30 seconds after departure
        var margin = new Time.Duration(30);
        return TimeUtil.now().greaterThan(_moment.add(margin));
    }

    function getTextColor() as ColorType {
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

    function getModeColor() as ColorType {
        if (_modeKey.equals(Mode.KEY_BUS)) {
            if (_group.equals(_GROUP_BUS_RED)) {
                return AppColors.MODE_BUS_RED;
            }
            else if (_group.equals(_GROUP_BUS_BLUE)) {
                return AppColors.MODE_BUS_BLUE;
            }
            else if (_group.equals(_GROUP_BUS_REPLACEMENT)) {
                return AppColors.MODE_BUS_REPLACEMENT;
            }
            else {
                return AppColors.MODE_UNKNOWN;
            }
        }
        else if (_modeKey.equals(Mode.KEY_METRO)) {
            if (_group.equals(_GROUP_METRO_RED)) {
                return AppColors.MODE_METRO_RED;
            }
            else if (_group.equals(_GROUP_METRO_BLUE)) {
                return AppColors.MODE_METRO_BLUE;
            }
            else if (_group.equals(_GROUP_METRO_GREEN)) {
                return AppColors.MODE_METRO_GREEN;
            }
            else {
                return AppColors.MODE_UNKNOWN;
            }
        }
        else if (_modeKey.equals(Mode.KEY_TRAIN)) {
            return AppColors.MODE_TRAIN;
        }
        else if (_modeKey.equals(Mode.KEY_TRAM)) {
            if (_group.equals(_GROUP_TRAM_SPARVAGCITY)) {
                return AppColors.MODE_TRAM_SPARVAGCITY;
            }
            else if (_group.equals(_GROUP_TRAM_NOCKEBYBANAN)) {
                return AppColors.MODE_TRAM_NOCKEBYBANAN;
            }
            else if (_group.equals(_GROUP_TRAM_LIDINGOBANAN)) {
                return AppColors.MODE_TRAM_LIDINGOBANAN;
            }
            else if (_group.equals(_GROUP_TRAM_TVARBANAN)) {
                return AppColors.MODE_TRAM_TVARBANAN;
            }
            else if (_group.equals(_GROUP_TRAM_SALTSJOBANAN)) {
                return AppColors.MODE_TRAM_SALTSJOBANAN;
            }
            else if (_group.equals(_GROUP_TRAM_ROSLAGSBANAN)) {
                return AppColors.MODE_TRAM_ROSLAGSBANAN;
            }
            else {
                return AppColors.MODE_UNKNOWN;
            }
        }
        else if (_modeKey.equals(Mode.KEY_SHIP)) {
            return AppColors.MODE_SHIP;
        }
        else if (_modeKey.equals(Mode.KEY_NONE)) {
            return AppColors.MODE_NONE;
        }
        else {
            return AppColors.MODE_UNKNOWN;
        }
    }

    function getDeviationMessages() as Array<String> {
        return _deviationMessages;
    }

}
