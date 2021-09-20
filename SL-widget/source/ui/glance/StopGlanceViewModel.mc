using Toybox.Timer;

(:glance)
class StopGlanceViewModel {

    private static const REQUEST_TIME = 30000;

    private var _repo;

    private var _timer = new Timer.Timer();
    private const _stopCursor = 0;

    //

    function initialize(repo) {
        _repo = repo;
    }

    // request

    function enableRequests() {
        registerLocation();
        makeRequestsDelayed();
        startRequestTimer();
    }

    function disableRequests() {
        stopRequestTimer();
    }

    private function makeRequestsDelayed() {
        new Timer.Timer().start(method(:makeRequests), 500, false);
    }

    private function startRequestTimer() {
        _timer.start(method(:makeRequests), REQUEST_TIME, true);
    }

    private function stopRequestTimer() {
        _timer.stop();
    }

    //! Make requests to SlApi neccessary for glance display
    function makeRequests() {
        _repo.requestNearbyStopsGlance();
    }

    private function registerLocation() {
        _repo.setPositionHandling(Position.LOCATION_ONE_SHOT);
    }

    // read

    function getStopString() {
        return _repo.getStopGlanceString(_stopCursor);
    }

    // write

    function addPlaceholderStops() {
        _repo.addPlaceholderStops();
    }

}
