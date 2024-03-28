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

using Toybox.Lang;

class ResponseError {

    // API
    static hidden var _API_RESPONSE_SERVER = [ 5321, 5322, 5323, 5324 ];
    static hidden var _API_REQUEST_LIMIT_MINUTE = [ 429, 1006 ];
    static hidden var _API_REQUEST_LIMIT_MONTH = 1007;
    static hidden var _API_RESPONSE_PROXY = 1008;

    // HTTP
    static var HTTP_OK = 200;
    static hidden var _HTTP_BAD_REQUEST = 400;
    static hidden var _HTTP_NOT_FOUND = 404;
    static hidden var _HTTP_NO_CODE = 1002;

    // custom
    static var CODE_AUTO_REQUEST_LIMIT_SERVER = -2000;
    static var CODE_AUTO_REQUEST_LIMIT_MEMORY = -2001;

    hidden var _code;
    hidden var _title = "";

    // init

    function initialize(codeOrTitle) {
        if (codeOrTitle instanceof Lang.Number) {
            _code = codeOrTitle;
            _setTitle();
        }
        else {
            _code = null;
            _title = codeOrTitle;
        }
    }

    function equals(other) {
        return other instanceof ResponseError && other.getCode() == _code;
    }

    function getCode() {
        return _code;
    }

    function getTitle() {
        return _title;
    }

    hidden function _setTitle() {
        if (_code == HTTP_OK) {
            _title = rez(Rez.Strings.msg_e_null_data);
        }
        else if (_code == _HTTP_BAD_REQUEST) {
            _title = rez(Rez.Strings.msg_e_bad_request);
        }
        else if (_code == _HTTP_NOT_FOUND) {
            _title = rez(Rez.Strings.msg_e_not_found);
        }
        else if (_code == Communications.UNKNOWN_ERROR || _code == _HTTP_NO_CODE) {
            _title = rez(Rez.Strings.msg_e_unknown);
        }
        else if (!hasConnection()) {
            _title = rez(Rez.Strings.msg_e_connection);
        }
        else if (_code == Communications.BLE_QUEUE_FULL) {
            _title = rez(Rez.Strings.msg_e_queue_full);
        }
        else if (_code == Communications.BLE_REQUEST_CANCELLED || _code == Communications.REQUEST_CANCELLED) {
            _title = rez(Rez.Strings.msg_e_cancelled);
        }
        else if (_code == Communications.BLE_HOST_TIMEOUT) {
            _title = rez(Rez.Strings.msg_e_timeout);
        }
        else if (_code == Communications.INVALID_HTTP_BODY_IN_NETWORK_RESPONSE) {
            _title = rez(Rez.Strings.msg_e_invalid);
        }
        else if (isServerError() || isTooLarge()) {
            _title = rez(Rez.Strings.msg_i_departures_requesting);
        }
        else if (ArrUtil.contains(_API_REQUEST_LIMIT_MINUTE, _code)) {
            _title = rez(Rez.Strings.msg_e_limit_minute);
        }
        else if (_code == _API_REQUEST_LIMIT_MONTH) {
            _title = rez(Rez.Strings.msg_e_limit_month);
        }
        else if (_code == _API_RESPONSE_PROXY) {
            _title = rez(Rez.Strings.msg_e_proxy);
        }
        else if (_code == CODE_AUTO_REQUEST_LIMIT_SERVER) {
            _title = rez(Rez.Strings.msg_e_server);
        }
        else if (_code == CODE_AUTO_REQUEST_LIMIT_MEMORY) {
            _title = rez(Rez.Strings.msg_e_memory);
        }

        else {
            _title = rez(Rez.Strings.msg_e_general) + " " + _code;
        }
    }

    //

    function isTooLarge() {
        return _code == Communications.NETWORK_RESPONSE_TOO_LARGE
            || _code == Communications.NETWORK_RESPONSE_OUT_OF_MEMORY;
    }

    function isServerError() {
        // NOTE: API limitation
        // usually these "server errors" are resolvable by simply requesting again.
        // we want to automate that.
        return ArrUtil.contains(_API_RESPONSE_SERVER, _code);
    }

    function hasConnection() {
        return _code != Communications.BLE_CONNECTION_UNAVAILABLE
            && _code != Communications.NETWORK_REQUEST_TIMED_OUT;
    }

    function isRequestLimitShortReached() {
        return ArrUtil.contains(_API_REQUEST_LIMIT_MINUTE, _code)
            || _code == CODE_AUTO_REQUEST_LIMIT_SERVER;
    }

    function isRequestLimitLongReached() {
        return _code == _API_REQUEST_LIMIT_MONTH
            || _code == CODE_AUTO_REQUEST_LIMIT_MEMORY;
    }

    function isAutoRefreshable() {
        return isTooLarge()
            || isServerError();
    }

    function isTimerRefreshable() {
        return hasConnection()
            && !isAutoRefreshable()
            && !isRequestLimitLongReached()
            && _code != _HTTP_BAD_REQUEST // shouldn't be repeated
            && _code != HTTP_OK // probably due to breaking API changes
            && _code != null;
    }

    function isUserRefreshable() {
        return isTimerRefreshable()
            && !isRequestLimitShortReached();
    }

}
