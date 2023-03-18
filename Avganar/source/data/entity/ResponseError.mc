using Toybox.Lang;

class ResponseError {

    static var CODES_E_SERVER = [ 5321, 5322, 5323, 5324 ];
    static var CODE_E_AUTO_LIMIT = -2000;

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
        // Trafiklab
        if (_code == 200) {
            _title = rez(Rez.Strings.lbl_e_null_data);
        }
        else if (ArrUtil.contains(CODES_E_SERVER, _code)) {
            // don't let the user know we are requesting again
            _title = rez(Rez.Strings.lbl_i_departures_requesting);
        }

        // Garmin
        else if (_code == Communications.UNKNOWN_ERROR) {
            _title = rez(Rez.Strings.lbl_e_unknown);
        }
        else if (_code == Communications.BLE_CONNECTION_UNAVAILABLE) {
            _title = rez(Rez.Strings.lbl_e_bluetooth);
        }
        else if (_code == Communications.NETWORK_REQUEST_TIMED_OUT) {
            _title = rez(Rez.Strings.lbl_e_internet);
        }
        else if (_code == Communications.NETWORK_RESPONSE_OUT_OF_MEMORY) {
            _title = rez(Rez.Strings.lbl_e_memory);
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
        else if (_code == Communications.NETWORK_RESPONSE_TOO_LARGE) {
            // don't let the user know we are requesting again
            _title = rez(Rez.Strings.lbl_i_departures_requesting);
        }
        else if (_code == Communications.INVALID_HTTP_BODY_IN_NETWORK_RESPONSE) {
            _title = rez(Rez.Strings.lbl_e_invalid);
        }

        // custom
        else if (_code == CODE_E_AUTO_LIMIT) {
            _title = rez(Rez.Strings.lbl_e_auto_limit);
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
        return ArrUtil.contains(CODES_E_SERVER, _code);
    }

    function hasConnection() {
        return _code != Communications.BLE_CONNECTION_UNAVAILABLE
            && _code != Communications.NETWORK_REQUEST_TIMED_OUT
            && _code != 404;
    }

    function isRerequestable() {
        return hasConnection()
            && !isTooLarge() // will auto-rerequest
            && !isServerError() // will auto-rerequest
            && _code != null;
    }

}
