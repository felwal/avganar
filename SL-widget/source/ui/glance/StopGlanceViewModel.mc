using Toybox.Timer;

(:glance)
class StopGlanceViewModel {

    private static const _REQUEST_TIME_INTERVAL = 30000;
    private static const _REQUEST_TIME_DELAY = 500;
    private static const _STOP_CURSOR = 0;

    private var _repo;

    private var _timer = new Timer.Timer();

    // init

    function initialize(repo) {
        _repo = repo;
    }

    // request

    function enableRequests() {
        _repo.setPlaceholderStop();
        _repo.enablePositionHandlingGlance();
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

    //! Make requests to SlApi neccessary for glance display.
    //! This needs to be public to be able to be called by timer.
    function makeRequests() {
        _repo.requestDeparturesGlance();
        //_repo.requestNearbyStopsGlance(); // TODO: temp
    }

    // read

    function getStopString() {
        return _repo.getStopGlanceString(_STOP_CURSOR);
    }

}
