using Toybox.Application.Storage;
using Toybox.Lang;
using Toybox.Math;

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

    function createStop(id, name, existingNearbyStop) {
        var fav = FavoriteStopsStorage.getFavorite(id, name);
        var stop;

        if (fav != null) {
            if (fav.name.equals(name)) {
                stop = fav;
            }
            else {
                stop = new StopDouble(fav, name);
            }
        }
        // we can use `else if ` because
        // if both are non-null they refer to the same stop
        else if (existingNearbyStop != null) {
            if (existingNearbyStop.name.equals(name)) {
                stop = existingNearbyStop;
            }
            else {
                stop = new StopDouble(existingNearbyStop, name);
            }
        }
        else {
            return new Stop(id, name);
        }

        return stop;
    }

    function _buildStops(ids, names) {
        var stops = [];
        var addedIds = [];

        for (var i = 0; i < ids.size() && i < names.size(); i++) {
            var existingId = addedIds.indexOf(ids[i]);
            var existingStop = existingId != -1 ? stops[existingId] : null;
            var stop = createStop(ids[i], names[i], existingStop);

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
            setResponse([], [], new ResponseError(ResponseError.CODE_AUTO_REQUEST_LIMIT_MEMORY, null));
            return false;
        }

        return response.isTooLarge();
    }

}
