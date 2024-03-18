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

//! Handles storage for favorite stops.
module FavoriteStopsStorage {

    const _STORAGE_FAVORITE_STOP_IDS = "favorite_stop_ids";
    const _STORAGE_FAVORITE_STOP_NAMES = "favorite_stop_names";
    const _STORAGE_FAVORITE_STOP_PRODUCTS = "favorite_stop_products";

    var favorites;

    var _favStopIds;
    var _favStopNames;
    var _favStopProducts;

    // set

    function _save() {
        Storage.setValue(_STORAGE_FAVORITE_STOP_IDS, _favStopIds);
        Storage.setValue(_STORAGE_FAVORITE_STOP_NAMES, _favStopNames);
        Storage.setValue(_STORAGE_FAVORITE_STOP_PRODUCTS, _favStopProducts);
    }

    function addFavorite(stop) {
        if (ArrUtil.contains(favorites, stop)) {
            Log.w(stop.name + " already in favorites");
            return;
        }

        _favStopIds.add(stop.getId());
        _favStopNames.add(stop.name);
        _favStopProducts.add(stop.getProducts());
        favorites.add(stop);

        _save();
    }

    function removeFavorite(stop) {
        var index = favorites.indexOf(stop);

        var success = ArrUtil.removeAt(_favStopIds, index);
        success &= ArrUtil.removeAt(_favStopNames, index);
        success &= ArrUtil.removeAt(_favStopProducts, index);
        success &= ArrUtil.removeAt(favorites, index);

        if (success) {
            _save();
        }
        else {
            Log.w("did not find stop id " + stop.getId() + " in favorites");
        }
    }

    function moveFavorite(stop, diff) {
        var index = favorites.indexOf(stop);

        ArrUtil.swap(_favStopIds, index, index + diff);
        ArrUtil.swap(_favStopNames, index, index + diff);
        ArrUtil.swap(_favStopProducts, index, index + diff);
        ArrUtil.swap(favorites, index, index + diff);

        _save();
    }

    // get

    function load() {
        _favStopIds = StorageUtil.getArray(_STORAGE_FAVORITE_STOP_IDS);
        _favStopNames = StorageUtil.getArray(_STORAGE_FAVORITE_STOP_NAMES);
        _favStopProducts = StorageUtil.getValue(_STORAGE_FAVORITE_STOP_PRODUCTS,
            ArrUtil.filled(_favStopIds.size(), null));

        favorites = _buildStops(_favStopIds, _favStopNames, _favStopProducts);
    }

    function _buildStops(ids, names, products) {
        var stops = [];
        var addedIds = [];

        for (var i = 0; i < ids.size() && i < names.size(); i++) {
            // shouldn't happen, but just in case
            var products_ = i < products.size() ? products[i] : null;

            var existingId = addedIds.indexOf(ids[i]);
            var stop;

            if (existingId != -1) {
                // we got multiple favorites with the same id
                var existingStop = stops[existingId];
                stop = new StopDouble(existingStop, names[i]);
            }
            else {
                stop = new Stop(ids[i], names[i], products_);
                addedIds.add(ids[i]);
            }

            stops.add(stop);
        }

        return stops;
    }

    function isFavorite(stop) {
        return ArrUtil.contains(favorites, stop);
    }

    function getFavoriteById(stopId) {
        var index = _favStopIds.indexOf(stopId);
        return ArrUtil.get(favorites, index, null);
    }

    function getFavorite(stopId, stopName) {
        var index = favorites.indexOf(new StopDummy(stopId, stopName));
        return ArrUtil.get(favorites, index, null);
    }

}
