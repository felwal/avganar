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

    function addFavorite(stop) {
        if (ArrUtil.in(_favStopIds, stop.id)) {
            Log.w(stop.repr() + " already in favorites");
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

    private function _load() {
        _favStopIds = StorageUtil.getArray(_STORAGE_FAVORITE_STOP_IDS);
        _favStopNames = StorageUtil.getArray(_STORAGE_FAVORITE_STOP_NAMES);

        favorites = _buildStops(_favStopIds, _favStopNames);
    }

    private function _buildStops(ids, names) {
        var stops = [];

        for (var i = 0; i < ids.size() && i < names.size(); i++) {
            var stop = new Stop(ids[i], names[i], null);
            stops.add(stop);
        }

        return stops;
    }

    function isFavorite(stopId) {
        return ArrUtil.in(_favStopIds, stopId);
    }

    function getFavorite(stopId) {
        var index = _favStopIds.indexOf(stopId);

        return ArrUtil.get(favorites, index, null);
    }

}