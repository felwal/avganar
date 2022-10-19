using Toybox.Lang;

class ResponseError {

    static const CODE_ERROR_RETREIVAL_FAILED_1 = 5321;
    static const CODE_ERROR_RETREIVAL_FAILED_2 = 5322;
    static const CODE_ERROR_RETREIVAL_FAILED_3 = 5323;
    static const CODE_ERROR_RETREIVAL_FAILED_4 = 5324;
    static const CODE_ERROR_NULL_DATA = 200;

    private var _code;
    private var _title = "";

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

    private function _setTitle() {
        switch (_code) {
            // Trafiklab
            case CODE_ERROR_NULL_DATA:
                _title = rez(Rez.Strings.lbl_e_null_data);
                break;
            case CODE_ERROR_RETREIVAL_FAILED_1:
            case CODE_ERROR_RETREIVAL_FAILED_2:
            case CODE_ERROR_RETREIVAL_FAILED_3:
            case CODE_ERROR_RETREIVAL_FAILED_4:
                _title = rez(Rez.Strings.lbl_e_retrieval) + " " + _code;
                break;

            // Garmin
            case Communications.BLE_CONNECTION_UNAVAILABLE:
                _title = rez(Rez.Strings.lbl_e_bluetooth);
                break;
            case Communications.NETWORK_REQUEST_TIMED_OUT:
                _title = rez(Rez.Strings.lbl_e_internet);
                break;
            case Communications.NETWORK_RESPONSE_OUT_OF_MEMORY:
                _title = rez(Rez.Strings.lbl_e_memory);
                break;
            case Communications.BLE_QUEUE_FULL:
                _title = rez(Rez.Strings.lbl_e_queue_full);
                break;
            case Communications.BLE_REQUEST_CANCELLED:
                _title = rez(Rez.Strings.lbl_e_cancelled);
                break;
            case Communications.REQUEST_CANCELLED:
                _title = rez(Rez.Strings.lbl_e_cancelled);
                break;
            case Communications.BLE_HOST_TIMEOUT:
                _title = rez(Rez.Strings.lbl_e_timeout);
                break;
            case Communications.NETWORK_RESPONSE_TOO_LARGE:
                _title = rez(Rez.Strings.lbl_e_size);
                break;
            case Communications.INVALID_HTTP_BODY_IN_NETWORK_RESPONSE:
                _title = rez(Rez.Strings.lbl_e_invalid);
                break;

            default:
                _title = (_code <= 0 ? rez(Rez.Strings.lbl_e_request) : rez(Rez.Strings.lbl_e_response)) + " " + _code;
        }
    }

    //

    function isTooLarge() {
        return _code == Communications.NETWORK_RESPONSE_TOO_LARGE
            || _code == Communications.NETWORK_RESPONSE_OUT_OF_MEMORY;
    }

    function hasConnection() {
        return _code != Communications.BLE_CONNECTION_UNAVAILABLE
            && _code != Communications.NETWORK_REQUEST_TIMED_OUT;
    }

    function isRerequestable() {
        return hasConnection()
            && !isTooLarge() // will auto-rerequest
            && _code != null;
    }

}
