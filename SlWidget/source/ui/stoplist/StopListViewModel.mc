using Toybox.Timer;
using Toybox.WatchUi;

class StopListViewModel {

    private static const _REQUEST_TIME_INTERVAL = 60000;
    private static const _REQUEST_TIME_DELAY = 500;

    var stopCursor = 0;

    private var _repo;
    private var _timer = new Timer.Timer();

    // init

    function initialize(repo) {
        _repo = repo;
    }

    // request

    function enableRequests() {
        _repo.setStopsSearching();
        _repo.enablePositionHandling();
        _startRequestTimer();
    }

    function disableRequests() {
        _repo.disablePositionHandling();
        _timer.stop();
    }

    private function _requestDeparturesDelayed() {
        // delayed because otherwise it crashes. TODO: figure out why
        new Timer.Timer().start(method(:requestPosition), _REQUEST_TIME_DELAY, false);
    }

    private function _startRequestTimer() {
        _timer.start(method(:onTimer), _REQUEST_TIME_INTERVAL, true);
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
        return _repo.hasStops();
    }

    function getStops() {
        var response = getResponse();
        return response instanceof ResponseError ? null : response;
    }

    function getStopCount() {
        return getStops().size();
    }

    function getSelectedStop() {
        return getStops()[stopCursor];
    }

    function isPositionRegistered() {
        return _repo.isPositionRegistered();
    }

    // write

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
