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

class ResponseError {

    // API
    static private var _API_RESPONSE_SERVER = [ 5321, 5322, 5323, 5324 ];
    static private var _API_REQUEST_LIMIT_MINUTE = [ 429, 1006 ];
    static private var _API_REQUEST_LIMIT_MONTH = 1007;
    static private var _API_RESPONSE_PROXY = 1008;

    // HTTP
    static var HTTP_OK = 200;
    static private var _HTTP_BAD_REQUEST = 400;
    static private var _HTTP_NOT_FOUND = 404;
    static private var _HTTP_NO_CODE = 1002;

    // custom
    static var CODE_AUTO_REQUEST_LIMIT_MEMORY = -2001;
    static var CODE_LOCATION_OFF = -2002;

    private var _code as Number?;
    private var _title as String = "";

    // init

    function initialize(codeOrTitle as Number or String) {
        if (codeOrTitle instanceof Number) {
            _code = codeOrTitle;
            _setTitle();
        }
        else {
            _code = null;
            _title = codeOrTitle;
        }
    }

    function equals(other) as Boolean {
        return other instanceof ResponseError && (_code != null
            ? _code == other.getCode()
            : _title.equals(other.getTitle()));
    }

    private function _setTitle() as Void {
        if (_code == HTTP_OK) {
            _title = getString(Rez.Strings.msg_e_null_data);
        }
        else if (_code == _HTTP_BAD_REQUEST) {
            _title = getString(Rez.Strings.msg_e_bad_request);
        }
        else if (_code == _HTTP_NOT_FOUND) {
            _title = getString(Rez.Strings.msg_e_not_found);
        }
        else if (_code == Communications.UNKNOWN_ERROR || _code == _HTTP_NO_CODE) {
            _title = getString(Rez.Strings.msg_e_unknown);
        }
        else if (!hasConnection()) {
            _title = getString(Rez.Strings.msg_e_connection);
        }
        else if (_code == Communications.BLE_QUEUE_FULL) {
            _title = getString(Rez.Strings.msg_e_queue_full);
        }
        else if (_code == Communications.BLE_REQUEST_CANCELLED || _code == Communications.REQUEST_CANCELLED) {
            _title = getString(Rez.Strings.msg_e_cancelled);
        }
        else if (_code == Communications.BLE_HOST_TIMEOUT) {
            _title = getString(Rez.Strings.msg_e_timeout);
        }
        else if (_code == Communications.INVALID_HTTP_BODY_IN_NETWORK_RESPONSE) {
            _title = getString(Rez.Strings.msg_e_invalid);
        }

        else if (isAutoRefreshable()) {
            _title = getString(Rez.Strings.msg_i_departures_requesting);
        }
        else if (ArrUtil.contains(_API_RESPONSE_SERVER, _code)) {
            _title = getString(Rez.Strings.msg_e_server);
        }
        else if (ArrUtil.contains(_API_REQUEST_LIMIT_MINUTE, _code)) {
            _title = getString(Rez.Strings.msg_e_limit_minute);
        }
        else if (_code == _API_REQUEST_LIMIT_MONTH) {
            _title = getString(Rez.Strings.msg_e_limit_month);
        }
        else if (_code == _API_RESPONSE_PROXY) {
            _title = getString(Rez.Strings.msg_e_proxy);
        }

        else if (_code == CODE_AUTO_REQUEST_LIMIT_MEMORY) {
            _title = getString(Rez.Strings.msg_e_memory);
        }
        else if (_code == CODE_LOCATION_OFF) {
            _title = getString(Rez.Strings.msg_i_stops_location_off);
        }

        else {
            _title = getString(Rez.Strings.msg_e_general) + " " + _code;
        }
    }

    // get

    function getCode() as Number? {
        return _code;
    }

    function getTitle() as String {
        return _title;
    }

    function isTooLarge() as Boolean {
        return _code == Communications.NETWORK_RESPONSE_TOO_LARGE
            || _code == Communications.NETWORK_RESPONSE_OUT_OF_MEMORY;
    }

    function hasConnection() as Boolean {
        return _code != Communications.BLE_CONNECTION_UNAVAILABLE
            && _code != Communications.NETWORK_REQUEST_TIMED_OUT;
    }

    private function _isRequestLimitShortReached() as Boolean {
        return ArrUtil.contains(_API_REQUEST_LIMIT_MINUTE, _code);
    }

    private function _isRequestLimitLongReached() as Boolean {
        return _code == _API_REQUEST_LIMIT_MONTH
            || _code == CODE_AUTO_REQUEST_LIMIT_MEMORY;
    }

    function isAutoRefreshable() as Boolean {
        return isTooLarge();
    }

    function isTimerRefreshable() as Boolean {
        return hasConnection()
            && !isAutoRefreshable()
            && !_isRequestLimitLongReached()
            && _code != _HTTP_BAD_REQUEST // shouldn't be repeated
            && _code != HTTP_OK // probably due to breaking API changes
            && _code != CODE_LOCATION_OFF
            && _code != null;
    }

    function isUserRefreshable() as Boolean {
        return isTimerRefreshable()
            && !_isRequestLimitShortReached();
    }

}
