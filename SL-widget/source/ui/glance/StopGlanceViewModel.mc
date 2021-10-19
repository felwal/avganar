using Toybox.Timer;

(:glance)
class StopGlanceViewModel {

    //private static const _REQUEST_TIME_INTERVAL = 30000;
    //private static const _REQUEST_TIME_DELAY = 1500;
    private static const _STOP_CURSOR = 0;

    private var _repo;
    //private var _timer;

    // init

    function initialize(repo) {
        _repo = repo;
        //_timer = new Timer.Timer();
    }

    // request

    function enableRequests() {
        _repo.loadStorage();
        //_repo.setDeparturesSearching(_STOP_CURSOR);
        // positioning should be avoided in glance.
        // TODO: just use last known position
        //_repo.enablePositionHandling();
        //_makeRequestsDelayed();
        //_startRequestTimer();
    }

    function disableRequests() {
        // positioning should be avoided in glance.
        //_repo.disablePositionHandling();
        //_timer.stop();
    }

    private function _makeRequestsDelayed() {
        //new Timer.Timer().start(method(:makeRequests), _REQUEST_TIME_DELAY, false);
    }

    private function _startRequestTimer() {
        //_timer.start(method(:makeRequests), _REQUEST_TIME_INTERVAL, true);
    }

    //! Make requests to SlApi neccessary for glance display.
    //! This needs to be public to be able to be called by timer.
    function makeRequests() {
        //_repo.requestDepartures();
        //_repo.requestNearbyStops(); // TODO: temp
    }

    // read

    function getStopString() {
        return _repo.getStopString(_STOP_CURSOR);
    }

}
