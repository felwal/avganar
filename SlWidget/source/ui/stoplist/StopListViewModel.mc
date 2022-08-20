using Toybox.Timer;
using Toybox.WatchUi;

class StopListViewModel {

    private static const _REQUEST_TIME_INTERVAL = 1 * 60 * 1000;
    private static const _REQUEST_TIME_DELAY = 500;

    var stopCursor = 0;

    private var _repo;
    private var _favStorage;

    private var _delayTimer = new Timer.Timer();
    private var _positionTimer = new Timer.Timer();

    // init

    function initialize(repo) {
        _repo = repo;
        _favStorage = new FavoriteStopsStorage();

        stopCursor = getFavoriteCount();
    }

    function stopTimers() {
        _delayTimer.stop();
    }

    // request

    function enableRequests() {
        _repo.enablePositionHandling();
        _startRequestTimer();
    }

    function disableRequests() {
        _repo.disablePositionHandling();
        _delayTimer.stop();
        _positionTimer.stop();
    }

    private function _requestDeparturesDelayed() {
        // delayed because otherwise it crashes. TODO: figure out why
        _delayTimer.start(method(:requestPosition), _REQUEST_TIME_DELAY, false);
    }

    private function _startRequestTimer() {
        _positionTimer.start(method(:onTimer), _REQUEST_TIME_INTERVAL, true);
    }

    function onTimer() {
        requestPosition();
        // request update to keep clock time synced
        WatchUi.requestUpdate();
    }

    function requestPosition() {
        _repo.enablePositionHandling();
    }

    // read

    function getResponse() {
        return _repo.getStopsResponse();
    }

    function hasStops() {
        return _repo.hasStops() || _favStorage.favorites.size() > 0;
    }

    function getStops() {
        var response = getResponse();
        var favs = _favStorage.favorites;
        return response instanceof ResponseError ? favs : ArrCompat.merge(favs, response);
    }

    function getStopNames() {
        var stops = getStops();
        if (stops == null) { return null; }

        var names = new [stops.size()];
        for (var i = 0; i < names.size(); i++) {
            names[i] = stops[i].name;
        }

        return names;
    }

    function getStopCount() {
        var response = getResponse();

        return getFavoriteCount() + (response instanceof ResponseError ? 1 : response.size());
    }

    function getFavoriteCount() {
        return _favStorage.favorites.size();
    }

    function getSelectedStop() {
        var stops = getStops();
        return stopCursor < stops.size() ? stops[stopCursor] : null;
    }

    function isFavorite() {
        var stop = getSelectedStop();
        return stop != null && _favStorage.isFavorite(stop.id);
    }

    function isShowingMessage() {
        return getResponse() instanceof ResponseError && stopCursor == getStopCount() - 1;
    }

    function isPositionRegistered() {
        return _repo.isPositionRegistered();
    }

    // write

    function addFavorite() {
        _favStorage.addFavorite(getSelectedStop());
        // navigate to newly added
        stopCursor = getFavoriteCount() - 1;
    }

    function removeFavorite() {
        _favStorage.removeFavorite(getSelectedStop());
        // navigate to start
        stopCursor = getFavoriteCount();
    }

    function moveFavorite(diff) {
        _favStorage.moveFavorite(getSelectedStop().id, diff);
        stopCursor += diff;
    }

    function incStopCursor() {
        _rotStopCursor(1);
    }

    function decStopCursor() {
        _rotStopCursor(-1);
    }

    private function _rotStopCursor(step) {
        if (hasStops()) {
            stopCursor = mod(stopCursor + step, getStopCount());
            WatchUi.requestUpdate();
        }
    }

}
