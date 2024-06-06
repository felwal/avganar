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

import Toybox.Lang;

//! Must have the same interface as `StopDouble` since we often don't
//! know whether our stops are of `Stop` or `StopDouble`.
class Stop {

    // NOTE: instead of adding public fields, add getters.
    // and when adding functions, remember to add
    // corresponding ones to ´StopDouble´

    var name as String;

    hidden var _id as Number;
    hidden var _products as Number? = null;
    hidden var _modes as Array<String> = [];
    hidden var _responses as Dictionary<String, DeparturesResponse or Null> = {};
    hidden var _deviationMessages as Array<String> = [];

    // init

    function initialize(id as Number, name as String, products as Number?) {
        _id = id;
        _products = products;
        me.name = name;

        _setModesKeys();
    }

    function equals(other) as Boolean {
        return (other instanceof Stop || other instanceof StopDouble || other instanceof StopDummy)
            && other.getId() == _id && other.name.equals(name);
    }

    // set

    function setProducts(products as Number?) as Void {
        _products = products;
    }

    function setResponse(mode as String?, response as ResponseWithDepartures) as Void {
        if (mode == null) {
            return;
        }

        // NOTE: migration to 1.8.0
        // if we got a successful response, remove the ALL mode
        if (!mode.equals(Departure.MODE_ALL) && ArrUtil.contains(_modes, Departure.MODE_ALL)) {
            _modes.remove(Departure.MODE_ALL);
            _responses.remove(Departure.MODE_ALL);
        }

        // NOTE: migration to 1.8.0
        // if we got an error for ALL, reset all modes
        else if (mode.equals(Departure.MODE_ALL) && response instanceof ResponseError) {
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

    function resetResponse(mode as String) as Void {
        _responses[mode] = null; // TODO: remove key instead?
    }

    function resetResponses() as Void {
        _responses = {};
    }

    function resetResponseErrors() as Void {
        var keys = _responses.keys();

        for (var i = 0; i < keys.size(); i++) {
            var key = keys[i];

            if (_responses[key] instanceof ResponseError) {
                _responses.remove(key);
            }
        }
    }

    function setDeviation(messages as Array<String>) as Void {
        _deviationMessages = messages;
    }

    hidden function _setModesKeys() as Void {
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

    function getId() as Number {
        return _id;
    }

    function getProducts() as Number? {
        return _products;
    }

    function hasResponse(mode as String?) as Boolean {
        return mode != null && _responses.hasKey(mode) && _responses[mode] != null;
    }

    function getResponse(mode as String) as DeparturesResponse {
        return _responses[mode];
    }

    function getFailedRequestCount(mode as String?) as Number {
        return _hasDeparturesResponse(mode)
            ? _responses[mode].getFailedRequestCount()
            : 0;
    }

    function getTimeWindow(mode as String?) as Number {
        return _hasDeparturesResponse(mode)
            ? _responses[mode].getTimeWindow()
            : SettingsStorage.getDefaultTimeWindow();
    }

    function getDeviationMessages() as Array<String> {
        return _deviationMessages;
    }

    function shouldAutoRefresh(mode as String?) as Boolean {
        return _hasDeparturesResponse(mode) && _responses[mode].shouldAutoRefresh();
    }

    function getDataAgeMillis(mode as String?) as Number? {
        return _hasDeparturesResponse(mode)
            ? _responses[mode].getDataAgeMillis()
            : null;
    }

    hidden function _hasDeparturesResponse(mode as String?) as Boolean {
        return mode != null
            && _responses.hasKey(mode)
            && _responses[mode] instanceof DeparturesResponse;
    }

    function getModeKey(index as Number) as String {
        return index < _modes.size() ? _modes[index] : Departure.MODE_ALL;
    }

    function getModesKeys() as Array<String> {
        return _modes;
    }

    function getModesStrings() as Array<String> {
        var strings = [];

        for (var i = 0; i < _modes.size(); i++) {
            var key = _modes[i];
            strings.add(Departure.MODE_TO_STRING[key]);
        }

        return strings;
    }

    function getModesCount() as Number {
        return _modes.size();
    }

    function getAddedModesCount() as Number {
        return _responses.size();
    }

    function getModeResponse(mode as String?) as ResponseWithDepartures {
        return _hasDeparturesResponse(mode)
            ? _responses[mode].getResponse()
            : _responses[mode];
    }

}
