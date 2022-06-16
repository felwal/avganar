(:glance)
class Repository {

    protected var _footprint;
    protected var _storage;

    // init

    function initialize(footprint, storage) {
        _footprint = footprint;
        _storage = storage;
    }

    // api

    function requestNearbyStops() {
        _setStopsSearching();

        if (DEBUG) {
            new SlNearbyStopsService(_storage).requestNearbyStops(debugLat, debugLon);
        }
        else {
            new SlNearbyStopsService(_storage).requestNearbyStops(_footprint.getLatDeg(), _footprint.getLonDeg());
        }
    }

    function requestDepartures(stop) {
        new SlDeparturesService(stop, false).requestDepartures();
    }

    function requestFewerDepartures(stop) {
        new SlDeparturesService(stop, true).requestDepartures();
    }

    // position

    function enablePositionHandling() {
        _setPositionHandling(Position.LOCATION_ONE_SHOT, method(:requestNearbyStops));
    }

    private function _setPositionHandling(acquisitionType, onRegisterPosition) {
        _setStopsSearching();

        // set location event listener and get last location while waiting
        _footprint.onRegisterPosition = onRegisterPosition;
        _footprint.enableLocationEvents(acquisitionType);
        _footprint.registerLastKnownPosition();
    }

    function disablePositionHandling() {
        _footprint.enableLocationEvents(Position.LOCATION_DISABLE);
        _footprint.onRegisterPosition = null;
    }

    function isPositionRegistered() {
        return _footprint.isPositionRegistered;
    }

    // storage

    function getStopsResponse() {
        return _storage.response;
    }

    function hasStops() {
        return _storage.hasStops();
    }

    private function _setStopsSearching() {
        // don't override previously requested stops with "searching" message
        if (!_storage.hasStops()) {
            if (!_footprint.isPositioned()) {
                _storage.setResponseError(new ResponseError(ResponseError.ERROR_CODE_NO_GPS));
            }
            else {
                _storage.setResponseError(new ResponseError(ResponseError.ERROR_CODE_REQUESTING_STOPS));
            }
        }
    }

}
