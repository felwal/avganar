using Toybox.Lang;

class ResponseError {

    // API
    static var CODES_RESPONSE_SERVER_ERROR = [ 5321, 5322, 5323, 5324 ];
    static var CODE_REQUEST_NOT_FOUND = 404;

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
        if (_code == 200) {
            _title = rez(Rez.Strings.lbl_e_null_data);
        }
        else if (_code == Communications.UNKNOWN_ERROR) {
            _title = rez(Rez.Strings.lbl_e_unknown);
        }
        else if (!hasConnection()) {
            _title = rez(Rez.Strings.lbl_e_connection);
        }
        else if (_code == Communications.BLE_QUEUE_FULL) {
            _title = rez(Rez.Strings.lbl_e_queue_full);
        }
        else if (_code == Communications.BLE_REQUEST_CANCELLED || _code == Communications.REQUEST_CANCELLED) {
            _title = rez(Rez.Strings.lbl_e_cancelled);
        }
        else if (_code == Communications.BLE_HOST_TIMEOUT) {
            _title = rez(Rez.Strings.lbl_e_timeout);
        }
        else if (_code == Communications.INVALID_HTTP_BODY_IN_NETWORK_RESPONSE) {
            _title = rez(Rez.Strings.lbl_e_invalid);
        }
        else if (isServerError() || isTooLarge()) {
            // don't let the user know we are requesting again
            _title = rez(Rez.Strings.lbl_i_departures_requesting);
        }
        else if (_code == CODE_AUTO_REQUEST_LIMIT_SERVER) {
            _title = rez(Rez.Strings.lbl_e_server);
        }
        else if (_code == CODE_AUTO_REQUEST_LIMIT_MEMORY) {
            _title = rez(Rez.Strings.lbl_e_memory);
        }

        else {
            _title = rez(Rez.Strings.lbl_e_default) + " " + _code;
        }
    }

    //

    function isTooLarge() {
        return _code == Communications.NETWORK_RESPONSE_TOO_LARGE
            || _code == Communications.NETWORK_RESPONSE_OUT_OF_MEMORY;
    }

    function isServerError() {
        return ArrUtil.contains(CODES_RESPONSE_SERVER_ERROR, _code);
    }

    function hasConnection() {
        return _code != Communications.BLE_CONNECTION_UNAVAILABLE
            && _code != Communications.NETWORK_REQUEST_TIMED_OUT
            && _code != CODE_REQUEST_NOT_FOUND;
    }

    function isRerequestable() {
        return hasConnection()
            && !isTooLarge() // will auto-rerequest
            && !isServerError() // will auto-rerequest
            && _code != null;
    }

}
