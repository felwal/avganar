using Toybox.Timer;
using Toybox.WatchUi;
using Toybox.Math;
using Carbon.Chem;

class StopDetailViewModel {

    private static const _REQUEST_TIME_INTERVAL = 2 * 60 * 1000;
    private static const _REQUEST_TIME_DELAY = 500;

    static const DEPARTURES_PER_PAGE = 4; // TODO: dynamic

    var stop;
    var pageCount = 1;
    var pageCursor = 0;
    var modeCursor = 0;

    private var _repo;

    private var _delayTimer = new Timer.Timer();
    private var _requestTimer = new Timer.Timer();

    // init

    function initialize(repo, stop) {
        _repo = repo;
        self.stop = stop;
    }

    // request

    function enableRequests() {
        _requestDeparturesDelayed();
    }

    function disableRequests() {
        _repo.disablePositionHandling();
        _delayTimer.stop();
        _requestTimer.stop();
    }

    private function _requestDeparturesDelayed() {
        var age = stop.getDataAgeMillis();

        // never request more frequently than _REQUEST_TIME_INTERVAL.
        // never request more quickly than _REQUEST_TIME_DELAY,
        // because otherwise it crashes. TODO: figure out why
        var delay = age == null
            ? _REQUEST_TIME_DELAY
            : Chem.max(_REQUEST_TIME_INTERVAL - age, _REQUEST_TIME_DELAY);

        Log.d("age: " + age + ", delay: " + delay);

        _delayTimer.start(method(:onDelayedDeparturesRequest), delay, false);
    }

    function onDelayedDeparturesRequest() {
        requestDepartures();
        _startRequestTimer();
    }

    private function _startRequestTimer() {
        _requestTimer.start(method(:onRequestTimer), _REQUEST_TIME_INTERVAL, true);
    }

    function onRequestTimer() {
        requestDepartures();
        // update to keep clock time synced
        WatchUi.requestUpdate();
    }

    //! Make requests to SlApi neccessary for detail display.
    //! Needs to be public to be able to be called by timer.
    function requestDepartures() {
        _repo.requestDepartures(stop);
    }

    // read

    function getModeDepartures() {
        var departures = stop.getDepartures(modeCursor);
        pageCount = _getPageCount(departures);

        // coerce cursor
        pageCursor = Chem.min(pageCursor, pageCount - 1);

        return departures;
    }

    function getPageDepartures(modeDepartures) {
        // take `modeDepartures` as parameter to avoid calling `Stop#_trimDepartures`
        // unnecessarily often

        var startIndex = pageCursor * DEPARTURES_PER_PAGE;
        var endIndex = startIndex + DEPARTURES_PER_PAGE;

        return modeDepartures.slice(startIndex, endIndex);
    }

    private function _getPageCount(modeDepartures) {
        // take `modeDepartures` as parameter to avoid calling `Stop#_trimDepartures`
        // unnecessarily often

        return stop.hasResponseError()
            ? 1
            : Math.ceil(modeDepartures.size().toFloat() / DEPARTURES_PER_PAGE).toNumber();
    }

    // write

    function incPageCursor() {
        if (pageCursor < pageCount - 1) {
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

        // rerequest
        if (hasError && stop.getResponseError().isRerequestable()) {
            requestDepartures();
            stop.setSearching();
            WatchUi.requestUpdate();
        }
        // rotate mode
        else if (!hasError && stop.getModeCount() > 1) {
            _incModeCursor();
            WatchUi.requestUpdate();
        }
    }

    private function _incModeCursor() {
        modeCursor = Chem.mod(modeCursor + 1, stop.getModeCount());
        pageCursor = 0;
        WatchUi.requestUpdate();
    }

}
