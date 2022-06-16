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

    function getFavouriteStops() {
        return [new Stop(1002, "T-Centralen", null), new Stop(9204, "Tekniska Högskolan", null)];
    }

    function hasStops() {
        return _storage.hasStops() || getFavouriteStops().size() > 0;
    }

    function setStopsSearching() {
        if (_storage.hasResponseError()) {
            if (!_footprint.isPositioned()) {
                _storage.setResponseError(new ResponseError(ResponseError.ERROR_CODE_NO_GPS));
            }
            else {
                _storage.setResponseError(new ResponseError(ResponseError.ERROR_CODE_REQUESTING_STOPS));
            }
        }
    }

}
