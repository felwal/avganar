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

//! NOTE: API limitation
//! The StopDouble represents a stop which has the same
//! id as another stop, but different name.
//! Since the ids are the same, they should present the same content.
//!
//! Must have the same interface as `Stop` since we often don't
//! know whether our stops are of `Stop` or `StopDouble`.
class StopDouble {

    var name;

    hidden var _stop;

    // init

    function initialize(stop, name) {
        _stop = stop instanceof Stop ? stop : stop.getRootStop();
        me.name = name;
    }

    function equals(other) {
        return (other instanceof Stop || other instanceof StopDouble || other instanceof StopDummy)
            && other.getId() == getId() && other.name.equals(name);
    }

    function getRootStop() {
        return _stop instanceof Stop ? _stop : _stop.getRootStop();
    }

    // set

    function setProducts(products) {
        _stop.setProducts(products);
    }

    function setResponse(mode, response) {
        _stop.setResponse(mode, response);
    }

    function resetResponse(mode) {
        _stop.resetResponse(mode);
    }

    function resetResponses() {
        _stop.resetResponses();
    }

    function resetResponseErrors() {
        _stop.resetResponseErrors();
    }

    function setDeviation(message) {
        _stop.setDeviation(message);
    }

    // get

    function getId() {
        return _stop.getId();
    }

    function getProducts() {
        return _stop.getProducts();
    }

    function hasResponse(mode) {
        return _stop.hasResponse(mode);
    }

    function getResponse(mode) {
        return _stop.getResponse(mode);
    }

    function getFailedRequestCount(mode) {
        return _stop.getFailedRequestCount(mode);
    }

    function getTimeWindow(mode) {
        return _stop.getTimeWindow(mode);
    }

    function getDeviationMessages() {
        return _stop.getDeviationMessages();
    }

    function shouldAutoRefresh(mode) {
        return _stop.shouldAutoRefresh(mode);
    }

    function getDataAgeMillis(mode) {
        return _stop.getDataAgeMillis(mode);
    }

    function getModeKey(index) {
        return _stop.getModeKey(index);
    }

    function getModesKeys() {
        return _stop.getModesKeys();
    }

    function getModesStrings() {
        return _stop.getModesStrings();
    }

    function getModesCount() {
        return _stop.getModesCount();
    }

    function getAddedModesCount() {
        return _stop.getAddedModesCount();
    }

    function getModeResponse(mode) {
        return _stop.getModeResponse(mode);
    }

}
