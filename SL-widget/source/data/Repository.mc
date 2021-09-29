using Toybox.Application;

(:glance)
class Repository {

    private var _pos;
    private var _storage;
    private var _sl;

    //

    function initialize(pos, storage, sl) {
        _pos = pos;
        _storage = storage;
        _sl = sl;

        //_storage.resetStops(); _pos.setPosDeg(debugLat, debugLon);
    }

    // request

    function requestNearbyStopsGlance() {
        _sl.requestNearbyStopsGlance(_pos.getLatDeg(), _pos.getLonDeg());
        //_sl.requestNearbyStopsGlance(debugLat, debugLon);
    }

    function requestNearbyStopsDetail() {
        _sl.requestNearbyStopsDetail(_pos.getLatDeg(), _pos.getLonDeg());
        //_sl.requestNearbyStopsGlance(debugLat, debugLon);
    }

    function requestDeparturesGlance() {
        _sl.requestDeparturesGlance();
    }

    function requestDeparturesDetail(index) {
        _sl.stopCursorDetail = index;
        _sl.requestDeparturesDetail();
    }

    // read

    function getStopGlanceString(index) {
        return getStop(index).toGlanceString();
    }

    function getStopDetailString(stopIndex, modeIndex) {
        return getStop(stopIndex).toDetailString(modeIndex);
    }

    function getStop(index) {
        return _storage.getStop(index);
    }

    function getStopCount() {
        return _storage.getStopCount();
    }

    function getModeCount(stopIndex) {
        return getStop(stopIndex).getModeCount();
    }

    function getStopIndexRotated(index, amount) {
        return mod(index + amount, getStopCount());
    }

    function getModeIndexRotated(stopIndex, modeIndex) {
        return mod(modeIndex + 1, getModeCount(stopIndex));
    }

    // write

    function enablePositionHandlingGlance() {
        setPositionHandling(Position.LOCATION_ONE_SHOT, method(:requestNearbyStopsGlance));
    }

    function enablePositionHandlingDetail() {
        setPositionHandling(Position.LOCATION_CONTINUOUS, method(:requestNearbyStopsDetail));
    }

    function setPositionHandling(acquisitionType, onRegisterPosition) {
        // set location event listener and get last location while waiting
        _pos.enableLocationEvents(acquisitionType);
        _pos.registerLastKnownPosition(Activity.getActivityInfo());
        _pos.onRegisterPosition = onRegisterPosition;
    }

    function disablePositionHandling() {
        _pos.enableLocationEvents(Position.LOCATION_DISABLE);
        _pos.onRegisterPosition = null;
    }

    function setPlaceholderStop() {
        if (!_storage.hasStops()) {
            var message;

            if (!_pos.isPositioned()) {
                message = Application.loadResource(Rez.Strings.lbl_i_stops_locating);
            }
            else {
                message = Application.loadResource(Rez.Strings.lbl_i_stops_searching);
            }

            _storage.setPlaceholderStop(message);
        }
    }

}
