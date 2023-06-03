using Toybox.Lang;

class ResponseError {

    // HTTP
    static var HTTP_OK = 200;
    static var HTTP_NOT_FOUND = 404;
    static var HTTP_TOO_MANY_REQUESTS = 429;
    static var HTTP_INTERNAL_SERVER_ERROR = 500;
    static var HTTP_SERVICE_UNAVAILABLE = 503;

    // custom
    static var CODE_AUTO_REQUEST_LIMIT_MEMORY = -2001;

    hidden var _code;
    hidden var _title = "";

    // init

    function initialize(httpCode, apiCode) {
        if (("API_QUOTA").equals(apiCode)) {
            _code = HTTP_TOO_MANY_REQUESTS;
        }
        else {
            _code = httpCode;
        }

        _setTitle();
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
        else if (_code == Communications.UNKNOWN_ERROR) {
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
        else if (isTooLarge()) {
            // don't let the user know we are requesting again
            _title = rez(Rez.Strings.msg_i_departures_requesting);
        }
        else if (_code == HTTP_TOO_MANY_REQUESTS) {
            _title = rez(Rez.Strings.msg_e_limit);
        }
        else if (_code == HTTP_INTERNAL_SERVER_ERROR) {
            _title = rez(Rez.Strings.msg_e_server);
        }
        else if (_code == HTTP_SERVICE_UNAVAILABLE) {
            _title = rez(Rez.Strings.msg_e_unavailable);
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

    function hasConnection() {
        return _code != Communications.BLE_CONNECTION_UNAVAILABLE
            && _code != Communications.NETWORK_REQUEST_TIMED_OUT
            && _code != HTTP_NOT_FOUND;
    }

    function isRerequestable() {
        return hasConnection()
            && !isTooLarge() // will auto-rerequest
            && _code != HTTP_TOO_MANY_REQUESTS
            && _code != null;
    }

}
