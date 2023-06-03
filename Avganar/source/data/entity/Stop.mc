using Toybox.Lang;

class Stop {

    hidden static var _SERVER_AUTO_REQUEST_LIMIT = 6;
    hidden static var _MEMORY_MIN_TIME_WINDOW = 2;

    // NOTE: instead of adding public fields, add getters.
    // and when adding functions, remember to add
    // corresponding ones to ´StopDouble´

    var name;

    hidden var _id;
    hidden var _response;
    hidden var _failedRequestCount = 0;
    hidden var _departuresTimeWindow;
    hidden var _timeStamp;

    // init

    function initialize(id, name) {
        _id = id;
        me.name = name;
    }

    function equals(other) {
        return (other instanceof Stop || other instanceof StopDouble || other instanceof StopDummy)
            && other.getId() == _id && other.name.equals(name);
    }

    // set

    function setResponse(response) {
        _response = response;
        _timeStamp = TimeUtil.now();

        // for each too large response, halve the time window
        if (_response instanceof ResponseError && _response.isTooLarge()) {
            _departuresTimeWindow = _departuresTimeWindow == null
                ? SettingsStorage.getDefaultTimeWindow() / 2
                : _departuresTimeWindow / 2;

            _failedRequestCount++;
        }
        else {
            // only vibrate if we are not auto-rerequesting
            vibrate();
            _failedRequestCount = 0;
        }
    }

    function resetResponse() {
        _response = null;
        _timeStamp = null;
    }

    function resetResponseError() {
        if (_response instanceof ResponseError) {
            resetResponse();
        }
    }

    // get

    function getId() {
        return _id;
    }

    function getResponse() {
        return _response;
    }

    function getFailedRequestCount() {
        return _failedRequestCount;
    }

    function getTimeWindow() {
        // we don't want to initialize `_departuresTimeWindow` with `SettingsStorage.getDefaultTimeWindow()`,
        // because then it wont sync when the setting is edited.
        return _departuresTimeWindow != null
            ? _departuresTimeWindow
            : SettingsStorage.getDefaultTimeWindow();
    }

    function shouldAutoRerequest() {
        if (!(_response instanceof ResponseError)) {
            return false;
        }

        if (getTimeWindow() < _MEMORY_MIN_TIME_WINDOW) {
            setResponse(new ResponseError(ResponseError.CODE_AUTO_REQUEST_LIMIT_MEMORY, null));
            return false;
        }

        return _response.isTooLarge();
    }

    function getDataAgeMillis() {
        return _response instanceof Lang.Array || _response instanceof Lang.String
            ? TimeUtil.now().subtract(_timeStamp).value() * 1000
            : null;
    }

    function getModeCount() {
        if (_response instanceof Lang.Array) {
            return _response.size();
        }

        return 1;
    }

    function getModeResponse(mode) {
        if (_response instanceof Lang.Array) {
            if (_response.size() > 0) {
                do {
                    mode = MathUtil.coerceIn(mode, 0, _response.size() - 1);
                    _removeDepartedDepartures(mode);
                }
                while (_response.removeAll(null) && _response.size() > 0);
            }

            return [ _response.size() > 0 ? _response[mode] : rez(Rez.Strings.msg_i_departures_none),
                mode ];
        }

        return [ _response, 0 ];
    }

    function getModeSymbol(mode) {
        if (!(_response instanceof Lang.Array) || _response.size() == 0) {
            return "";
        }

        return _response[mode][0].getModeSymbol();
    }

    //

    hidden function _removeDepartedDepartures(mode) {
        if (_response[mode] == null || _response[mode].size() == 0 || !_response[mode][0].hasDeparted()) {
            return;
        }

        var firstIndex = -1;

        for (var i = 1; i < _response[mode].size(); i++) {
            // once we get the first departure that has not departed,
            // add it and everything after
            if (!_response[mode][i].hasDeparted()) {
                firstIndex = i;
                break;
            }
        }

        if (firstIndex != -1) {
            _response[mode] = _response[mode].slice(firstIndex, null);
        }
        else {
            // add null because an ampty array is not matched with the equals() that removeAll() performes.
            _response[mode] = null;
        }
    }

}
