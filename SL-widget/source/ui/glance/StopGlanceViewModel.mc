import Toybox.Lang;

using Toybox.Timer;

(:glance)
class StopGlanceViewModel {

    private static const _REQUEST_TIME_INTERVAL = 30000;
    private static const _REQUEST_TIME_DELAY = 500;
    private static const _STOP_CURSOR = 0;

    private var _repo as Repository;

    private var _timer = new Timer.Timer();

    //

    function initialize(repo as Repository) as Void {
        _repo = repo;
    }

    // request

    function enableRequests() as Void {
        _repo.setPlaceholderStop();
        enableLocationEvents();
        makeRequestsDelayed();
        startRequestTimer();
    }

    function disableRequests() as Void {
        disableLocationEvents();
        stopRequestTimer();
    }

    private function makeRequestsDelayed() as Void {
        new Timer.Timer().start(method(:makeRequests), _REQUEST_TIME_DELAY, false);
    }

    private function startRequestTimer() as Void {
        _timer.start(method(:makeRequests), _REQUEST_TIME_INTERVAL, true);
    }

    private function stopRequestTimer() as Void {
        _timer.stop();
    }

    //! Make requests to SlApi neccessary for glance display.
    //! This needs to be public to be able to be called by timer.
    function makeRequests() as Void {
        _repo.requestDeparturesGlance();
        //_repo.requestNearbyStopsGlance(); // TODO: temp
    }

    private function enableLocationEvents() as Void {
        _repo.enablePositionHandlingGlance();
    }

    private function disableLocationEvents() as Void {
        _repo.disablePositionHandling();
    }

    // read

    function getStopString() as String {
        return _repo.getStopGlanceString(_STOP_CURSOR);
    }

}
