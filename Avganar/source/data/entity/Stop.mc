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

//! Must have the same interface as `StopDouble` since we often don't
//! know whether our stops are of `Stop` or `StopDouble`.
class Stop {

    hidden static var _SERVER_AUTO_REQUEST_LIMIT = 4;
    hidden static var _MEMORY_MIN_TIME_WINDOW = 5;

    // NOTE: instead of adding public fields, add getters.
    // and when adding functions, remember to add
    // corresponding ones to ´StopDouble´

    var name;

    hidden var _id;
    hidden var _products = null;
    hidden var _modes = [];
    hidden var _responses = {};
    hidden var _failedRequestCount = 0;
    hidden var _deviationMessages = [];
    hidden var _departuresTimeWindow;
    hidden var _timeStamp; // TODO: we need one per mode

    // init

    function initialize(id, name, products) {
        _id = id;
        _products = products;
        me.name = name;

        _setModesKeys();
    }

    function equals(other) {
        return (other instanceof Stop || other instanceof StopDouble || other instanceof StopDummy)
            && other.getId() == _id && other.name.equals(name);
    }

    // set

    function setProducts(products) {
        _products = products;
    }

    function setResponse(mode, response) {
        _responses[mode] = response;
        _timeStamp = TimeUtil.now();

        // NOTE: migration to 1.8.0
        // if the mode wasn't added via products, add it now
        if (!ArrUtil.contains(_modes, mode)) {
            _modes.add(mode);
        }

        // for each too large response, halve the time window
        if (response instanceof ResponseError && response.isTooLarge()) {
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
        else if (response instanceof ResponseError && response.isServerError()) {
            _failedRequestCount++;
            return;
        }

        // only vibrate if we are not auto-refreshing
        SystemUtil.vibrateLong();
        _failedRequestCount = 0;
    }

    function resetResponse(mode) {
        _responses[mode] = [];
        _timeStamp = null;
    }

    function resetResponses() {
        _responses = {};
        _timeStamp = null;
    }

    function resetResponseErrors() {
        var keys = _responses.keys();

        for (var i = 0; i < keys.size(); i++) {
            var key = keys[i];

            if (_responses[key] instanceof ResponseError) {
                _responses.remove(key);
            }
        }
    }

    function setDeviation(messages) {
        _deviationMessages = messages;
    }

    hidden function _setModesKeys() {
        if (_products == null) {
            // NOTE: migration to 1.8.0
            // if products are unknown, skip the mode menu entirely
            _modes = [];
        }
        else {
            _modes = Departure.getModesKeysByBits(_products);
        }
    }


    // get

    function getId() {
        return _id;
    }

    function getProducts() {
        return _products;
    }

    function hasResponse(mode) {
        return _responses.hasKey(mode) && _responses[mode] != [];
    }

    function getResponse(mode) {
        return _responses[mode];
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

    function getDeviationMessages() {
        return _deviationMessages;
    }

    function shouldAutoRefresh(mode) {
        if (!(_responses[mode] instanceof ResponseError)) {
            return false;
        }

        if (_failedRequestCount >= _SERVER_AUTO_REQUEST_LIMIT && _responses[mode].isServerError()) {
            setResponse(mode, new ResponseError(ResponseError.CODE_AUTO_REQUEST_LIMIT_SERVER));
            return false;
        }

        if (getTimeWindow() < _MEMORY_MIN_TIME_WINDOW) {
            setResponse(mode, new ResponseError(ResponseError.CODE_AUTO_REQUEST_LIMIT_MEMORY));
            return false;
        }

        return _responses[mode].isAutoRefreshable();
    }

    function getDataAgeMillis(mode) {
        return _responses[mode] instanceof Lang.Array || _responses[mode] instanceof Lang.String
            ? TimeUtil.now().subtract(_timeStamp).value() * 1000
            : null;
    }

    function getModeKey(index) {
        return index < _modes.size() ? _modes[index] : null;
    }

    function getModesKeys() {
        return _modes;
    }

    function getModesStrings() {
        var strings = [];

        for (var i = 0; i < _modes.size(); i++) {
            var key = _modes[i];
            strings.add(Departure.MODE_TO_STRING[key]);
        }

        return strings;
    }

    function getModesCount() {
        return _modes.size();
    }

    function getAddedModesCount() {
        return _responses.size();
    }

    function getModeResponse(mode) {
        _removeDepartedDepartures(mode);
        return _responses[mode];
    }

    //

    hidden function _removeDepartedDepartures(mode) {
        if (!_responses.hasKey(mode) || _responses[mode] == null
            || _responses[mode].size() == 0 || !_responses[mode][0].hasDeparted()) {

            return;
        }

        //Log.d(_responses[mode]);

        var firstIndex = -1;

        for (var i = 1; i < _responses[mode].size(); i++) {
            // once we get the first departure that has not departed,
            // add it and everything after
            if (!_responses[mode][i].hasDeparted()) {
                firstIndex = i;
                break;
            }
        }

        if (firstIndex != -1) {
            _responses[mode] = _responses[mode].slice(firstIndex, null);
        }
        else {
            _responses[mode] = [];
        }
    }

}
