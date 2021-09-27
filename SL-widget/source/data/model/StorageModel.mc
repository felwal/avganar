import Toybox.Lang;

using Toybox.Application;
using Toybox.Application.Storage;

(:glance)
class StorageModel {

    private static const _STORAGE_STOP_IDS = "stop_ids";
    private static const _STORAGE_STOP_NAMES = "stop_names";

    private var _stopIds as Array<Number> = [];
    private var _stopNames as Array<String> = [];
    private var _stops as Array<Stop> = [];

    //

    function initialize() as Void {
        load();
    }

    // set

    private function save() as Void {
        Storage.setValue(_STORAGE_STOP_IDS, _stopIds);
        Storage.setValue(_STORAGE_STOP_NAMES, _stopNames);
    }

    function setPlaceholderStop(name as String) as Void {
        resetStops();
        _stopIds.add(Stop.NO_ID);
        _stopNames.add(name);
        _stops.add(new Stop(Stop.NO_ID, name));
    }

    function setStops(stopIds as Array<Number>, stopNames as Array<String>, stops as Array<Stop>) as Void {
        _stopIds = stopIds;
        _stopNames = stopNames;
        _stops = stops;
        save();
    }

    function resetStops() as Void {
        _stopIds = [];
        _stopNames = [];
        _stops = [];
    }

    function setJourneys(index as Number, journeys as Array<Array>) as Void {
        getStop(index).journeys = journeys;
    }

    // get

    private function load() as Void {
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

    function hasStops() as Boolean {
        return _stops != null && _stops.size() > 0 && _stops[0].id != Stop.NO_ID;
    }

    function getStop(index as Number) as Stop {
        if (index >= 0 && index < _stops.size()) {
            return _stops[index];
        }
        else {
            return Stop.placeholder(Application.loadResource(Rez.Strings.lbl_e_stops_index_oob));
        }
    }

    function getStopId(index as Number) as Number {
        if (index >= 0 && index < _stopIds.size()) {
            return _stopIds[index];
        }
        else {
            return Stop.NO_ID;
        }
    }

    function getStops() as Array<Stop> {
        return _stops;
    }

    function getStopCount() as Number {
        return _stops.size();
    }

}
