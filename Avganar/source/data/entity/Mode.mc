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
    static const KEY_NONE = "NONE";

    static const BIT_BUS = 8;
    static const BIT_METRO = 2;
    static const BIT_TRAIN = 1;
    static const BIT_TRAM = 4;
    static const BIT_SHIP = 64;

    static const KEY_TO_BIT = {
        KEY_BUS => BIT_BUS,
        KEY_METRO => BIT_METRO,
        KEY_TRAIN => BIT_TRAIN,
        KEY_TRAM => BIT_TRAM,
        KEY_SHIP => BIT_SHIP,
    };
    static const KEY_TO_STRING = {
        KEY_BUS => rez(Rez.Strings.itm_modes_bus),
        KEY_METRO => rez(Rez.Strings.itm_modes_metro),
        KEY_TRAIN => rez(Rez.Strings.itm_modes_train),
        KEY_TRAM => rez(Rez.Strings.itm_modes_tram),
        KEY_SHIP => rez(Rez.Strings.itm_modes_ship),
    };

    hidden static var _SERVER_AUTO_REQUEST_LIMIT = 4;
    hidden static var _MEMORY_MIN_TIME_WINDOW = 5;

    hidden var _response as DeparturesResponse;
    hidden var _failedRequestCount = 0;
    hidden var _departuresTimeWindow as Number?;
    hidden var _timeStamp as Moment?;

    function initialize(response as DeparturesResponse) {
        setResponse(response);
    }

    function setResponse(response as DeparturesResponse) as Void {
        _response = response;

        if (response != null) {
            _timeStamp = TimeUtil.now();
            handlePotentialErrors();
        }
    }

    function reset() as Void {
        _timeStamp = null;
        _response = [];
    }

    function getDataAgeMillis() as Number? {
        return (_response instanceof Lang.Array || _response instanceof Lang.String) && _timeStamp != null
            ? TimeUtil.now().subtract(_timeStamp).value() * 1000
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

        if (_failedRequestCount >= _SERVER_AUTO_REQUEST_LIMIT && _response.isServerError()) {
            setResponse(new ResponseError(ResponseError.CODE_AUTO_REQUEST_LIMIT_SERVER));
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

    function handlePotentialErrors() as Void {
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
        else if (_response instanceof ResponseError && _response.isServerError()) {
            _failedRequestCount++;
            return;
        }

        // only vibrate if we are not auto-refreshing
        SystemUtil.vibrateLong();
        _failedRequestCount = 0;
    }

    function getResponse() as DeparturesResponse {
        _removeDepartedDepartures(); // TODO: probably dont want to call this all the time
        return _response;
    }

    //

    hidden function _removeDepartedDepartures() as Void {
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

    //

    static function getKeysByBits(bits as Number) as Array<String> {
        var keys = [];

        if (bits&BIT_BUS != 0) {
            keys.add(KEY_BUS);
        }
        if (bits&BIT_METRO != 0) {
            keys.add(KEY_METRO);
        }
        if (bits&BIT_TRAIN != 0) {
            keys.add(KEY_TRAIN);
        }
        if (bits&BIT_TRAM != 0) {
            keys.add(KEY_TRAM);
        }
        if (bits&BIT_SHIP != 0) {
            keys.add(KEY_SHIP);
        }

        return keys;
    }

    static function getStringsByBits(bits as Number) as Array<String> {
        var strings = [];

        if (bits&BIT_BUS != 0) {
            strings.add(rez(Rez.Strings.itm_modes_bus));
        }
        if (bits&BIT_METRO != 0) {
            strings.add(rez(Rez.Strings.itm_modes_metro));
        }
        if (bits&BIT_TRAIN != 0) {
            strings.add(rez(Rez.Strings.itm_modes_train));
        }
        if (bits&BIT_TRAM != 0) {
            strings.add(rez(Rez.Strings.itm_modes_tram));
        }
        if (bits&BIT_SHIP != 0) {
            strings.add(rez(Rez.Strings.itm_modes_ship));
        }

        return strings;
    }

    static function getLetter(key as String) as String {
        if (key.equals(KEY_ALL)) {
            return "";
        }

        else if (key.equals(KEY_BUS)) {
            return rez(Rez.Strings.lbl_detail_mode_letter_bus);
        }
        else if (key.equals(KEY_METRO)) {
            return rez(Rez.Strings.lbl_detail_mode_letter_metro);
        }
        else if (key.equals(KEY_TRAIN)) {
            return rez(Rez.Strings.lbl_detail_mode_letter_train);
        }
        else if (key.equals(KEY_TRAM)) {
            return rez(Rez.Strings.lbl_detail_mode_letter_tram);
        }
        else if (key.equals(KEY_SHIP)) {
            return rez(Rez.Strings.lbl_detail_mode_letter_ship);
        }
        else {
            return rez(Rez.Strings.lbl_detail_mode_letter_unknown);
        }
    }

}
