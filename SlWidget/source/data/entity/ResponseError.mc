using Toybox.Lang;

(:glance)
class ResponseError {

    static const CODE_STATUS_REQUESTING_STOPS = -2000;
    static const CODE_STATUS_REQUESTING_DEPARTURES = -2001;
    static const CODE_STATUS_NO_GPS = -2002;
    static const CODE_STATUS_OUTSIDE_BOUNDS = -2003;

    static const CODE_RESPONSE_NO_STOPS = -2004;
    static const CODE_RESPONSE_NO_DEPARTURES = -2005;

    static const CODE_ERROR_NULL_DATA = 200;

    var title = "";
    var message = "";

    private var _code;

    // init

    function initialize(codeOrTitle) {
        if (codeOrTitle instanceof Lang.Number) {
            _code = codeOrTitle;
            _initStrings();
        }
        else {
            _code = null;
            title = codeOrTitle;
        }
    }

    function equals(other) {
        if (!(other instanceof ResponseError)) {
            return false;
        }

        return other.getCode() == _code;
    }

    function toString() {
        return _code.toString();
    }

    function getCode() {
        return _code;
    }

    private function _initStrings() {
        switch (_code) {
            // status
            case CODE_STATUS_REQUESTING_STOPS:
                title = rez(Rez.Strings.lbl_i_stops_requesting);
                break;
            case CODE_STATUS_REQUESTING_DEPARTURES:
                title = rez(Rez.Strings.lbl_i_departures_requesting);
                break;
            case CODE_STATUS_NO_GPS:
                title = rez(Rez.Strings.lbl_i_stops_no_gps);
                break;
            case CODE_STATUS_OUTSIDE_BOUNDS:
                title = rez(Rez.Strings.lbl_i_stops_outside_bounds);
                break;

            // response
            case CODE_RESPONSE_NO_STOPS:
                title = rez(Rez.Strings.lbl_i_stops_none);
                break;
            case CODE_RESPONSE_NO_DEPARTURES:
                title = rez(Rez.Strings.lbl_i_departures_none);
                break;
            case CODE_ERROR_NULL_DATA:
                title = rez(Rez.Strings.lbl_e_null_data);
                break;

            // request
            case Communications.BLE_CONNECTION_UNAVAILABLE:
                title = rez(Rez.Strings.lbl_e_bluetooth);
                break;
            case Communications.NETWORK_REQUEST_TIMED_OUT:
                title = rez(Rez.Strings.lbl_e_internet);
                break;
            case Communications.NETWORK_RESPONSE_OUT_OF_MEMORY:
                title = rez(Rez.Strings.lbl_e_memory);
                break;
            case Communications.BLE_QUEUE_FULL:
                title = rez(Rez.Strings.lbl_e_queue_full);
                break;
            case Communications.BLE_REQUEST_CANCELLED:
                title = rez(Rez.Strings.lbl_e_cancelled);
                break;
            case Communications.REQUEST_CANCELLED:
                title = rez(Rez.Strings.lbl_e_cancelled);
                break;
            case Communications.NETWORK_RESPONSE_TOO_LARGE:
                title = rez(Rez.Strings.lbl_e_response_size);
                break;

            default:
                title = rez(Rez.Strings.lbl_e_general) + " " + _code;
        }
    }

    //

    function isStatusMessage() {
        return _code == CODE_STATUS_REQUESTING_STOPS
            || _code == CODE_STATUS_REQUESTING_DEPARTURES
            || _code == CODE_STATUS_NO_GPS
            || _code == CODE_STATUS_OUTSIDE_BOUNDS;
    }

    function isResponseMessage() {
        return _code == CODE_RESPONSE_NO_STOPS
            || _code == CODE_RESPONSE_NO_DEPARTURES;
    }

    function isErrorMessage() {
        return !isStatusMessage() && !isResponseMessage();
    }

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
            && _code != CODE_RESPONSE_NO_STOPS
            && _code != CODE_RESPONSE_NO_DEPARTURES
            && _code != CODE_STATUS_REQUESTING_STOPS
            && _code != CODE_STATUS_REQUESTING_DEPARTURES
            && _code != CODE_STATUS_NO_GPS
            && _code != CODE_STATUS_OUTSIDE_BOUNDS
            && _code != null;
    }

}
