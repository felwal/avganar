using Toybox.Application.Storage;

class Repository {

    private static const _STORAGE_LAST_POS = "last_pos";

    private var _footprint;
    private var _nearbyStorage;
    private var _favStorage;
    private var _stopFactory;
    private var _stopsService;

    private var _lastPos;

    // init

    function initialize(footprint, nearbyStorage, favStorage, stopFactory, stopsService) {
        _footprint = footprint;
        _nearbyStorage = nearbyStorage;
        _favStorage = favStorage;
        _stopFactory = stopFactory;
        _stopsService = stopsService;

        _lastPos = StorageUtil.getArray(_STORAGE_LAST_POS);
    }

    // api

    function requestNearbyStops() {
        if (!_nearbyStorage.hasStops()) {
            // set searching
            _nearbyStorage.setResponse([], [], new StatusMessage(rez(Rez.Strings.lbl_i_stops_requesting)));
        }

        if (DEBUG) {
            _stopsService.requestNearbyStops(debugLat, debugLon);
        }
        else {
            _stopsService.requestNearbyStops(_footprint.getLatDeg(), _footprint.getLonDeg());
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
        // set location event listener and get last location while waiting
        _footprint.onRegisterPosition = method(:onPosition);
        _footprint.enableLocationEvents(Position.LOCATION_ONE_SHOT);
        _footprint.registerLastKnownPosition();

        // set locating message after `registerLastKnownPosition` to avoid
        // setting the response more times than necessary
        if (!_nearbyStorage.hasStops() && !_isPositioned()) {
            _nearbyStorage.setResponse([], [], new StatusMessage(rez(Rez.Strings.lbl_i_stops_no_gps)));
        }
    }

    function onPosition() {
        if (_lastPos.size() != 2 || !_nearbyStorage.hasStopsResponse()) {
            requestNearbyStops();
        }
        else if (_lastPos.size() == 2) {
            var movedDistance = _footprint.distanceTo(_lastPos[0], _lastPos[1]);
            Log.d("moved distance: " + movedDistance);

            // only request stops if the user has moved 100 m since last request
            if (movedDistance > 100) {
                requestNearbyStops();
            }
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
        return _footprint.isPositioned() || DEBUG;
    }

    // storage

    function getNearbyStopsResponse() {
        return _nearbyStorage.response;
    }

    function hasStops() {
        return _nearbyStorage.hasStops() || getFavorites().size() > 0;
    }

    function getFavorites() {
        return _favStorage.favorites;
    }

    function isFavorite(stopId) {
        return _favStorage.isFavorite(stopId);
    }

    function addFavorite(stop) {
        _favStorage.addFavorite(stop);
    }

    function removeFavorite(stopId) {
        _favStorage.removeFavorite(stopId);
    }

    function moveFavorite(stopId, diff) {
        _favStorage.moveFavorite(stopId, diff);
    }

}
