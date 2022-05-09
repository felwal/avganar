using Toybox.Timer;
using Toybox.WatchUi;
using Toybox.Communications;
using Toybox.Math;

class StopDetailViewModel {

    private static const _REQUEST_TIME_INTERVAL = 30000;
    private static const _REQUEST_TIME_DELAY = 500;

    static const DEPARTURES_PER_PAGE = 4; // TODO: dynamic

    var stop;
    var pageCursor = 0;
    var modeCursor = 0;

    private var _repo;
    private var _timer = new Timer.Timer();

    // init

    function initialize(repo, stop) {
        _repo = repo;
        self.stop = stop;
    }

    // request

    function enableRequests() {
        _requestDeparturesDelayed();
        _startRequestTimer();
    }

    function disableRequests() {
        _repo.disablePositionHandling();
        _timer.stop();
    }

    private function _requestDeparturesDelayed() {
        // delayed because otherwise it crashes. TODO: figure out why
        new Timer.Timer().start(method(:requestDepartures), _REQUEST_TIME_DELAY, false);
    }

    private function _startRequestTimer() {
        _timer.start(method(:onTimer), _REQUEST_TIME_INTERVAL, true);
    }

    function onTimer() {
        requestDepartures();
        // request update to keep clock time synced
        WatchUi.requestUpdate();
    }

    //! Make requests to SlApi neccessary for detail display.
    //! This needs to be public to be able to be called by timer.
    function requestDepartures() {
        _repo.requestDepartures(stop);
    }

    private function _rerequestDepartures() {
        if (stop.hasResponseError() && stop.getResponseError().isTooLarge()) {
            _repo.requestFewerDepartures(stop);
        }
        else {
            requestDepartures();
        }

        stop.setSearching();
    }

    // read

    function getPageDepartures() {
        var startIndex = pageCursor * DEPARTURES_PER_PAGE;
        var endIndex = startIndex + DEPARTURES_PER_PAGE;

        return _getModeDepartures().slice(startIndex, endIndex);
    }

    private function _getModeDepartures() {
        return stop.getDepartures(modeCursor);
    }

    function getPageCount() {
        return Math.ceil(_getModeDepartures().size().toFloat() / DEPARTURES_PER_PAGE).toNumber();
    }

    // write

    function incPageCursor() {
        if (pageCursor < getPageCount() - 1) {
            pageCursor++;
            WatchUi.requestUpdate();
        }
    }

    function decPageCursor() {
        if (pageCursor > 0) {
            pageCursor--;
            WatchUi.requestUpdate();
        }
    }

    function onSelect() {
        var hasError = stop.hasResponseError();
        if (hasError && stop.getResponseError().isRerequestable()) {
            _rerequestDepartures();
            WatchUi.requestUpdate();
        }
        else if (!hasError && stop.getModeCount() > 1) {
            _incModeCursor();
            WatchUi.requestUpdate();
        }
    }

    private function _incModeCursor() {
        modeCursor = mod(modeCursor + 1, stop.getModeCount());
        pageCursor = 0;
        WatchUi.requestUpdate();
    }

}
