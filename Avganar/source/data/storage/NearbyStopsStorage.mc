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

using Toybox.Application.Storage;
using Toybox.Lang;
using Toybox.Math;

//! Handles storage for nearby stops.
//! We want to persist these between sessions to achieve continuity
//! and avoid redundant API requests.
module NearbyStopsStorage {

    const _STORAGE_NEARBY_STOP_IDS = "nearby_stop_ids";
    (:glance)
    const _STORAGE_NEARBY_STOP_NAMES = "nearby_stop_names";

    const _MEMORY_MIN_MAX_STOPS = 1;

    var response;
    var maxStops;
    var failedRequestCount = 0;

    var _nearbyStopIds;
    var _nearbyStopNames;

    // static

    (:glance)
    function getNearestStopName() {
        var arr = StorageUtil.getArray(_STORAGE_NEARBY_STOP_NAMES);
        return ArrUtil.get(arr, 0, null);
    }

    // set

    function _save() {
        Storage.setValue(_STORAGE_NEARBY_STOP_IDS, _nearbyStopIds);
        Storage.setValue(_STORAGE_NEARBY_STOP_NAMES, _nearbyStopNames);
    }

    //! The response is represented by:
    //! - `Array<Stop>` - success
    //! - `ResponseError` - error
    //! - `String` - response message (e.g. "No Stops")
    //! - `null` - status message (e.g. "Loading ...", determined in `StopListViewModel#getMessage`)
    function setResponse(stopIds, stopNames, response_) {
        // for each too large response, halve the time window
        if (response_ instanceof ResponseError && response_.isTooLarge()) {
            maxStops = Math.ceil(maxStops == null
                ? SettingsStorage.getMaxStops() / 2f
                : maxStops / 2f).toNumber();

            failedRequestCount++;
        }
        else {
            // reset maxStops for next request, which will be
            // at a different place
            maxStops = SettingsStorage.getMaxStops();
            failedRequestCount = 0;

            // only vibrate if we are not auto-rerequesting and data is changed
            if (!ArrUtil.equals(_nearbyStopIds, stopIds)
                || ((response_ instanceof ResponseError || response_ instanceof Lang.String) && !response_.equals(response))) {

                vibrate();
            }
        }

        _nearbyStopIds = stopIds;
        _nearbyStopNames = stopNames;
        response = response_;

        _save();
    }

    // get

    function load() {
        _nearbyStopIds = StorageUtil.getArray(_STORAGE_NEARBY_STOP_IDS);
        _nearbyStopNames = StorageUtil.getArray(_STORAGE_NEARBY_STOP_NAMES);

        response = _nearbyStopIds.size() == 0 ? null : _buildStops(_nearbyStopIds, _nearbyStopNames);
    }

    //! Create a new stop, a `StopDouble`, refer to another, or return `null`
    //! depending on if it already exists with `id` and `name`
    function createStop(id, name, currentlyNearbyStops) {
        var fav = FavoriteStopsStorage.getFavorite(id, name);
        var previouslyNearbyStop = getStopByIdAndName(id, name);

        // check if stop already exists as nearby
        if (currentlyNearbyStops.size() != 0) {
            var stopDouble = null;

            for (var i = 0; i < currentlyNearbyStops.size(); i++) {
                if (currentlyNearbyStops[i].name.equals(name)) {
                    // ignore duplicates of both id and name.
                    // takes priority over creating a double.
                    return null;
                }
                else if (stopDouble == null) {
                    // create a double if same id but different name
                    stopDouble = new StopDouble(currentlyNearbyStops[i], name);
                }
            }

            return stopDouble;
        }
        // check if stop already exists as favorite
        else if (fav != null) {
            if (fav.name.equals(name)) {
                // use existing stop if same id and name
                return fav;
            }
            else {
                // create a double if same id but different name
                return new StopDouble(fav, name);
            }
        }
        // check if stop exists as nearby in last response
        else if (previouslyNearbyStop != null) {
            if (previouslyNearbyStop.name.equals(name)) {
                // use existing stop if same id and name
                return previouslyNearbyStop;
            }
            else {
                // create a double if same id but different name
                return new StopDouble(previouslyNearbyStop, name);
            }
        }

        // if no existing stops of same id, create new stop
        return new Stop(id, name);
    }

    function _buildStops(ids, names) {
        var stops = [];
        var addedIds = [];

        for (var i = 0; i < ids.size() && i < names.size(); i++) {
            var existingIdIndices = ArrUtil.indexOfAll(addedIds, ids[i]);
            var existingStops = ArrUtil.getAll(stops, existingIdIndices);
            var stop = createStop(ids[i], names[i], existingStops);

            stops.add(stop);
            addedIds.add(ids[i]);
        }

        return stops;
    }

    function hasStops() {
        return getStopCount() > 0;
    }

    function getStopCount() {
        return response instanceof Lang.Array ? response.size() : 0 ;
    }

    function getStop(index) {
        return response instanceof Lang.Array ? ArrUtil.coerceGet(response, index) : null;
    }

    function getStopByIdAndName(id, name) {
        if (!(response instanceof Lang.Array)) {
            return null;
        }

        var index = response.indexOf(new StopDummy(id, name));
        return ArrUtil.get(response, index, null);
    }

    function getStops() {
        return response instanceof Lang.Array ? response : null;
    }

    function shouldAutoRerequest() {
        if (!(response instanceof ResponseError)) {
            return false;
        }

        if (maxStops < _MEMORY_MIN_MAX_STOPS) {
            setResponse([], [], new ResponseError(ResponseError.CODE_AUTO_REQUEST_LIMIT_MEMORY));
            return false;
        }

        return response.isTooLarge();
    }

}
