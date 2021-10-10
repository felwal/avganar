using Toybox.Application.Storage;

(:glance)
class StorageModel {

    private static const _STORAGE_STOP_IDS = "stop_ids";
    private static const _STORAGE_STOP_NAMES = "stop_names";

    private var _stopIds = [];
    private var _stopNames = [];
    private var _stops = [];

    // init


    function initialize() {
        _load();
    }

    // set

    private function _save() {
        Storage.setValue(_STORAGE_STOP_IDS, _stopIds);
        Storage.setValue(_STORAGE_STOP_NAMES, _stopNames);
    }

    function setPlaceholderStop(errorCode, msg) {
        resetStops();
        _stopIds.add(Stop.NO_ID);
        _stopNames.add(msg);
        _stops.add(Stop.placeholder(errorCode, msg));
    }

    function setPlaceholderDeparture(stopIndex, errorCode, msg) {
        getStop(stopIndex).setDepartures([ [ Departure.placeholder(errorCode, msg) ] ]);
    }

    function setStops(stopIds, stopNames, stops) {
        _stopIds = stopIds;
        _stopNames = stopNames;
        _stops = stops;
        _save();
    }

    function resetStops() {
        _stopIds = [];
        _stopNames = [];
        _stops = [];
    }

    // get

    private function _load() {
        var stopIds = Storage.getValue(_STORAGE_STOP_IDS);
        var stopNames = Storage.getValue(_STORAGE_STOP_NAMES);

        if (stopIds == null || stopNames == null) {
            return;
        }
        _stopIds = stopIds;
        _stopNames = stopNames;

        for (var i = 0; i < _stopIds.size() && i < _stopNames.size(); i++) {
            var stop = new Stop(_stopIds[i], _stopNames[i]);
            _stops.add(stop);
        }
    }

    function hasStops() {
        return _stops != null && _stops.size() > 0 && _stops[0].id != Stop.NO_ID;
    }

    function getStop(index) {
        return ArrCompat.coerceGet(_stops, index);
    }

    function getStopId(index) {
        return ArrCompat.coerceGet(_stopIds, index);
    }

    function getStops() {
        return _stops;
    }

    function getStopCount() {
        return _stops.size();
    }

}
