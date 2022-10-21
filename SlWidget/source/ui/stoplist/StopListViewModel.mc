using Toybox.Timer;
using Toybox.WatchUi;
using Carbon.Chem;

class StopListViewModel {

    private static const _REQUEST_TIME_INTERVAL = 1 * 60 * 1000;
    private static const _REQUEST_TIME_DELAY = 500;

    var stopCursor = 0;

    private var _repo;

    private var _delayTimer = new Timer.Timer();
    private var _positionTimer = new Timer.Timer();

    // init

    function initialize(repo) {
        _repo = repo;

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
        return _repo.getNearbyStopsResponse();
    }

    function hasStops() {
        return _repo.hasStops();
    }

    private function _getStops() {
        var response = getResponse();
        var favs = _repo.getFavorites();
        var stops = response instanceof StopsResponse ? ArrUtil.merge(favs, response.getStops()) : favs;

        // coerce cursor
        stopCursor = Chem.min(stopCursor, getStopCount() - 1);

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

    function getStopCount() {
        var response = getResponse();

        return getFavoriteCount() + (response instanceof StopsResponse ? response.getStopCount() : 1);
    }

    function getFavoriteCount() {
        return _repo.getFavorites().size();
    }

    function getSelectedStop() {
        var stops = _getStops();
        return stopCursor < stops.size() ? stops[stopCursor] : null;
    }

    function isSelectedStopFavorite() {
        var stop = getSelectedStop();
        return stop != null && _repo.isFavorite(stop.id);
    }

    function isShowingMessage() {
        return !(getResponse() instanceof StopsResponse) && stopCursor == getStopCount() - 1;
    }

    function isPositionRegistered() {
        return _repo.isPositionRegistered();
    }

    // write

    function addFavorite() {
        _repo.addFavorite(getSelectedStop());
        // navigate to newly added
        stopCursor = getFavoriteCount() - 1;
    }

    function removeFavorite() {
        var isInFavoritesPane = stopCursor < getFavoriteCount();

        _repo.removeFavorite(getSelectedStop().id);

        // keep cursor inside favorites panel
        // – or where it was
        stopCursor = isInFavoritesPane
            ? Chem.coerceIn(stopCursor, 0, Chem.max(getFavoriteCount() - 1, 0))
            : stopCursor - 1;
    }

    function moveFavorite(diff) {
        _repo.moveFavorite(getSelectedStop().id, diff);
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
            stopCursor = Chem.mod(stopCursor + step, getStopCount());
            WatchUi.requestUpdate();
        }
    }

}
