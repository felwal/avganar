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

    function setResponse(response) {
        _stop.setResponse(response);
    }

    function resetResponse() {
        _stop.resetResponse();
    }

    function resetResponseError() {
        _stop.resetResponseError();
    }

    function setDeviation(message) {
        _stop.setDeviation(message);
    }

    // get

    function getId() {
        return _stop.getId();
    }

    function getResponse() {
        return _stop.getResponse();
    }

    function getFailedRequestCount() {
        return _stop.getFailedRequestCount();
    }

    function getTimeWindow() {
        return _stop.getTimeWindow();
    }

    function getDeviationMessages() {
        return _stop.getDeviationMessages();
    }

    function shouldAutoRefresh() {
        return _stop.shouldAutoRefresh();
    }

    function getDataAgeMillis() {
        return _stop.getDataAgeMillis();
    }

    function getModeCount() {
        return _stop.getModeCount();
    }

    function getModeResponse(mode) {
        return _stop.getModeResponse(mode);
    }

    function getModeSymbol(mode) {
        return _stop.getModeSymbol(mode);
    }

}
