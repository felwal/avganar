using Toybox.Application.Storage;

class Repository {

    private static const _STORAGE_LAST_POS = "last_pos";

    private var _footprint;
    private var _storage;

    private var _lastPos;

    // init

    function initialize(footprint, storage) {
        _footprint = footprint;
        _storage = storage;

        _lastPos = StorageCompat.getArray(_STORAGE_LAST_POS);
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

        // update last position
        _lastPos = [ _footprint.getLatRad(), _footprint.getLonRad() ];
        // save to storage to avoid requesting every time the user enters the app
        Storage.setValue(_STORAGE_LAST_POS, _lastPos);
    }

    function requestDepartures(stop) {
        new SlDeparturesService(stop).requestDepartures();
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
        if (_lastPos.size() == 2) {
            var movedDistance = _footprint.distanceTo(_lastPos[0], _lastPos[1]);
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
