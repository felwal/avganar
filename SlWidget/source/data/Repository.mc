using Toybox.Application.Storage;
using Toybox.Lang;
using Toybox.Position;
using Carbon.Footprint;

module Repository {

    const _STORAGE_LAST_POS = "last_pos";

    var _lastPos;

    // init

    function load() {
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
            SlNearbyStopsService.requestNearbyStops(Footprint.getLatDeg(), Footprint.getLonDeg());
        }

        // update last position
        _lastPos = [ Footprint.getLatRad(), Footprint.getLonRad() ];
        // save to storage to avoid requesting every time the user enters the app
        Storage.setValue(_STORAGE_LAST_POS, _lastPos);
    }

    function requestDepartures(stop) {
        new SlDeparturesService(stop).requestDepartures();
    }

    // position

    function enablePositionHandling() {
        // set location event listener and get last location while waiting
        Footprint.onRegisterPosition = new Lang.Method(Repository, :onPosition);
        Footprint.enableLocationEvents(Position.LOCATION_ONE_SHOT);
        Footprint.registerLastKnownPosition();

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
            var movedDistance = Footprint.distanceTo(_lastPos[0], _lastPos[1]);
            Log.d("moved distance: " + movedDistance);

            // only request stops if the user has moved 100 m since last request
            if (movedDistance > 100) {
                requestNearbyStops();
            }
        }
    }

    function disablePositionHandling() {
        Footprint.enableLocationEvents(Position.LOCATION_DISABLE);
        Footprint.onRegisterPosition = null;
    }

    function isPositionRegistered() {
        return Footprint.isPositionRegistered;
    }

    function _isPositioned() {
        return Footprint.isPositioned() || DEBUG;
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
