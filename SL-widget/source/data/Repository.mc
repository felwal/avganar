using Toybox.Application;

(:glance)
class Repository {

    private var _position;
    private var _storage;
    private var _api;

    // init

    function initialize(position, storage, api) {
        _position = position;
        _storage = storage;
        _api = api;

        //_storage.resetStops(); _position.setPosDeg(debugLat, debugLon);
    }

    // request

    function requestNearbyStopsGlance() {
        _api.requestNearbyStopsGlance(_position.getLatDeg(), _position.getLonDeg());
        //_api.requestNearbyStopsGlance(debugLat, debugLon);
    }

    function requestNearbyStopsDetail() {
        _api.requestNearbyStopsDetail(_position.getLatDeg(), _position.getLonDeg());
        //_api.requestNearbyStopsGlance(debugLat, debugLon);
    }

    function requestDeparturesGlance() {
        _api.requestDeparturesGlance();
    }

    function requestDeparturesDetail(index) {
        _api.stopCursorDetail = index;
        _api.requestDeparturesDetail();
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
        setPositionHandling(Position.LOCATION_ONE_SHOT, method(:requestNearbyStopsDetail));
    }

    function setPositionHandling(acquisitionType, onRegisterPosition) {
        // set location event listener and get last location while waiting
        _position.enableLocationEvents(acquisitionType);
        _position.registerLastKnownPosition(Activity.getActivityInfo());
        _position.onRegisterPosition = onRegisterPosition;
    }

    function disablePositionHandling() {
        _position.enableLocationEvents(Position.LOCATION_DISABLE);
        _position.onRegisterPosition = null;
    }

    function setPlaceholderStop() {
        if (!_storage.hasStops()) {
            var message;

            if (!_position.isPositioned()) {
                message = Application.loadResource(Rez.Strings.lbl_i_stops_locating);
            }
            else {
                message = Application.loadResource(Rez.Strings.lbl_i_stops_searching);
            }

            _storage.setPlaceholderStop(message);
        }
    }

}
