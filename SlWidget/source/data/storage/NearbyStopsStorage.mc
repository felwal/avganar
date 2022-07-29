using Toybox.Application.Storage;

(:glance)
class NearbyStopsStorage {

    private static const _STORAGE_NEARBY_STOP_IDS = "nearby_stop_ids";
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
            vibrate();
        }

        _nearbyStopIds = stopIds;
        _nearbyStopNames = stopNames;
        response = stops;
        _save();
    }

    function setResponseError(error) {
        _nearbyStopIds = [];
        _nearbyStopNames = [];
        response = error;
        vibrate();
    }

    function resetStops() {
        _nearbyStopIds = [];
        _nearbyStopNames = [];
        response = [];
    }

    // get

    private function _load() {
        _nearbyStopIds = StorageCompat.getArray(_STORAGE_NEARBY_STOP_IDS);
        _nearbyStopNames = StorageCompat.getArray(_STORAGE_NEARBY_STOP_NAMES);
        response = buildStops(_nearbyStopIds, _nearbyStopNames);
    }

    function hasResponseError() {
        return response instanceof ResponseError;
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
