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

//! NOTE: API limitation
//! The StopDouble represents a stop which has the same
//! id as another stop, but different name.
//! Since the ids are the same, they should present the same content.
//!
//! Must have the same interface as `Stop` since we often don't
//! know whether our stops are of `Stop` or `StopDouble`.
class StopDouble {

    var name as String;

    hidden var _stop as StopType;

    // init

    function initialize(stop as StopType, name as String) {
        _stop = stop instanceof Stop ? stop : stop.getRootStop();
        me.name = name;
    }

    function equals(other) as Boolean {
        return (other instanceof Stop || other instanceof StopDouble || other instanceof StopDummy)
            && other.getId() == getId() && other.name.equals(name);
    }

    function getRootStop() as Stop {
        return _stop instanceof Stop ? _stop : _stop.getRootStop();
    }

    // set

    function setProducts(products as Number?) as Void {
        _stop.setProducts(products);
    }

    function setResponse(mode as String?, response as ResponseWithDepartures) as Void {
        _stop.setResponse(mode, response);
    }

    function resetResponse(mode as String) as Void {
        _stop.resetResponse(mode);
    }

    function resetResponses() as Void {
        _stop.resetResponses();
    }

    function resetResponseErrors() as Void {
        _stop.resetResponseErrors();
    }

    function setDeviation(message as Array<String>) as Void {
        _stop.setDeviation(message);
    }

    // get

    function getId() as Number {
        return _stop.getId();
    }

    function getProducts() as Number? {
        return _stop.getProducts();
    }

    function hasResponse(mode as String?) as Boolean {
        return _stop.hasResponse(mode);
    }

    function getResponse(mode as String) as DeparturesResponse {
        return _stop.getResponse(mode);
    }

    function getFailedRequestCount(mode as String?) as Number {
        return _stop.getFailedRequestCount(mode);
    }

    function getTimeWindow(mode as String?) as Number {
        return _stop.getTimeWindow(mode);
    }

    function getDeviationMessages() as Array<String> {
        return _stop.getDeviationMessages();
    }

    function shouldAutoRefresh(mode as String?) as Boolean {
        return _stop.shouldAutoRefresh(mode);
    }

    function getDataAgeMillis(mode as String?) as Number? {
        return _stop.getDataAgeMillis(mode);
    }

    function getModeKey(index as Number) as String {
        return _stop.getModeKey(index);
    }

    function getModesKeys() as Array<String> {
        return _stop.getModesKeys();
    }

    function getModesStrings() as Array<String> {
        return _stop.getModesStrings();
    }

    function getModesCount() as Number {
        return _stop.getModesCount();
    }

    function getAddedModesCount() as Number {
        return _stop.getAddedModesCount();
    }

    function getModeResponse(mode as String?) as ResponseWithDepartures {
        return _stop.getModeResponse(mode);
    }

}
