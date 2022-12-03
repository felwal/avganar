using Toybox.Application.Storage;

module FavoriteStopsStorage {

    const _STORAGE_FAVORITE_STOP_IDS = "favorite_stop_ids";
    const _STORAGE_FAVORITE_STOP_NAMES = "favorite_stop_names";

    var favorites;

    var _favStopIds;
    var _favStopNames;

    // set

    function _save() {
        Storage.setValue(_STORAGE_FAVORITE_STOP_IDS, _favStopIds);
        Storage.setValue(_STORAGE_FAVORITE_STOP_NAMES, _favStopNames);
    }

    function addFavorite(stop) {
        if (ArrUtil.contains(_favStopIds, stop.id)) {
            Log.w(stop.id + " already in favorites");
            return;
        }

        _favStopIds.add(stop.id);
        _favStopNames.add(stop.name);
        favorites.add(stop);

        _save();
    }

    function removeFavorite(stopId) {
        // use index of id, to avoid situations where two different
        // stops share the same name
        var index = _favStopIds.indexOf(stopId);

        var success = ArrUtil.removeAt(_favStopIds, index);
        success &= ArrUtil.removeAt(_favStopNames, index);
        success &= ArrUtil.removeAt(favorites, index);

        if (success) {
            _save();
        }
        else {
            Log.w("did not find stop id " + stopId + " in favorites");
        }
    }

    function moveFavorite(stopId, diff) {
        var index = _favStopIds.indexOf(stopId);

        ArrUtil.swap(_favStopIds, index, index + diff);
        ArrUtil.swap(_favStopNames, index, index + diff);
        ArrUtil.swap(favorites, index, index + diff);

        _save();
    }

    // get

    function load() {
        _favStopIds = StorageUtil.getArray(_STORAGE_FAVORITE_STOP_IDS);
        _favStopNames = StorageUtil.getArray(_STORAGE_FAVORITE_STOP_NAMES);

        favorites = _buildStops(_favStopIds, _favStopNames);
    }

    function createStop(id, name, existingNearbyStop) {
        var fav = getFavorite(id);
        var stop;

        // if both are non-null they refer to the same object
        if (fav != null) {
            stop = fav;
        }
        else if (existingNearbyStop != null) {
            stop = existingNearbyStop;
        }
        else {
            return new Stop(id, name);
        }

        // set stop name to the most recent
        //stop.name = name;

        return stop;
    }

    function _buildStops(ids, names) {
        var stops = [];

        for (var i = 0; i < ids.size() && i < names.size(); i++) {
            var stop = new Stop(ids[i], names[i]);
            stops.add(stop);
        }

        return stops;
    }

    function isFavorite(stopId) {
        return ArrUtil.contains(_favStopIds, stopId);
    }

    function getFavorite(stopId) {
        var index = _favStopIds.indexOf(stopId);

        return ArrUtil.get(favorites, index, null);
    }

}
