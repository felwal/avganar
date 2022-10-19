using Toybox.Application.Storage;

class NearbyStopsStorage {

    private static const _STORAGE_NEARBY_STOP_IDS = "nearby_stop_ids";
    (:glance)
    private static const _STORAGE_NEARBY_STOP_NAMES = "nearby_stop_names";

    var response;

    private var _nearbyStopIds;
    private var _nearbyStopNames;

    // init

    function initialize() {
        _load();
    }

    // static

    (:glance)
    static function getNearestStopName() {
        var arr = StorageCompat.getArray(_STORAGE_NEARBY_STOP_NAMES);
        return arr.size() > 0 ? arr[0] : null;
    }

    static function getNearestStopsNames(count) {
        return StorageCompat.getArray(_STORAGE_NEARBY_STOP_NAMES).slice(0, count);
    }

    // set

    private function _save() {
        Storage.setValue(_STORAGE_NEARBY_STOP_IDS, _nearbyStopIds);
        Storage.setValue(_STORAGE_NEARBY_STOP_NAMES, _nearbyStopNames);
    }

    function setResponse(stopIds, stopNames, response_) {
        // only vibrate when data is changed
        if (!ArrCompat.equals(_nearbyStopIds, stopIds)
            || ((response_ instanceof ResponseError || response_ instanceof ResponseMessage)
            && !response_.equals(response))) {

            vibrate("stops changed to " + stopIds.toString());
        }

        _nearbyStopIds = stopIds;
        _nearbyStopNames = stopNames;
        response = response_;

        _save();
    }

    // get

    private function _load() {
        _nearbyStopIds = StorageCompat.getArray(_STORAGE_NEARBY_STOP_IDS);
        _nearbyStopNames = StorageCompat.getArray(_STORAGE_NEARBY_STOP_NAMES);
        response = new StopsResponse(buildStops(_nearbyStopIds, _nearbyStopNames));
    }

    function hasStopsResponse() {
        return response instanceof StopsResponse;
    }

    function hasErrorOrIsEmpty() {
        return response instanceof ResponseError || getStopCount() == 0;
    }

    function hasStops() {
        return getStopCount() > 0;
    }

    function getStop(index) {
        return hasStopsResponse() ? response.getStop(index) : null;
    }

    function getStops() {
        return hasStopsResponse() ? response.getStops() : null;
    }

    function getStopCount() {
        return hasStopsResponse() ? response.getStopCount() : 0 ;
    }

}
