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

    // NOTE: instead of adding public fields, add getters.
    // and when adding functions, remember to add
    // corresponding ones to ´StopDouble´

    var name;

    hidden var _id;
    hidden var _products = null;
    hidden var _modes = [];
    hidden var _responses = {};
    hidden var _deviationMessages = [];

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
        // NOTE: migration to 1.8.0
        // if we got a successful response, remove the ALL mode
        if (mode != null && mode != Departure.MODE_ALL && ArrUtil.contains(_modes, Departure.MODE_ALL)) {
            _modes.remove(Departure.MODE_ALL);
            _responses.remove(Departure.MODE_ALL);
        }

        // NOTE: migration to 1.8.0
        // if we got an error for ALL, reset all modes
        else if (mode == Departure.MODE_ALL && response instanceof ResponseError) {
            resetResponses();
        }

        // NOTE: migration to 1.8.0
        // if the mode wasn't added via products, add it now
        if (!ArrUtil.contains(_modes, mode)) {
            _modes.add(mode);
        }

        if (_responses.hasKey(mode)) {
            _responses[mode].setResponse(response);
        }
        else {
            _responses[mode] = new DeparturesResponse(response);
        }
    }

    function resetResponse(mode) {
        _responses[mode] = [];
    }

    function resetResponses() {
        _responses = {};
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
        return mode != null && _responses.hasKey(mode) && _responses[mode] != null;
    }

    function getResponse(mode) {
        return _responses[mode];
    }

    function getFailedRequestCount(mode) {
        return _hasDeparturesResponse(mode)
            ? _responses[mode].getFailedRequestCount()
            : 0;
    }

    function getTimeWindow(mode) {
        return _hasDeparturesResponse(mode)
            ? _responses[mode].getTimeWindow()
            : SettingsStorage.getDefaultTimeWindow();
    }

    function getDeviationMessages() {
        return _deviationMessages;
    }

    function shouldAutoRefresh(mode) {
        return _hasDeparturesResponse(mode) && _responses[mode].shouldAutoRefresh();
    }

    function getDataAgeMillis(mode) {
        return _hasDeparturesResponse(mode)
            ? _responses[mode].getDataAgeMillis()
            : null;
    }

    hidden function _hasDeparturesResponse(mode) {
        return mode != null
            && _responses.hasKey(mode)
            && _responses[mode] instanceof DeparturesResponse;
    }

    function getModeKey(index) {
        return index < _modes.size() ? _modes[index] : Departure.MODE_ALL;
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
        return _hasDeparturesResponse(mode)
            ? _responses[mode].getResponse()
            : _responses[mode];
    }

}
