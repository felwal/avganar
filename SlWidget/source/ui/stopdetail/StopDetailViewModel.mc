using Toybox.Timer;
using Toybox.WatchUi;
using Toybox.Math;
using Carbon.Chem;

class StopDetailViewModel {

    static private const _REFRESH_TIME_INTERVAL = 15 * 1000;
    static private const _REQUEST_TIME_INTERVAL = 2 * 60 * 1000;
    static private const _REQUEST_TIME_DELAY = 500;

    static const DEPARTURES_PER_PAGE = 4;

    var stop;
    var pageCount = 1;
    var pageCursor = 0;
    var modeCursor = 0;

    private var _delayTimer = new Timer.Timer();
    private var _repeatTimer = new TimerWrapper();

    // init

    function initialize(stop) {
        self.stop = stop;
    }

    // request

    function enableRequests() {
        _requestDeparturesDelayed();
    }

    function disableRequests() {
        _delayTimer.stop();
        _repeatTimer.stop();
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
        _startRepeatTimer();
    }

    private function _startRepeatTimer() {
        var refreshTimer = new TimerRepr(method(:onRefreshTimer), 1);
        var requestTimer = new TimerRepr(method(:onRequestTimer), _REQUEST_TIME_INTERVAL / _REFRESH_TIME_INTERVAL);

        _repeatTimer.start(_REFRESH_TIME_INTERVAL, [ refreshTimer, requestTimer ]);
    }

    function onRefreshTimer() {
        WatchUi.requestUpdate();
    }

    function onRequestTimer() {
        requestDepartures();
    }

    //! Make requests to SlApi neccessary for detail display.
    //! Needs to be public to be able to be called by timer.
    function requestDepartures() {
        new SlDeparturesService(stop).requestDepartures();
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

        return stop.hasDepartures()
            ? Math.ceil(modeDepartures.size().toFloat() / DEPARTURES_PER_PAGE).toNumber()
            : 1;
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
        if (stop.getResponseError() instanceof ResponseError) {
            // rerequest
            if (stop.getResponseError().isRerequestable()) {
                requestDepartures();
                stop.setSearching();
                WatchUi.requestUpdate();
            }
        }
        else if (stop.getModeCount() > 1) {
            // rotate mode
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
