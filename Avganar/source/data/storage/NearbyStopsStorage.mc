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
    const _STORAGE_NEARBY_STOP_PRODUCTS = "nearby_stop_products";

    const _MEMORY_MIN_MAX_STOPS = 1;

    var response;
    var maxStops;
    var failedRequestCount = 0;

    var _nearbyStopIds;
    var _nearbyStopNames;
    var _nearbyStopProducts;

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
        Storage.setValue(_STORAGE_NEARBY_STOP_PRODUCTS, _nearbyStopProducts);
    }

    function setResponseError(responseError) {
        setResponse([], [], [], responseError);
    }

    //! The response is represented by:
    //! - `Array<Stop>` - success
    //! - `ResponseError` - error
    //! - `String` - response message (e.g. "No Stops")
    //! - `null` - status message (e.g. "Loading ...", determined in `StopListViewModel#getMessage`)
    function setResponse(stopIds, stopNames, stopProducts, response_) {
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

            // only vibrate if we are not auto-refreshing and data is changed
            if (!ArrUtil.equals(_nearbyStopIds, stopIds)
                || ((response_ instanceof ResponseError || response_ instanceof Lang.String)
                && !response_.equals(response))) {

                SystemUtil.vibrateLong();
            }
        }

        _nearbyStopIds = stopIds;
        _nearbyStopNames = stopNames;
        _nearbyStopProducts = stopProducts;
        response = response_;

        _save();
    }

    // get

    function load() {
        _nearbyStopIds = StorageUtil.getArray(_STORAGE_NEARBY_STOP_IDS);
        _nearbyStopNames = StorageUtil.getArray(_STORAGE_NEARBY_STOP_NAMES);
        _nearbyStopProducts = StorageUtil.getValue(_STORAGE_NEARBY_STOP_PRODUCTS,
            ArrUtil.filled(_nearbyStopIds.size(), null));

        response = _nearbyStopIds.size() == 0
            ? null
            : _buildStops(_nearbyStopIds, _nearbyStopNames, _nearbyStopProducts);
    }

    //! Create a new stop, a `StopDouble`, refer to another, or return `null`
    //! depending on if it already exists with `id` or `id` and `name`
    function createStop(id, name, products, addedStops, addedStopIds, addedStopNames) {
        // we need to consider all already added stops, since
        // "id1 name1" should return existing "id1 name1" over "id1 name2"
        var addedStopsWithSameIdIndices = ArrUtil.indicesOf(addedStopIds, id);
        var addedStopsWithSameId = ArrUtil.getAll(addedStops, addedStopsWithSameIdIndices);

        // check if stop already exists as nearby
        if (addedStopsWithSameId.size() != 0) {
            for (var i = 0; i < addedStopsWithSameId.size(); i++) {
                if (addedStopsWithSameId[i].name.equals(name)) {
                    // ignore duplicates of both id and name.
                    // takes priority over creating a double.
                    return null;
                }

                // check for supernames and subnames, eg "Odenplan Vasagatan" and "Odenplan"
                // – keep the smallest name
                else if (name.find(addedStopsWithSameId[i].name) != null) {
                    // new name is supername of already added
                    // – keep that
                    return null;
                }
                else if (addedStopsWithSameId[i].name.find(name) != null) {
                    // new name is subname of already added
                    // – keep this (in practice, just rename that)
                    var ind = addedStops.indexOf(addedStopsWithSameId[i]);
                    if (ind == -1) {
                        continue;
                    }

                    addedStopsWithSameId[i].name = name; // same as addedStops[ind]
                    addedStopNames[ind] = name;
                    return null;
                }
            }

            // create a double if same id but different name.
            // doesn't matter which one we take, since all have the same id
            return new StopDouble(addedStopsWithSameId[0], name);
        }

        var favStopWithSameId = FavoriteStopsStorage.getFavoriteById(id);

        // check if stop already exists as favorite
        if (favStopWithSameId != null) {
            // NOTE: migration to 1.8.0
            // always update favs' products when they are nearby
            FavoriteStopsStorage.updateFavoriteProducts(id, products);

            if (favStopWithSameId.name.equals(name)) {
                // use existing stop if same id and name
                return favStopWithSameId;
            }
            else {
                // create a double if same id but different name
                return new StopDouble(favStopWithSameId, name);
            }
        }

        var previousStopWithSameId = getStopById(id);

        // check if stop exists as nearby in last response
        if (previousStopWithSameId != null) {
            // NOTE: migration to 1.8.0
            // make sure we don't pass along old null products
            previousStopWithSameId.setProducts(products);

            // use existing stop if same id
            if (!previousStopWithSameId.name.equals(name)) {
                // just rename if different name
                // – we don't want StopDoubles of previous stops
                previousStopWithSameId.name = name;
            }
            return previousStopWithSameId;
        }

        // if no existing stops of same id, create new stop
        return new Stop(id, name, products);
    }

    function _buildStops(ids, names, products) {
        var addedStops = [];
        var addedIds = [];
        var addedNames = [];
        var addedProducts = [];

        for (var i = 0; i < ids.size() && i < names.size(); i++) {
            // shouldn't happen, but just in case. TODO: remove?
            var products_ = i < products.size() ? products[i] : null;

            // null if duplicate
            var stop = createStop(ids[i], names[i], products_, addedStops, addedIds, addedNames);
            if (stop == null) {
                continue;
            }

            addedStops.add(stop);
            addedIds.add(ids[i]);
            addedNames.add(names[i]);
            addedProducts.add(products_);
        }

        // also update these: if some of the stops were null (duplicates),
        // we don't want to keep the ids or names associated with those either.
        _nearbyStopIds = addedIds;
        _nearbyStopNames = addedNames;
        _nearbyStopProducts = addedProducts;

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

    function getStopById(id) {
        if (!(response instanceof Lang.Array)) {
            return null;
        }

        var index = _nearbyStopIds.indexOf(id);
        return ArrUtil.get(response, index, null);
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

    function shouldAutoRefresh() {
        if (!(response instanceof ResponseError)) {
            return false;
        }

        if (maxStops < _MEMORY_MIN_MAX_STOPS) {
            setResponseError(new ResponseError(ResponseError.CODE_AUTO_REQUEST_LIMIT_MEMORY));
            return false;
        }

        return response.isTooLarge();
    }

}
