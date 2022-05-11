using Toybox.Lang;

(:glance)
class ResponseError {

    static const ERROR_CODE_SEARCHING = -2000;
    static const ERROR_CODE_NO_DATA = 200;
    static const ERROR_CODE_NO_GPS = -2001;
    static const ERROR_CODE_OUTSIDE_BOUNDS = -2002;
    static const ERROR_CODE_NO_STOPS = -2003;
    static const ERROR_CODE_NO_DEPARTURES = -2004;

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

    private function _initStrings() {
        switch (_code) {
            case ERROR_CODE_SEARCHING:
                title = rez(Rez.Strings.lbl_i_departures_searching);
                break;
            case ERROR_CODE_NO_DATA:
                title = rez(Rez.Strings.lbl_e_null_data);
                break;
            case ERROR_CODE_NO_GPS:
                title = rez(Rez.Strings.lbl_i_stops_no_gps);
                break;
            case ERROR_CODE_OUTSIDE_BOUNDS:
                title = rez(Rez.Strings.lbl_i_stops_outside_bounds);
                break;
            case ERROR_CODE_NO_STOPS:
                title = rez(Rez.Strings.lbl_i_stops_no_gps);
                break;
            case ERROR_CODE_NO_DEPARTURES:
                title = rez(Rez.Strings.lbl_i_departures_none_found);
                break;

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
            && _code != ERROR_CODE_SEARCHING
            && _code != ERROR_CODE_NO_GPS
            && _code != ERROR_CODE_OUTSIDE_BOUNDS
            && _code != null;
    }

}
