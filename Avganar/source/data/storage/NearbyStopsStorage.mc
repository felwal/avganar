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
    //! depending on if it already exists with `id` or `id` and `name`
    function createStop(id, name, addedStopIds, addedStops) {
        // we need to consider all existing stops, since
        // "id1 name1" should return existing "id1 name1" over "id1 name2"
        var addedStopsWithSameIdIndices = ArrUtil.indicesOf(addedStopIds, id);
        var addedStopsWithSameId = ArrUtil.getAll(addedStops, addedStopsWithSameIdIndices);

        var favStopWithSameId = FavoriteStopsStorage.getFavorite(id, name);
        var previousStopsWithSameId = getStopByIdAndName(id, name);

        // check if stop already exists as nearby
        if (addedStopsWithSameId.size() != 0) {
            for (var i = 0; i < addedStopsWithSameId.size(); i++) {
                if (addedStopsWithSameId[i].name.equals(name)) {
                    // ignore duplicates of both id and name.
                    // takes priority over creating a double.
                    return null;
                }
            }

            // create a double if same id but different name.
            // doesn't matter which one we take, since all have the same id
            return new StopDouble(addedStopsWithSameId[0], name);
        }

        // check if stop already exists as favorite
        else if (favStopWithSameId != null) {
            if (favStopWithSameId.name.equals(name)) {
                // use existing stop if same id and name
                return favStopWithSameId;
            }
            else {
                // create a double if same id but different name
                return new StopDouble(favStopWithSameId, name);
            }
        }

        // check if stop exists as nearby in last response
        else if (previousStopsWithSameId != null) {
            if (previousStopsWithSameId.name.equals(name)) {
                // use existing stop if same id and name
                return previousStopsWithSameId;
            }
            else {
                // create a double if same id but different name
                return new StopDouble(previousStopsWithSameId, name);
            }
        }

        // if no existing stops of same id, create new stop
        return new Stop(id, name);
    }

    function _buildStops(ids, names) {
        var addedStops = [];
        var addedIds = [];
        var addedNames = [];

        for (var i = 0; i < ids.size() && i < names.size(); i++) {
            // null if duplicate
            var stop = createStop(ids[i], names[i], addedIds, addedStops);
            if (stop == null) {
                continue;
            }

            addedStops.add(stop);
            addedIds.add(ids[i]);
            addedNames.add(names[i]);
        }

        // also update these: if some of the stops were null (duplicates),
        // we don't want to keep the ids or names associated with those either.
        _nearbyStopIds = addedIds;
        _nearbyStopNames = addedNames;

        return addedStops;
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
