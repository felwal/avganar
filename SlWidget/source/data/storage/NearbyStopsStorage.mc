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

    // set

    private function _save() {
        Storage.setValue(_STORAGE_NEARBY_STOP_IDS, _nearbyStopIds);
        Storage.setValue(_STORAGE_NEARBY_STOP_NAMES, _nearbyStopNames);
    }

    function setStops(stopIds, stopNames, stops) {
        // only vibrate when data is changed
        if (!ArrCompat.equals(_nearbyStopIds, stopIds)) {
            vibrate("stops changed to " + stopIds.toString());
        }

        _nearbyStopIds = stopIds;
        _nearbyStopNames = stopNames;

        // if we got no stops, we want to show a message, and therefore wont
        // have to set `response` twice.
        if (stopIds.size() != 0) {
            response = stops;
        }

        _save();
    }

    function setResponseError(error) {
        // only vibrate when data is changed
        if (!error.isStatusMessage() && !error.equals(response)) {
            vibrate(response.toString() + " changed to " + error.toString());
        }

        _nearbyStopIds = [];
        _nearbyStopNames = [];
        response = error;
    }

    // get

    private function _load() {
        _nearbyStopIds = StorageCompat.getArray(_STORAGE_NEARBY_STOP_IDS);
        _nearbyStopNames = StorageCompat.getArray(_STORAGE_NEARBY_STOP_NAMES);
        response = buildStops(_nearbyStopIds, _nearbyStopNames);
    }

    (:glance)
    static function getNearestStopName() {
        var arr = StorageCompat.getArray(_STORAGE_NEARBY_STOP_NAMES);
        return arr.size() > 0 ? arr[0] : null;
    }

    static function getNearestStopsNames(count) {
        return StorageCompat.getArray(_STORAGE_NEARBY_STOP_NAMES).slice(0, count);
    }

    function hasResponseError() {
        return response instanceof ResponseError;
    }

    function hasErrorOrIsEmpty() {
        return (hasResponseError() && response.isErrorMessage()) || (response instanceof Array && response.size() == 0);
    }

    function hasStops() {
        return !hasResponseError() && response != null && response.size() > 0;
    }

    function getStop(index) {
        return hasResponseError() ? null : ArrCompat.coerceGet(response, index);
    }

    function getStops() {
        return hasResponseError() ? null : response;
    }

    function getStopCount() {
        return hasResponseError() ? null : response.size();
    }

}
