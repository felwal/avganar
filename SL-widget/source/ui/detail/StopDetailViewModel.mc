import Toybox.Lang;

using Toybox.Timer;
using Toybox.WatchUi;

(:glance)
class StopDetailViewModel {

    private static const _REQUEST_TIME_INTERVAL = 30000;
    private static const _REQUEST_TIME_DELAY = 500;

    private var _repo as Repository;

    private var _timer = new Timer.Timer();
    private var _stopCursor = 0;
    private var _modeCursor = 0;

    //

    function initialize(repo as Repository) as Void {
        _repo = repo;
    }

    // request

    function enableRequests() as Void {
        _repo.setPlaceholderStop();
        _enableLocationEvents();
        _makeRequestsDelayed();
        _startRequestTimer();
    }

    function disableRequests() as Void {
        _disableLocationEvents();
        _stopRequestTimer();
    }

    private function _makeRequestsDelayed() as Void {
        new Timer.Timer().start(method(:makeRequests), _REQUEST_TIME_DELAY, false);
    }

    private function _startRequestTimer() as Void {
        _timer.start(method(:makeRequests), _REQUEST_TIME_INTERVAL, true);
    }

    private function _stopRequestTimer() as Void {
        _timer.stop();
    }

    //! Make requests to SlApi neccessary for detail display.
    //! This needs to be public to be able to be called by timer.
    function makeRequests() as Void {
        _repo.requestDeparturesDetail(_stopCursor);
        //_repo.requestNearbyStopsDetail(); // TODO: temp
    }

    private function _enableLocationEvents() as Void {
        _repo.enablePositionHandlingDetail();
    }

    private function _disableLocationEvents() as Void {
        _repo.disablePositionHandling();
    }

    // read

    function getSelectedStopString() as String {
        return _repo.getStopDetailString(_stopCursor, _modeCursor);
    }

    function getSelectedStop() as Stop {
        return _repo.getStop(_stopCursor);
    }

    function getSelectedJourneys() as Array<Journey> {
        return getSelectedStop().journeys[_modeCursor];
    }

    // write

    function incStopCursor() as Void {
        _rotStopCursor(1);
    }

    function decStopCursor() as Void {
        _rotStopCursor(-1);
    }

    private function _rotStopCursor(amount as Number) as Void {
        _stopCursor = _repo.getStopIndexRotated(_stopCursor, amount);
        _modeCursor = 0;
        // TODO: maybe a better way to request departures
        //  e.g. let timer request for all stops
        _repo.requestDeparturesDetail(_stopCursor);
        WatchUi.requestUpdate();
    }

    function incModeCursor() as Void {
        _modeCursor = _repo.getModeIndexRotated(_stopCursor, _modeCursor);
        WatchUi.requestUpdate();
    }

}
