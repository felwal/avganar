
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
        new SlStopService(_storage).requestNearbyStops(_footprint.getLatDeg(), _footprint.getLonDeg());
        //new SlStopService(_storage).requestNearbyStops(debugLat, debugLon);
    }

    function requestDepartures(stop) {
        new SlDepartureService(stop, false).requestDepartures();
    }

    function requestFewerDepartures(stop) {
        new SlDepartureService(stop, true).requestDepartures();
    }

    // position

    function enablePositionHandling() {
        _setPositionHandling(Position.LOCATION_ONE_SHOT, method(:requestNearbyStops));
    }

    private function _setPositionHandling(acquisitionType, onRegisterPosition) {
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

    function setStopsSearching() {
        if (_storage.hasResponseError()) {
            if (!_footprint.isPositioned()) {
                _storage.setResponseError(new ResponseError(ResponseError.ERROR_CODE_NO_GPS));
            }
            else {
                _storage.setResponseError(new ResponseError(ResponseError.ERROR_CODE_SEARCHING));
            }
        }
    }

}
