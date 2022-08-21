(:glance)
class Repository {

    protected var _footprint;
    protected var _storage;

    private var _lastLatRad;
    private var _lastLonRad;

    // init

    function initialize(footprint, storage) {
        _footprint = footprint;
        _storage = storage;
    }

    // api

    function requestNearbyStops() {
        if (_storage.hasErrorOrIsEmpty()) {
            _storage.setResponseError(new ResponseError(ResponseError.CODE_STATUS_REQUESTING_STOPS));
        }

        if (DEBUG) {
            new SlNearbyStopsService(_storage).requestNearbyStops(debugLat, debugLon);
        }
        else {
            new SlNearbyStopsService(_storage).requestNearbyStops(_footprint.getLatDeg(), _footprint.getLonDeg());
        }

        _lastLatRad = _footprint.getLatRad();
        _lastLonRad = _footprint.getLonRad();
    }

    function requestDepartures(stop) {
        new SlDeparturesService(stop, false).requestDepartures();
    }

    function requestFewerDepartures(stop) {
        new SlDeparturesService(stop, true).requestDepartures();
    }

    // position

    function enablePositionHandling() {
        if (_storage.hasErrorOrIsEmpty() && !_isPositioned()) {
            _storage.setResponseError(new ResponseError(ResponseError.CODE_STATUS_NO_GPS));
        }

        // set location event listener and get last location while waiting
        _footprint.onRegisterPosition = method(:onPosition);
        _footprint.enableLocationEvents(Position.LOCATION_ONE_SHOT);
        _footprint.registerLastKnownPosition();
    }

    function onPosition() {
        // only request stops if the user has moved 100 m since last request
        if (_lastLatRad != null && _lastLonRad != null) {
            var movedDistance = _footprint.distanceTo(_lastLatRad, _lastLonRad);
            Log.d("moved distance: " + movedDistance);

            if (movedDistance > 100) {
                requestNearbyStops();
            }
        }
        else {
            requestNearbyStops();
        }
    }

    function disablePositionHandling() {
        _footprint.enableLocationEvents(Position.LOCATION_DISABLE);
        _footprint.onRegisterPosition = null;
    }

    function isPositionRegistered() {
        return _footprint.isPositionRegistered;
    }

    private function _isPositioned() {
        return DEBUG || _footprint.isPositioned();
    }

    // storage

    function getStopsResponse() {
        return _storage.response;
    }

    function hasStops() {
        return _storage.hasStops();
    }

}
