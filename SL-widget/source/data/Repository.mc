import Toybox.Lang;

using Toybox.Application;

(:glance)
class Repository {

    private var _pos as PositionModel;
    private var _storage as StorageModel;
    private var _sl as SlApi;

    //

    function initialize(pos as PositionModel, storage as StorageModel, sl as SlApi) as Void {
        _pos = pos;
        _storage = storage;
        _sl = sl;

        //_storage.resetStops(); _pos.setPosDeg(debugLat, debugLon);
    }

    // requst

    function requestNearbyStopsGlance() as Void {
        _sl.requestNearbyStopsGlance(_pos.getLatDeg(), _pos.getLonDeg());
        //_sl.requestNearbyStopsGlance(debugLat, debugLon);
    }

    function requestNearbyStopsDetail() as Void {
        _sl.requestNearbyStopsDetail(_pos.getLatDeg(), _pos.getLonDeg());
        //_sl.requestNearbyStopsGlance(debugLat, debugLon);
    }

    function requestDeparturesGlance() as Void {
        _sl.requestDeparturesGlance();
    }

    function requestDeparturesDetail(index as Number) as Void {
        _sl.stopCursorDetail = index;
        _sl.requestDeparturesDetail();
    }

    // read

    function getStopGlanceString(index as Number) as String {
        return getStop(index).toGlanceString();
    }

    function getStopDetailString(stopIndex as Number, modeIndex as Number) as String {
        return getStop(stopIndex).toDetailString(modeIndex);
    }

    function getStop(index as Number) as Stop {
        return _storage.getStop(index);
    }

    // write

    function enablePositionHandlingGlance() as Void {
        setPositionHandling(Position.LOCATION_ONE_SHOT, method(:requestNearbyStopsGlance));
    }

    function enablePositionHandlingDetail() as Void {
        setPositionHandling(Position.LOCATION_CONTINUOUS, method(:requestNearbyStopsDetail));
    }

    function setPositionHandling(acquisitionType as Number, onRegisterPosition as Method) as Void {
        // set location event listener and get last location while waiting
        _pos.enableLocationEvents(acquisitionType);
        _pos.registerLastKnownPosition(Activity.getActivityInfo());
        _pos.onRegisterPosition = onRegisterPosition;
    }

    function disablePositionHandling() as Void {
        _pos.enableLocationEvents(Position.LOCATION_DISABLE);
        _pos.onRegisterPosition = null;
    }

    function setPlaceholderStop() as Void {
        if (!_storage.hasStops()) {
            var message as String;

            if (!_pos.isPositioned()) {
                message = Application.loadResource(Rez.Strings.lbl_i_stops_locating);
            }
            else {
                message = Application.loadResource(Rez.Strings.lbl_i_stops_searching);
            }

            _storage.setPlaceholderStop(message);
        }
    }

    // tool

    function getStopIndexRotated(index as Number, amount as Number) as Number {
        var stopCount = _storage.getStopCount();
        return mod(index + amount, stopCount);
    }

    function getModeIndexRotated(stopIndex as Number, modeIndex as Number) as Number {
        var modeCount = _storage.getStop(stopIndex).getModeCount();
        return mod(modeIndex + 1, modeCount);
    }

}
