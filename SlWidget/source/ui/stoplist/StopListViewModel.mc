using Toybox.Timer;
using Toybox.WatchUi;
using Carbon.Chem;

class StopListViewModel {

    static private const _REQUEST_TIME_INTERVAL = 1 * 60 * 1000;
    static private const _REQUEST_TIME_DELAY = 500;

    var stopCursor = 0;

    private var _delayTimer = new Timer.Timer();
    private var _positionTimer = new Timer.Timer();

    // init

    function initialize() {
        stopCursor = getFavoriteCount();
    }

    function stopTimers() {
        _delayTimer.stop();
    }

    // request

    function enableRequests() {
        Repository.enablePositionHandling();
        _startRequestTimer();
    }

    function disableRequests() {
        Repository.disablePositionHandling();
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
        Repository.enablePositionHandling();
    }

    // read

    function getResponse() {
        return Repository.getNearbyStopsResponse();
    }

    function hasStops() {
        return Repository.hasStops();
    }

    private function _getStops() {
        var response = getResponse();
        var favs = Repository.getFavorites();
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
        return Repository.getFavorites().size();
    }

    function getSelectedStop() {
        var stops = _getStops();
        return stopCursor < stops.size() ? stops[stopCursor] : null;
    }

    function isSelectedStopFavorite() {
        var stop = getSelectedStop();
        return stop != null && Repository.isFavorite(stop.id);
    }

    function isShowingMessage() {
        return !(getResponse() instanceof StopsResponse) && stopCursor == getStopCount() - 1;
    }

    function isPositionRegistered() {
        return Repository.isPositionRegistered();
    }

    // write

    function addFavorite() {
        Repository.addFavorite(getSelectedStop());
        // navigate to newly added
        stopCursor = getFavoriteCount() - 1;
    }

    function removeFavorite() {
        var isInFavoritesPane = stopCursor < getFavoriteCount();

        Repository.removeFavorite(getSelectedStop().id);

        // keep cursor inside favorites panel
        // – or where it was
        stopCursor = isInFavoritesPane
            ? Chem.coerceIn(stopCursor, 0, Chem.max(getFavoriteCount() - 1, 0))
            : stopCursor - 1;
    }

    function moveFavorite(diff) {
        Repository.moveFavorite(getSelectedStop().id, diff);
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
