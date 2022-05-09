using Toybox.Application.Storage;

(:glance)
class StorageModel {

    private static const _STORAGE_STOP_IDS = "stop_ids";
    private static const _STORAGE_STOP_NAMES = "stop_names";

    var response;

    private var _stopIds;
    private var _stopNames;

    // init


    function initialize() {
        _load();
    }

    // set

    private function _save() {
        Storage.setValue(_STORAGE_STOP_IDS, _stopIds);
        Storage.setValue(_STORAGE_STOP_NAMES, _stopNames);
    }

    function setStops(stopIds, stopNames, stops) {
        _stopIds = stopIds;
        _stopNames = stopNames;
        response = stops;
        _save();
    }

    function setResponseError(error) {
        _stopIds = [];
        _stopNames = [];
        response = error;
    }

    function resetStops() {
        _stopIds = [];
        _stopNames = [];
        response = [];
    }

    // get

    private function _load() {
        var stopIds = Storage.getValue(_STORAGE_STOP_IDS);
        var stopNames = Storage.getValue(_STORAGE_STOP_NAMES);

        if (stopIds == null || stopNames == null) {
            resetStops();
        }
        else {
            _stopIds = stopIds;
            _stopNames = stopNames;
            response = [];

            for (var i = 0; i < _stopIds.size() && i < _stopNames.size(); i++) {
                var stop = new Stop(_stopIds[i], _stopNames[i]);
                response.add(stop);
            }
        }
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
