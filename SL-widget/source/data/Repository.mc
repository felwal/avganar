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
        
        _pos.setLatDeg(debugLat); _pos.setLonDeg(debugLon);
    }

    // requst

    function requestNearbyStopsGlance() {
        _sl.requestNearbyStopsGlance(_pos.getLatDeg(), _pos.getLonDeg());
    }

    function requestNearbyStopsDetail() {
        _sl.requestNearbyStopsDetail(_pos.getLatDeg(), _pos.getLonDeg());
    }

    function requestDeparturesGlance() {
        _sl.requestDeparturesGlance(_storage.getStopId(0));
    }

    function requestDeparturesDetail(index) {
        _sl.requestDeparturesDetail(_storage.getStopId(index));
    }

    // read

    function getStopGlanceString(index) {
        return getStop(index).toGlanceString();
    }

    function getStopDetailString(index) {
        return getStop(index).toDetailString();
    }

    function getStop(index) {
        return _storage.getStop(index);
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
        if (!_pos.isPositioned()) {
            _storage.setPlaceholderStop(Application.loadResource(Rez.Strings.lbl_i_stops_locating));
        }
        else if (!_storage.hasStops()) {
            _storage.setPlaceholderStop(Application.loadResource(Rez.Strings.lbl_i_stops_searching));
        }
    }

}
