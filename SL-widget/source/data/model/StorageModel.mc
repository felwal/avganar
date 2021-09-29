using Toybox.Application;
using Toybox.Application.Storage;

(:glance)
class StorageModel {

    private static const _STORAGE_STOP_IDS = "stop_ids";
    private static const _STORAGE_STOP_NAMES = "stop_names";

    private var _stopIds = [];
    private var _stopNames = [];
    private var _stops = [];

    //


    function initialize() {
        _load();
    }

    // set

    private function _save() {
        Storage.setValue(_STORAGE_STOP_IDS, _stopIds);
        Storage.setValue(_STORAGE_STOP_NAMES, _stopNames);
    }

    function setPlaceholderStop(name) {
        resetStops();
        _stopIds.add(Stop.NO_ID);
        _stopNames.add(name);
        _stops.add(new Stop(Stop.NO_ID, name));
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
        if (index >= 0 && index < _stops.size()) {
            return _stops[index];
        }
        else {
            return _stops[_stops.size() - 1];
            //return Stop.placeholder(Application.loadResource(Rez.Strings.lbl_e_stops_index_oob));
        }
    }

    function getStopId(index) {
        if (index >= 0 && index < _stopIds.size()) {
            return _stopIds[index];
        }
        else {
            return Stop.NO_ID;
        }
    }

    function getStops() {
        return _stops;
    }

    function getStopCount() {
        return _stops.size();
    }

}
