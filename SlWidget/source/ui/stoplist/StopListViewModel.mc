using Toybox.Timer;
using Toybox.WatchUi;
using Toybox.Application.Storage;
using Toybox.Lang;
using Toybox.Position;
using Carbon.Footprint;
using Carbon.Chem;

class StopListViewModel {

    static private const _REQUEST_TIME_INTERVAL = 1 * 60 * 1000;
    static private const _REQUEST_TIME_DELAY = 500;
    static private const _STORAGE_LAST_POS = "last_pos";

    var stopCursor = 0;

    private var _positionTimer = new Timer.Timer();
    private var _lastPos;

    // init

    function initialize() {
        stopCursor = getFavoriteCount();
        _lastPos = StorageUtil.getArray(_STORAGE_LAST_POS);
    }

    // timer

    function enableRequests() {
        requestPosition();
        _positionTimer.start(method(:requestPosition), _REQUEST_TIME_INTERVAL, true);
    }

    function disableRequests() {
        _disablePositionHandling();
        _positionTimer.stop();
    }

    // position

    function requestPosition() {
        // set location event listener and get last location while waiting
        Footprint.onRegisterPosition = method(:onPosition);
        Footprint.enableLocationEvents(Position.LOCATION_ONE_SHOT);
        Footprint.registerLastKnownPosition();

        // set locating message after `registerLastKnownPosition` to avoid
        // setting the response more times than necessary
        if (!NearbyStopsStorage.hasStops() && !_isPositioned()) {
            NearbyStopsStorage.setResponse([], [], new ResponseMessage(rez(Rez.Strings.lbl_i_stops_no_gps)));
        }
    }

    private function _disablePositionHandling() {
        Footprint.enableLocationEvents(Position.LOCATION_DISABLE);
        Footprint.onRegisterPosition = null;
    }

    function onPosition() {
        if (_lastPos.size() != 2 || !NearbyStopsStorage.hasStops()) {
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

    function _isPositioned() {
        return Footprint.isPositioned() || DEBUG;
    }

    // service

    function requestNearbyStops() {
        if (!NearbyStopsStorage.hasStops() && !(NearbyStopsStorage.response instanceof ResponseError)) {
            // set searching
            NearbyStopsStorage.setResponse([], [], null);
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

    // storage - read

    function getResponse() {
        return NearbyStopsStorage.response;
    }

    function hasStops() {
        return NearbyStopsStorage.hasStops() || FavoriteStopsStorage.favorites.size() > 0;
    }

    private function _getStops() {
        var response = NearbyStopsStorage.response;
        var favs = FavoriteStopsStorage.favorites;
        var stops = response instanceof StopsResponse ? ArrUtil.merge(favs, response.getStops()) : favs;

        // coerce cursor
        stopCursor = Chem.min(stopCursor, getItemCount() - 1);

        return stops;
    }

    function getStopNames() {
        var stops = _getStops();
        if (stops == null) { return null; }

        var names = new [stops.size()];
        for (var i = 0; i < names.size(); i++) {
            names[i] = stops[i].name;
        }

        return names;
    }

    function getItemCount() {
        var response = NearbyStopsStorage.response;

        return getFavoriteCount() + (response instanceof StopsResponse ? response.getStopCount() : 1);
    }

    function getFavoriteCount() {
        return FavoriteStopsStorage.favorites.size();
    }

    function getSelectedStop() {
        var stops = _getStops();
        return stopCursor < stops.size() ? stops[stopCursor] : null;
    }

    function isSelectedStopFavorite() {
        var stop = getSelectedStop();
        return stop != null && FavoriteStopsStorage.isFavorite(stop.id);
    }

    function isShowingMessage() {
        return !(NearbyStopsStorage.response instanceof StopsResponse) && stopCursor == getItemCount() - 1;
    }

    // storage - write

    function addFavorite() {
        FavoriteStopsStorage.addFavorite(getSelectedStop());
        // navigate to newly added
        stopCursor = getFavoriteCount() - 1;
    }

    function removeFavorite() {
        var isInFavoritesPane = stopCursor < getFavoriteCount();

        FavoriteStopsStorage.removeFavorite(getSelectedStop().id);

        // keep cursor inside favorites panel
        // – or where it was
        stopCursor = isInFavoritesPane
            ? Chem.coerceIn(stopCursor, 0, Chem.max(getFavoriteCount() - 1, 0))
            : stopCursor - 1;
    }

    function moveFavorite(diff) {
        FavoriteStopsStorage.moveFavorite(getSelectedStop().id, diff);
        stopCursor += diff;
    }

    //

    function incStopCursor() {
        _rotStopCursor(1);
    }

    function decStopCursor() {
        _rotStopCursor(-1);
    }

    private function _rotStopCursor(step) {
        if (hasStops()) {
            stopCursor = Chem.mod(stopCursor + step, getItemCount());
            WatchUi.requestUpdate();
        }
    }

}
