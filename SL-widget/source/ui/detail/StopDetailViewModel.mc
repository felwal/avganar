using Toybox.Timer;

(:glance)
class StopDetailViewModel {

    private static const _REQUEST_TIME_INTERVAL = 30000;
    private static const _REQUEST_TIME_DELAY = 500;

    private var _repo;
    private var _timer = new Timer.Timer();
    private var _stopCursor = 0;

    //

    function initialize(repo) {
        _repo = repo;
    }

    // request

    function enableRequests() {
        enableLocationEvents();
        makeRequestsDelayed();
        startRequestTimer();
    }

    function disableRequests() {
        disableLocationEvents();
        stopRequestTimer();
    }

    private function makeRequestsDelayed() {
        new Timer.Timer().start(method(:makeRequests), _REQUEST_TIME_DELAY, false);
    }

    private function startRequestTimer() {
        _timer.start(method(:makeRequests), _REQUEST_TIME_INTERVAL, true);
    }

    private function stopRequestTimer() {
        _timer.stop();
    }

    //! Make requests to SlApi neccessary for detail display.
    //! This needs to be public to be able to be called by timer.
    function makeRequests() {
        _repo.requestDeparturesDetail(_stopCursor);
        _repo.requestNearbyStopsDetail(); // TODO: temp
    }

    private function enableLocationEvents() {
        _repo.enablePositionHandlingDetail();
    }

    private function disableLocationEvents() {
        _repo.disablePositionHandling();
    }

    // read

    function getSelectedStopString() {
        return _repo.getStopDetailString(_stopCursor);
    }

    function getSelectedStop() {
        return _repo.getStop(_stopCursor);
    }

}
