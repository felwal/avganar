using Toybox.Lang;
using Toybox.Math;
using Toybox.Timer;
using Toybox.WatchUi;
using Carbon.Chem;

class StopDetailViewModel {

    static hidden const _REFRESH_TIME_INTERVAL = 15 * 1000;
    static hidden const _REQUEST_TIME_INTERVAL = 2 * 60 * 1000;
    static hidden const _REQUEST_TIME_DELAY = 500;

    static const DEPARTURES_PER_PAGE = 4;

    var stop;
    var pageCount = 1;
    var pageCursor = 0;
    var modeCursor = 0;

    hidden var _delayTimer = new Timer.Timer();
    hidden var _repeatTimer = new TimerWrapper();

    // init

    function initialize(stop) {
        me.stop = stop;
    }

    // request

    function enableRequests() {
        _requestDeparturesDelayed();
    }

    function disableRequests() {
        _delayTimer.stop();
        _repeatTimer.stop();
    }

    hidden function _requestDeparturesDelayed() {
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

    hidden function _startRepeatTimer() {
        var refreshTimer = new TimerRepr(new Lang.Method(WatchUi, :requestUpdate), 1);
        var requestTimer = new TimerRepr(method(:requestDepartures), _REQUEST_TIME_INTERVAL / _REFRESH_TIME_INTERVAL);

        _repeatTimer.start(_REFRESH_TIME_INTERVAL, [ refreshTimer, requestTimer ]);
    }

    //! Needs to be public to be able to be called by timer.
    function requestDepartures() {
        new DeparturesService(stop).requestDepartures();
    }

    // read

    function getPageResponse() {
        var responseAndMode = stop.getModeResponse(modeCursor);
        var modeResponse = responseAndMode[0];
        modeCursor = responseAndMode[1]; // the cursor might have been coerced
        responseAndMode = null;

        if (!(modeResponse instanceof Lang.Array)) {
            pageCount = 1;
            return modeResponse;
        }

        pageCount = Math.ceil(modeResponse.size().toFloat() / DEPARTURES_PER_PAGE).toNumber();

        // coerce cursor
        pageCursor = Chem.min(pageCursor, pageCount - 1);

        // get page range
        var startIndex = pageCursor * DEPARTURES_PER_PAGE;
        var endIndex = startIndex + DEPARTURES_PER_PAGE;

        // slice to page range
        return modeResponse.slice(startIndex, endIndex);
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
        if (stop.response instanceof ResponseError) {
            // rerequest
            if (stop.response.isRerequestable()) {
                stop.resetResponse();
                requestDepartures();
                WatchUi.requestUpdate();
            }
        }
        else if (stop.getModeCount() > 1) {
            // rotate mode
            _incModeCursor();
            WatchUi.requestUpdate();
        }
    }

    hidden function _incModeCursor() {
        modeCursor = Chem.mod(modeCursor + 1, stop.getModeCount());
        pageCursor = 0;
        WatchUi.requestUpdate();
    }

}
