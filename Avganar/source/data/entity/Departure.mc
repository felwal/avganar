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

    static private const _GROUP_BUS_RED = "";
    static private const _GROUP_BUS_BLUE = "Blåbuss";
    static private const _GROUP_BUS_REPLACEMENT = "Ersättningsbuss";

    static private const _GROUP_METRO_RED = "Tunnelbanans röda linje";
    static private const _GROUP_METRO_BLUE = "Tunnelbanans blå linje";
    static private const _GROUP_METRO_GREEN = "Tunnelbanans gröna linje";

    static private const _GROUP_TRAM_SPARVAGCITY = "Spårväg City";
    static private const _GROUP_TRAM_NOCKEBYBANAN = "Nockebybanan";
    static private const _GROUP_TRAM_LIDINGOBANAN = "Lidingöbanan";
    static private const _GROUP_TRAM_TVARBANAN = "Tvärbanan";
    static private const _GROUP_TRAM_SALTSJOBANAN = "Saltsjöbanan";
    static private const _GROUP_TRAM_ROSLAGSBANAN = "Roslagsbanan";

    static private const _KEEP_DEPARTURE_AFTER_DEPARTED_SEC = 30;

    var cancelled as Boolean;
    var isRealTime as Boolean;

    private var _modeKey as String;
    private var _group as String;
    private var _line as String;
    private var _destination as String;
    private var _moment as Moment?;
    private var _deviationLevel as Number;
    private var _deviationMessages as Array<String> = [];

    // init

    function initialize(modeKey as String, group as String, line as String, destination as String,
        moment as Moment?, deviation as DepartureDeviation, isRealTime as Boolean) {

        me.cancelled = deviation[2];
        me.isRealTime = isRealTime;

        _modeKey = modeKey;
        _group = group;
        _line = line;
        _destination = destination;
        _moment = moment;
        _deviationLevel = deviation[0];
        _deviationMessages = deviation[1];
    }

    // get

    function toString() as String {
        return displayTime() + " " + _line + " " + _destination;
    }

    function displayTime() as String {
        if (_moment == null) {
            return getString(Rez.Strings.itm_detail_departure_time_null);
        }

        // since we keep the departure a bit after it has departed,
        // we need handle a negative time diff
        var seconds = MathUtil.max(0, _moment.value() - Time.now().value());
        var minutes = Math.round(seconds / 60.0).toNumber();

        return minutes <= 0
            ? getString(Rez.Strings.itm_detail_departure_time_now)
            : (minutes + SettingsStorage.getMinuteSymbol());
    }

    function hasDeparted() as Boolean {
        if (_moment == null) {
            return false;
        }

        // keep displaying "now" a bit after it has departed
        var margin = new Time.Duration(_KEEP_DEPARTURE_AFTER_DEPARTED_SEC);
        return Time.now().greaterThan(_moment.add(margin));
    }

    function getDeviationColor() as ColorType {
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
        }
        else if (_modeKey.equals(Mode.KEY_SHIP)) {
            return AppColors.MODE_SHIP;
        }

        return AppColors.MODE_OTHER;
    }

    function getDeviationMessages() as Array<String> {
        return _deviationMessages;
    }

}
