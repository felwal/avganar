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

import Toybox.Lang;
import Toybox.Time;

class Mode {

    static const KEY_BUS = "BUS";
    static const KEY_METRO = "METRO";
    static const KEY_TRAIN = "TRAIN";
    static const KEY_TRAM = "TRAM";
    static const KEY_SHIP = "SHIP";
    static const KEY_ALL = "ALL";

    static private const _BIT_BUS = 8;
    static private const _BIT_METRO = 2;
    static private const _BIT_TRAIN = 1;
    static private const _BIT_TRAM = 4;
    static private const _BIT_SHIP = 64;

    static private var _SERVER_AUTO_REQUEST_LIMIT = 4;
    static private var _MEMORY_MIN_TIME_WINDOW = 5;

    private var _response as DeparturesResponse;
    private var _failedRequestCount as Number = 0;
    private var _departuresTimeWindow as Number?;
    private var _timeStamp as Moment?;

    // init

    function initialize(response as DeparturesResponse) {
        setResponse(response);
    }

    function setResponse(response as DeparturesResponse) as Void {
        _response = response;

        if (response != null) {
            _timeStamp = Time.now();
            _handlePotentialErrors();
        }
    }

    // get

    function getDataAgeMillis() as Number? {
        return (_response instanceof Lang.Array || _response instanceof Lang.String) && _timeStamp != null
            ? Time.now().subtract(_timeStamp).value() * 1000
            : null;
    }

    function getFailedRequestCount() as Number {
        return _failedRequestCount;
    }

    function getTimeWindow() as Number {
        // we don't want to initialize `_departuresTimeWindow` with `SettingsStorage.getDefaultTimeWindow()`,
        // because then it wont sync when the setting is edited.
        return _departuresTimeWindow != null
            ? _departuresTimeWindow
            : SettingsStorage.getDefaultTimeWindow();
    }

    function shouldAutoRefresh() as Boolean {
        if (!(_response instanceof ResponseError)) {
            return false;
        }

        if (getTimeWindow() < _MEMORY_MIN_TIME_WINDOW) {
            setResponse(new ResponseError(ResponseError.CODE_AUTO_REQUEST_LIMIT_MEMORY));
            return false;
        }

        return _response.isAutoRefreshable();
    }

    function hasResponseError() as Boolean {
        return _response instanceof ResponseError;
    }

    function getResponse() as DeparturesResponse {
        _removeDepartedDepartures();
        return _response;
    }

    //

    private function _handlePotentialErrors() as Void {
        // for each too large response, halve the time window
        if (_response instanceof ResponseError && _response.isTooLarge()) {
            if (_departuresTimeWindow == null) {
                _departuresTimeWindow = SettingsStorage.getDefaultTimeWindow() / 2;
            }
            else if (_departuresTimeWindow > _MEMORY_MIN_TIME_WINDOW
                && _departuresTimeWindow < 2 * _MEMORY_MIN_TIME_WINDOW) {
                // if halving would result in less than the minimum,
                // use the minimum
                _departuresTimeWindow = _MEMORY_MIN_TIME_WINDOW;
            }
            else {
                _departuresTimeWindow /= 2;
            }

            _failedRequestCount++;
            return;
        }

        // only vibrate if we are not auto-refreshing
        SystemUtil.vibrateLong();
        _failedRequestCount = 0;
    }

    private function _removeDepartedDepartures() as Void {
        if (!(_response instanceof Lang.Array) || _response.size() == 0
            || !_response[0].hasDeparted()) {

            return;
        }

        var firstIndex = -1;

        for (var i = 1; i < _response.size(); i++) {
            // once we get the first departure that has not departed,
            // add it and everything after
            if (!_response[i].hasDeparted()) {
                firstIndex = i;
                break;
            }
        }

        if (firstIndex != -1) {
            _response = _response.slice(firstIndex, null);
        }
        else {
            _response = [];
        }
    }

    // static

    static function getKeysByBits(bits as Number) as Array<String> {
        var keys = [];

        if (bits&_BIT_BUS != 0) {
            keys.add(KEY_BUS);
        }
        if (bits&_BIT_METRO != 0) {
            keys.add(KEY_METRO);
        }
        if (bits&_BIT_TRAIN != 0) {
            keys.add(KEY_TRAIN);
        }
        if (bits&_BIT_TRAM != 0) {
            keys.add(KEY_TRAM);
        }
        if (bits&_BIT_SHIP != 0) {
            keys.add(KEY_SHIP);
        }

        return keys;
    }

    static function getItemString(key as String) as String {
        if (key.equals(KEY_BUS)) {
            return getString(Rez.Strings.itm_modes_bus);
        }
        else if (key.equals(KEY_METRO)) {
            return getString(Rez.Strings.itm_modes_metro);
        }
        else if (key.equals(KEY_TRAIN)) {
            return getString(Rez.Strings.itm_modes_train);
        }
        else if (key.equals(KEY_TRAM)) {
            return getString(Rez.Strings.itm_modes_tram);
        }
        else if (key.equals(KEY_SHIP)) {
            return getString(Rez.Strings.itm_modes_ship);
        }

        return getString(Rez.Strings.itm_modes_other);
    }

    static function getSymbol(key as String) as String {
        if (key.equals(KEY_ALL)) {
            return "";
        }

        else if (key.equals(KEY_BUS)) {
            return getString(Rez.Strings.lbl_detail_mode_symbol_bus);
        }
        else if (key.equals(KEY_METRO)) {
            return getString(Rez.Strings.lbl_detail_mode_symbol_metro);
        }
        else if (key.equals(KEY_TRAIN)) {
            return getString(Rez.Strings.lbl_detail_mode_symbol_train);
        }
        else if (key.equals(KEY_TRAM)) {
            return getString(Rez.Strings.lbl_detail_mode_symbol_tram);
        }
        else if (key.equals(KEY_SHIP)) {
            return getString(Rez.Strings.lbl_detail_mode_symbol_ship);
        }

        return getString(Rez.Strings.lbl_detail_mode_symbol_other);
    }

}
