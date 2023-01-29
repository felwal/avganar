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
        if (ArrUtil.contains(favorites, stop)) {
            Log.w(stop.name + " already in favorites");
            return;
        }

        _favStopIds.add(stop.getId());
        _favStopNames.add(stop.name);
        favorites.add(stop);

        _save();
    }

    function removeFavorite(stop) {
        var index = favorites.indexOf(stop);

        var success = ArrUtil.removeAt(_favStopIds, index);
        success &= ArrUtil.removeAt(_favStopNames, index);
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
        ArrUtil.swap(favorites, index, index + diff);

        _save();
    }

    // get

    function load() {
        _favStopIds = StorageUtil.getArray(_STORAGE_FAVORITE_STOP_IDS);
        _favStopNames = StorageUtil.getArray(_STORAGE_FAVORITE_STOP_NAMES);

        favorites = _buildStops(_favStopIds, _favStopNames);
    }

    function _buildStops(ids, names) {
        var stops = [];
        var addedIds = [];

        for (var i = 0; i < ids.size() && i < names.size(); i++) {
            var existingId = addedIds.indexOf(ids[i]);
            var stop;

            if (existingId != -1) {
                // we got multiple favorites with the same id
                var existingStop = stops[existingId];
                stop = new StopDouble(existingStop, names[i]);
            }
            else {
                stop = new Stop(ids[i], names[i]);
                addedIds.add(ids[i]);
            }

            stops.add(stop);
        }

        return stops;
    }

    function isFavorite(stop) {
        return ArrUtil.contains(favorites, stop);
    }

    function getFavorite(stopId, stopName) {
        var index = favorites.indexOf(new StopDummy(stopId, stopName));
        Log.d("index:" + index);

        return ArrUtil.get(favorites, index, null);
    }

}
