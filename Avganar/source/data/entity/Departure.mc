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

    static private const _KEEP_DEPARTURE_AFTER_DEPARTED_SEC = 30;

    private var _modeKey as Number;
    private var _line as String;
    private var _destination as String;
    private var _moment as Moment?;

    // init

    function initialize(modeKey as Number, line as String, destination as String, moment as Moment?) {
        _modeKey = modeKey;
        _line = line;
        _destination = destination;
        _moment = moment;
    }

    // get

    function toString() as String {
        return _displayTime() + " "
            // skip some line numbers which are wrong anyway
            + (_line.length() >= 5 || _line.equals(".") ? "" : _line + " ")
            + _destination;
    }

    private function _displayTime() as String {
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

    function getModeColor() as ColorType {
        if (_modeKey == Mode.KEY_BUS_LOCAL) {
            return AppColors.MODE_BUS_LOCAL;
        }
        else if (_modeKey == Mode.KEY_BUS_EXPRESS) {
            return AppColors.MODE_BUS_EXPRESS;
        }
        else if (_modeKey == Mode.KEY_METRO) {
           return AppColors.MODE_METRO;
        }
        else if (_modeKey == Mode.KEY_TRAIN_LOCAL) {
            return AppColors.MODE_TRAIN_LOCAL;
        }
        else if (_modeKey == Mode.KEY_TRAIN_REGIONAL) {
            return AppColors.MODE_TRAIN_REGIONAL;
        }
        else if (_modeKey == Mode.KEY_TRAIN_EXPRESS) {
            return AppColors.MODE_TRAIN_EXPRESS;
        }
        else if (_modeKey == Mode.KEY_TRAM) {
            return AppColors.MODE_TRAM;
        }
        else if (_modeKey == Mode.KEY_SHIP) {
            return AppColors.MODE_SHIP;
        }

        return AppColors.MODE_OTHER;
    }

}
