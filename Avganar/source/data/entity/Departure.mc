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

    static private const _GROUP_BUS_LOCAL_LOCAL = "BLT";

    static private const _GROUP_BUS_EXPRESS_EXPRESS = "BXB";
    static private const _GROUP_BUS_EXPRESS_AIRPORT = "BAX";

    static private const _GROUP_TRAIN_LOCAL_LOCAL = "JLT";
    static private const _GROUP_TRAIN_LOCAL_PAGA = "JPT";

    static private const _GROUP_TRAIN_REGIONAL_REGIONAL = "JRE";
    static private const _GROUP_TRAIN_REGIONAL_INTERCITY = "JIC";
    static private const _GROUP_TRAIN_REGIONAL_NATTAG = "JNT";

    static private const _GROUP_TRAIN_EXPRESS_EXPRESS = "JEX";
    static private const _GROUP_TRAIN_EXPRESS_SNABBTAG = "JST";
    static private const _GROUP_TRAIN_EXPRESS_AIRPORT = "JAX";

    static private const _GROUP_SHIP_LOCAL = "FLT";
    static private const _GROUP_SHIP_INTERNATIONAL = "FUT";

    static private const _KEEP_DEPARTURE_AFTER_DEPARTED_SEC = 30;

    var isRealTime as Boolean;

    private var _modeKey as Number;
    private var _group as String;
    private var _line as String;
    private var _destination as String;
    private var _moment as Moment?;

    // init

    function initialize(modeKey as Number, group as String, line as String, destination as String,
        moment as Moment?, isRealTime as Boolean) {

        me.isRealTime = isRealTime;

        _modeKey = modeKey;
        _group = group;
        _line = line;
        _destination = destination;
        _moment = moment;
    }

    // get

    function toString() as String {
        return displayTime() + " "
            // skip some line numbers which are wrong anyway
            + (_line.length() >= 5 || _line.equals(".") ? "" : _line + " ")
            + _destination;
    }

    function displayTime() as String {
        if (_moment == null) {
            return getString(Rez.Strings.itm_detail_departure_time_null);
        }

        // since we keep the departure a bit after it has departed,
        // we need handle a negative time diff
        var seconds = MathUtil.max(0, _moment.value() - Time.now().value());
        var minutes = Math.round(seconds / 60.0).toNumber();

        return minutes > 0
            ? (minutes + SettingsStorage.getMinuteSymbol())
            : getString(Rez.Strings.itm_detail_departure_time_now);
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
        if (_modeKey == Mode.KEY_METRO) {
           return AppColors.MODE_METRO;
        }
        else if (_modeKey == Mode.KEY_TRAM) {
            return AppColors.MODE_TRAM;
        }

        else if (_group.equals(_GROUP_BUS_LOCAL_LOCAL)) {
            return AppColors.MODE_BUS_LOCAL;
        }
        else if (_group.equals(_GROUP_BUS_EXPRESS_EXPRESS)) {
            return AppColors.GROUP_BUS_EXPRESS_EXPRESS;
        }
        else if (_group.equals(_GROUP_BUS_EXPRESS_AIRPORT)) {
            return AppColors.GROUP_BUS_EXPRESS_AIRPORT;
        }
        else if (_modeKey == Mode.KEY_BUS_LOCAL) {
            //Log.w("Unknown local bus group " + _group);
            return AppColors.MODE_BUS_LOCAL;
        }
        else if (_modeKey == Mode.KEY_BUS_EXPRESS) {
            //Log.w("Unknown express bus group " + _group);
            return AppColors.GROUP_BUS_EXPRESS_EXPRESS;
        }

        else if (_group.equals(_GROUP_TRAIN_LOCAL_LOCAL)) {
            return AppColors.GROUP_TRAIN_LOCAL_LOCAL;
        }
        else if (_group.equals(_GROUP_TRAIN_REGIONAL_REGIONAL)) {
            return AppColors.GROUP_TRAIN_REGIONAL_REGIONAL;
        }
        else if (_group.equals(_GROUP_TRAIN_EXPRESS_EXPRESS)) {
            return AppColors.GROUP_TRAIN_EXPRESS_EXPRESS;
        }
        else if (_group.equals(_GROUP_TRAIN_EXPRESS_AIRPORT)) {
            return AppColors.GROUP_TRAIN_EXPRESS_AIRPORT;
        }
        else if (_group.equals(_GROUP_TRAIN_EXPRESS_SNABBTAG)) {
            return AppColors.GROUP_TRAIN_EXPRESS_SNABBTAG;
        }
        else if (_group.equals(_GROUP_TRAIN_REGIONAL_NATTAG)) {
            return AppColors.GROUP_TRAIN_REGIONAL_NATTAG;
        }
        else if (_group.equals(_GROUP_TRAIN_REGIONAL_INTERCITY)) {
            return AppColors.GROUP_TRAIN_REGIONAL_INTERCITY;
        }
        else if (_group.equals(_GROUP_TRAIN_LOCAL_PAGA)) {
            return AppColors.GROUP_TRAIN_LOCAL_PAGA;
        }
        else if (_modeKey == Mode.KEY_TRAIN_LOCAL) {
            //Log.w("Unknown local train group " + _group);
            return AppColors.GROUP_TRAIN_LOCAL_LOCAL;
        }
        else if (_modeKey == Mode.KEY_TRAIN_REGIONAL) {
            //Log.w("Unknown regional train group " + _group);
            return AppColors.GROUP_TRAIN_REGIONAL_REGIONAL;
        }
        else if (_modeKey == Mode.KEY_TRAIN_EXPRESS) {
            //Log.w("Unknown express train group " + _group);
            return AppColors.GROUP_TRAIN_EXPRESS_EXPRESS;
        }

        else if (_group.equals(_GROUP_SHIP_LOCAL)) {
            return AppColors.GROUP_SHIP_LOCAL;
        }
        else if (_group.equals(_GROUP_SHIP_INTERNATIONAL)) {
            return AppColors.GROUP_SHIP_INTERNATIONAL;
        }
        else if (_modeKey == Mode.KEY_SHIP) {
            //Log.w("Unknown ship group " + _group);
            return AppColors.GROUP_SHIP_LOCAL;
        }

        //Log.w("Unknown mode " + _modeKey + " or group " + _group);
        return AppColors.MODE_OTHER;
    }

}
