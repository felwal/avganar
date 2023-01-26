using Toybox.Application.Storage;
using Toybox.Lang;

module NearbyStopsStorage {

    const _STORAGE_NEARBY_STOP_IDS = "nearby_stop_ids";
    (:glance)
    const _STORAGE_NEARBY_STOP_NAMES = "nearby_stop_names";

    var response;
    var isResponseCurrent = false;

    var _nearbyStopIds;
    var _nearbyStopNames;

    // static

    (:glance)
    function getNearestStopName() {
        var arr = StorageUtil.getArray(_STORAGE_NEARBY_STOP_NAMES);
        return ArrUtil.get(arr, 0, null);
    }

    function getNearestStopsNames(count) {
        return StorageUtil.getArray(_STORAGE_NEARBY_STOP_NAMES).slice(0, count);
    }

    // set

    function _save() {
        Storage.setValue(_STORAGE_NEARBY_STOP_IDS, _nearbyStopIds);
        Storage.setValue(_STORAGE_NEARBY_STOP_NAMES, _nearbyStopNames);
    }

    function setResponse(stopIds, stopNames, response_) {
        // only vibrate when data is changed
        if (!ArrUtil.equals(_nearbyStopIds, stopIds)
            || ((response_ instanceof ResponseError || response_ instanceof Lang.String) && !response_.equals(response))) {

            vibrate();
        }

        _nearbyStopIds = stopIds;
        _nearbyStopNames = stopNames;
        response = response_;
        isResponseCurrent = true;

        _save();
    }

    // get

    function load() {
        _nearbyStopIds = StorageUtil.getArray(_STORAGE_NEARBY_STOP_IDS);
        _nearbyStopNames = StorageUtil.getArray(_STORAGE_NEARBY_STOP_NAMES);

        response = _nearbyStopIds.size() == 0 ? null : _buildStops(_nearbyStopIds, _nearbyStopNames);
    }

    function _buildStops(ids, names) {
        var stops = [];

        for (var i = 0; i < ids.size() && i < names.size(); i++) {
            var stop = FavoriteStopsStorage.createStop(ids[i], names[i], null);
            stops.add(stop);
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

    function getStopById(id) {
        var index = _nearbyStopIds.indexOf(id);

        return response instanceof Lang.Array ? ArrUtil.get(response, index, null) : null;
    }

    function getStops() {
        return response instanceof Lang.Array ? response : null;
    }

}
