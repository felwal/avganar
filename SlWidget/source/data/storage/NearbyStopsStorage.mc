using Toybox.Application.Storage;

class NearbyStopsStorage {

    private static const _STORAGE_NEARBY_STOP_IDS = "nearby_stop_ids";
    (:glance)
    private static const _STORAGE_NEARBY_STOP_NAMES = "nearby_stop_names";

    var response;

    private var _stopFactory;

    private var _nearbyStopIds;
    private var _nearbyStopNames;

    // init

    function initialize(stopFactory) {
        _stopFactory = stopFactory;
        _load();
    }

    // static

    (:glance)
    static function getNearestStopName() {
        var arr = StorageUtil.getArray(_STORAGE_NEARBY_STOP_NAMES);
        return ArrUtil.get(arr, 0, null);
    }

    static function getNearestStopsNames(count) {
        return StorageUtil.getArray(_STORAGE_NEARBY_STOP_NAMES).slice(0, count);
    }

    // set

    private function _save() {
        Storage.setValue(_STORAGE_NEARBY_STOP_IDS, _nearbyStopIds);
        Storage.setValue(_STORAGE_NEARBY_STOP_NAMES, _nearbyStopNames);
    }

    function setResponse(stopIds, stopNames, response_) {
        // only vibrate when data is changed
        if (!ArrUtil.equals(_nearbyStopIds, stopIds)
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
        _nearbyStopIds = StorageUtil.getArray(_STORAGE_NEARBY_STOP_IDS);
        _nearbyStopNames = StorageUtil.getArray(_STORAGE_NEARBY_STOP_NAMES);

        response = new StopsResponse(_buildStops(_nearbyStopIds, _nearbyStopNames));
    }

    private function _buildStops(ids, names) {
        var stops = [];

        for (var i = 0; i < ids.size() && i < names.size(); i++) {
            var stop = _stopFactory.createStop(ids[i], names[i], null, null);
            stops.add(stop);
        }

        return stops;
    }

    function hasStopsResponse() {
        return response instanceof StopsResponse;
    }

    function hasStops() {
        return getStopCount() > 0;
    }

    function getStopCount() {
        return hasStopsResponse() ? response.getStopCount() : 0 ;
    }

    function getStop(index) {
        return hasStopsResponse() ? response.getStop(index) : null;
    }

    function getStopById(id) {
        var index = _nearbyStopIds.indexOf(id);

        return hasStopsResponse() ? ArrUtil.get(response.getStops(), index, null) : null;
    }

    function getStops() {
        return hasStopsResponse() ? response.getStops() : null;
    }

}
