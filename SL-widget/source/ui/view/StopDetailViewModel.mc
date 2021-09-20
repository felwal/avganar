using Toybox.Timer;

(:glance)
class StopDetailViewModel {

    private static const REQUEST_TIME = 30000;

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
        _repo.requestNearbyStopsView();
    }

    private function enableLocationEvents() {
        _repo.setPositionHandling(Position.LOCATION_CONTINUOUS);
    }

    private function disableLocationEvents() {
        _repo.setPositionHandling(Position.LOCATION_DISABLE);
    }

    // read

    function getSelectedStopString() {
        return _repo.getStopViewString(_stopCursor);
    }

    function getSelectedStop() {
        return _repo.getStop(_stopCursor);
    }

    // write

    function addPlaceholderStops() {
        _repo.addPlaceholderStops();
    }

}
