using Toybox.Application.Storage;

class FavoriteStopsStorage {

    private static const _STORAGE_FAVORITE_STOP_IDS = "favorite_stop_ids";
    private static const _STORAGE_FAVORITE_STOP_NAMES = "favorite_stop_names";

    var favorites;

    private var _favStopIds;
    private var _favStopNames;

    // init


    function initialize() {
        _load();
    }

    // set

    private function _save() {
        Storage.setValue(_STORAGE_FAVORITE_STOP_IDS, _favStopIds);
        Storage.setValue(_STORAGE_FAVORITE_STOP_NAMES, _favStopNames);
    }

    static function addFavorite(stop) {
        if (ArrCompat.in(_favStopIds, stop.id)) {
            Log.w(stop.repr() + " already in favorites");
            return;
        }

        _favStopIds.add(stop.id);
        _favStopNames.add(stop.name);
        favorites.add(stop);

        _save();
    }

    static function removeFavorite(stop) {
        var success = _favStopIds.remove(stop.id);
        success &= _favStopNames.remove(stop.name);
        success &= favorites.remove(stop);

        if (success) {
            _save();
        }
        else {
            Log.w("did not find " + stop.repr() + " in favorites");
        }
    }

    static function moveFavorite(stopId, diff) {
        var index = _favStopIds.indexOf(stopId);

        ArrCompat.swap(_favStopIds, index, index + diff);
        ArrCompat.swap(_favStopNames, index, index + diff);
        ArrCompat.swap(favorites, index, index + diff);

        _save();
    }

    // get

    private function _load() {
        _favStopIds = StorageCompat.getArray(_STORAGE_FAVORITE_STOP_IDS);
        _favStopNames = StorageCompat.getArray(_STORAGE_FAVORITE_STOP_NAMES);
        favorites = buildStops(_favStopIds, _favStopNames);
    }

    static function isFavorite(stopId) {
        return ArrCompat.in(_favStopIds, stopId);
    }

}
