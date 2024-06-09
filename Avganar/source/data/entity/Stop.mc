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

    private var _id as Number;
    private var _products as Number? = null;
    private var _modesKeys as Array<String> = [];
    private var _modes as Dictionary<String, Mode> = {};
    private var _deviationMessages as Array<String> = [];

    // init

    function initialize(id as Number, name as String, products as Number?) {
        _id = id;
        _products = products;
        me.name = name;

        _setModesKeys();
    }

    //! Only use this for quick comparison
    static function dummy(id as Number, name as String) as Stop {
        return new Stop(id, name, null);
    }

    function equals(other) as Boolean {
        return (other instanceof Stop || other instanceof StopDouble)
            && other.getId() == _id && other.name.equals(name);
    }

    // set

    function setProducts(products as Number?) as Void {
        _products = products;
    }

    function setDeparturesResponse(modeKey as String, response as DeparturesResponse) as Void {
        // NOTE: migration to 1.8.0
        // if we got a successful response, remove the ALL mode
        if (!modeKey.equals(Mode.KEY_ALL) && ArrUtil.contains(_modesKeys, Mode.KEY_ALL)) {
            _modesKeys.remove(Mode.KEY_ALL);
            _modes.remove(Mode.KEY_ALL);
        }

        // NOTE: migration to 1.8.0
        // if we got an error for ALL, reset all modes
        else if (modeKey.equals(Mode.KEY_ALL) && response instanceof ResponseError) {
            resetModes();
        }

        // NOTE: migration to 1.8.0
        // if the mode wasn't added via products, add it now
        if (!ArrUtil.contains(_modesKeys, modeKey)) {
            _modesKeys.add(modeKey);
        }

        if (_modes.hasKey(modeKey)) {
            _modes[modeKey].setResponse(response);
        }
        else {
            _modes[modeKey] = new Mode(response);
        }
    }

    function resetMode(modeKey as String) as Void {
        _modes.remove(modeKey);
    }

    function resetModes() as Void {
        _modes = {};
    }

    function resetModesWithResponseErrors() as Void {
        var keys = _modes.keys();

        for (var i = 0; i < keys.size(); i++) {
            var key = keys[i];

            if (_modes[key].hasResponseError()) {
                _modes.remove(key);
            }
        }
    }

    function setDeviation(messages as Array<String>) as Void {
        _deviationMessages = messages;
    }

    private function _setModesKeys() as Void {
        if (_products == null) {
            // NOTE: migration to 1.8.0
            // if products are unknown, skip the mode menu entirely
            _modesKeys = [];
        }
        else {
            _modesKeys = Mode.getKeysByBits(_products);
        }
    }


    // get

    function getId() as Number {
        return _id;
    }

    function getProducts() as Number? {
        return _products;
    }

    function hasMode(modeKey as String) as Boolean {
        return _modes.hasKey(modeKey);
    }

    function getMode(modeKey as String) as Mode {
        return _modes.hasKey(modeKey)
            ? _modes[modeKey]
            : new Mode(null); // to avoid having to null-check all the time
    }

    function getDeviationMessages() as Array<String> {
        return _deviationMessages;
    }

    function getModeKey(index as Number) as String {
        return index < _modesKeys.size() ? _modesKeys[index] : Mode.KEY_ALL;
    }

    function getModesKeys() as Array<String> {
        return _modesKeys;
    }

    function getModesStrings() as Array<String> {
        var strings = [];

        for (var i = 0; i < _modesKeys.size(); i++) {
            var key = _modesKeys[i];
            strings.add(Mode.KEY_TO_STRING[key]);
        }

        return strings;
    }

    function getModesCount() as Number {
        return _modesKeys.size();
    }

    function getAddedModesCount() as Number {
        return _modes.size();
    }

}
