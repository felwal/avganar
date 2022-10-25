using Toybox.Lang;
using Carbon.C14;

class Stop {

    var id;
    var name;
    var distance;

    private var _departuresTimeWindow;
    private var _response;
    private var _timeStamp;

    // init

    function initialize(id, name, distance) {
        self.id = id;
        self.name = name;
        self.distance = distance;

        setSearching();
    }

    // set

    function setSearching() {
        _response = null;
        _timeStamp = null;
    }

    function setResponse(response) {
        _response = response;
        _timeStamp = C14.now();

        // for each too large response, halve the time window
        if (_response instanceof ResponseError && _response.isTooLarge()) {
            _departuresTimeWindow = _departuresTimeWindow == null
                ? SettingsStorage.getDefaultTimeWindow() / 2
                : _departuresTimeWindow / 2;
        }
        else {
            // only vibrate if we are not auto-rerequesting
            vibrate();
        }
    }

    // get

    function getTimeWindow() {
        // we don't want to initialize `_departuresTimeWindow` with `SettingsStorage.getDefaultTimeWindow()`,
        // because then it wont sync when the setting is edited.
        return _departuresTimeWindow != null
            ? _departuresTimeWindow
            : SettingsStorage.getDefaultTimeWindow();
    }

    function hasDepartures() {
        return _response instanceof Lang.Array;
    }

    function getDataAgeMillis() {
        return hasDepartures() ? C14.now().subtract(_timeStamp).value() * 1000 : null;
    }

    function getModeCount() {
        return hasDepartures() ? _response.size() : 1;
    }

    function getDepartures(mode) {
        _removeDepartedDepartures(mode);
        return hasDepartures() ? ArrUtil.coerceGet(_response, mode) : null;
    }

    function getResponseError() {
        return hasDepartures() ? null : _response;
    }

    //

    private function _removeDepartedDepartures(mode) {
        var firstIndex = -1;

        if (!_response[mode][0].hasDeparted()) {
            return;
        }

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
            _response[mode] = [];
        }
    }

}
