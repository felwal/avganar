using Toybox.Application.Storage;
using Toybox.Lang;
using Toybox.Position;
using Carbon.Footprint;

module Repository {

    const _STORAGE_LAST_POS = "last_pos";

    var _footprint;
    var _lastPos;

    // init

    function load() {
        _footprint = new Carbon.Footprint();
        _lastPos = StorageUtil.getArray(_STORAGE_LAST_POS);
    }

    // api

    function requestNearbyStops() {
        if (!NearbyStopsStorage.hasStops()) {
            // set searching
            NearbyStopsStorage.setResponse([], [], new StatusMessage(rez(Rez.Strings.lbl_i_stops_requesting)));
        }

        if (DEBUG) {
            SlNearbyStopsService.requestNearbyStops(debugLat, debugLon);
        }
        else {
            SlNearbyStopsService.requestNearbyStops(_footprint.getLatDeg(), _footprint.getLonDeg());
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
        _footprint.onRegisterPosition = new Lang.Method(Repository, :onPosition);
        _footprint.enableLocationEvents(Position.LOCATION_ONE_SHOT);
        _footprint.registerLastKnownPosition();

        // set locating message after `registerLastKnownPosition` to avoid
        // setting the response more times than necessary
        if (!NearbyStopsStorage.hasStops() && !_isPositioned()) {
            NearbyStopsStorage.setResponse([], [], new StatusMessage(rez(Rez.Strings.lbl_i_stops_no_gps)));
        }
    }

    function onPosition() {
        if (_lastPos.size() != 2 || !NearbyStopsStorage.hasStopsResponse()) {
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

    function _isPositioned() {
        return _footprint.isPositioned() || DEBUG;
    }

    // storage

    function getNearbyStopsResponse() {
        return NearbyStopsStorage.response;
    }

    function hasStops() {
        return NearbyStopsStorage.hasStops() || getFavorites().size() > 0;
    }

    function getFavorites() {
        return FavoriteStopsStorage.favorites;
    }

    function isFavorite(stopId) {
        return FavoriteStopsStorage.isFavorite(stopId);
    }

    function addFavorite(stop) {
        FavoriteStopsStorage.addFavorite(stop);
    }

    function removeFavorite(stopId) {
        FavoriteStopsStorage.removeFavorite(stopId);
    }

    function moveFavorite(stopId, diff) {
        FavoriteStopsStorage.moveFavorite(stopId, diff);
    }

}
