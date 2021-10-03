using Toybox.Timer;
using Toybox.WatchUi;

(:glance)
class StopDetailViewModel {

    private static const _REQUEST_TIME_INTERVAL = 30000;
    private static const _REQUEST_TIME_DELAY = 500;

    var stopCursor = 0;
    var modeCursor = 0;

    private var _repo;
    private var _timer = new Timer.Timer();

    // init

    function initialize(repo) {
        _repo = repo;
    }

    // request

    function enableRequests() {
        _repo.setPlaceholderStop();
        _repo.enablePositionHandling(method(:getStopCursor));
        _makeRequestsDelayed();
        _startRequestTimer();
    }

    function disableRequests() {
        _repo.disablePositionHandling();
        _timer.stop();
    }

    private function _makeRequestsDelayed() {
        new Timer.Timer().start(method(:makeRequests), _REQUEST_TIME_DELAY, false);
    }

    private function _startRequestTimer() {
        _timer.start(method(:makeRequests), _REQUEST_TIME_INTERVAL, true);
    }

    //! Make requests to SlApi neccessary for detail display.
    //! This needs to be public to be able to be called by timer.
    function makeRequests() {
        _repo.requestDepartures(stopCursor);
        //_repo.requestNearbyStops(); // TODO: temp
    }

    // read

    function getStopCursor() {
        return stopCursor;
    }

    function getSelectedStopString() {
        return _repo.getStopString(stopCursor, modeCursor);
    }

    function getSelectedStop() {
        return _repo.getStop(stopCursor);
    }

    function getSelectedDepartures() {
        return getSelectedStop().getDepartures(modeCursor);
    }

    function getSelectedDepartureCount() {
        return getSelectedStop().getDepartureCount(modeCursor);
    }

    function getStopCount() {
        return _repo.getStopCount();
    }

    function getModeCount() {
        return _repo.getModeCount(stopCursor);
    }

    // write

    function incStopCursor() {
        _rotStopCursor(1);
    }

    function decStopCursor() {
        _rotStopCursor(-1);
    }

    private function _rotStopCursor(amount) {
        stopCursor = _repo.getStopIndexRotated(stopCursor, amount);
        modeCursor = 0;

        // TODO: maybe a better way to request departures
        //  e.g. let timer request for all stops
        _repo.requestDepartures(stopCursor);
        WatchUi.requestUpdate();
    }

    function incModeCursor() {
        modeCursor = _repo.getModeIndexRotated(stopCursor, modeCursor);
        WatchUi.requestUpdate();
    }

}
