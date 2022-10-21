using Toybox.Application.Storage;

class FavoriteStopsStorage extends StopsStorage {

    private static const _STORAGE_FAVORITE_STOP_IDS = "favorite_stop_ids";
    private static const _STORAGE_FAVORITE_STOP_NAMES = "favorite_stop_names";

    var favorites;

    private var _favStopIds;
    private var _favStopNames;

    // init

    function initialize() {
        StopsStorage.initialize();
        _load();
    }

    // set

    private function _save() {
        Storage.setValue(_STORAGE_FAVORITE_STOP_IDS, _favStopIds);
        Storage.setValue(_STORAGE_FAVORITE_STOP_NAMES, _favStopNames);
    }

    static function addFavorite(stop) {
        if (ArrUtil.in(_favStopIds, stop.id)) {
            Log.w(stop.repr() + " already in favorites");
            return;
        }

        _favStopIds.add(stop.id);
        _favStopNames.add(stop.name);
        favorites.add(stop);

        _save();
    }

    static function removeFavorite(stop) {
        // use index of id, to avoid situations where two different
        // stops share the same name
        var index = _favStopIds.indexOf(stop.id);

        var success = ArrUtil.removeAt(_favStopIds, index);
        success &= ArrUtil.removeAt(_favStopNames, index);
        success &= ArrUtil.removeAt(favorites, index);

        if (success) {
            _save();
        }
        else {
            Log.w("did not find " + stop.repr() + " in favorites");
        }
    }

    static function moveFavorite(stopId, diff) {
        var index = _favStopIds.indexOf(stopId);

        ArrUtil.swap(_favStopIds, index, index + diff);
        ArrUtil.swap(_favStopNames, index, index + diff);
        ArrUtil.swap(favorites, index, index + diff);

        _save();
    }

    // get

    private function _load() {
        _favStopIds = StorageUtil.getArray(_STORAGE_FAVORITE_STOP_IDS);
        _favStopNames = StorageUtil.getArray(_STORAGE_FAVORITE_STOP_NAMES);

        favorites = StopsStorage.buildStops(_favStopIds, _favStopNames);
    }

    static function isFavorite(stopId) {
        return ArrUtil.in(_favStopIds, stopId);
    }

}
