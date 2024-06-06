import Toybox.Lang;
import Toybox.Time;

class DeparturesResponse {

    hidden static var _SERVER_AUTO_REQUEST_LIMIT = 4;
    hidden static var _MEMORY_MIN_TIME_WINDOW = 5;

    hidden var _response as ResponseWithDepartures;
    hidden var _failedRequestCount = 0;
    hidden var _departuresTimeWindow as Number?;
    hidden var _timeStamp as Moment?;

    function initialize(response as ResponseWithDepartures) {
        setResponse(response);
    }

    function setResponse(response as ResponseWithDepartures) as Void {
        _response = response;
        _timeStamp = TimeUtil.now();

        handlePotentialErrors();
    }

    function reset() as Void {
        _timeStamp = null;
        _response = [];
    }

    function getDataAgeMillis() as Number? {
        return _response instanceof Lang.Array || _response instanceof Lang.String
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

    function getResponse() as ResponseWithDepartures {
        _removeDepartedDepartures();
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

}
