// This file is part of Avgånär.
//
// Avgånär is free software: you can redistribute it and/or modify it under the terms of
// the GNU General Public License as published by the Free Software Foundation,
// either version 3 of the License, or (at your option) any later version.
//
// Avgånär is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
// without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with Avgånär.
// If not, see <https://www.gnu.org/licenses/>.

using Toybox.Lang;
using Toybox.Math;
using Toybox.Timer;
using Toybox.WatchUi;

class StopDetailViewModel {

    static hidden const _SCREEN_TIME_INTERVAL = 15 * 1000;
    static hidden const _REQUEST_TIME_INTERVAL = 2 * 60 * 1000;

    static const DEPARTURES_PER_PAGE = 4;

    var stop;
    var pageCount = 1;
    var pageCursor = 0;
    var currentMode = Departure.MODE_ALL;
    var departureCursor = 0;
    var isDepartureState = false;
    var isModePaneState = false;
    var isInitialRequest = true; // TODO: replace with check against currentMode?

    hidden var _lastPageDepartureCount = 0;
    hidden var _delayTimer = new Timer.Timer();
    hidden var _repeatTimer = new TimerWrapper();

    // init

    function initialize(stop) {
        me.stop = stop;

        // when initial mode menu is open,
        // (ie dont request automatically; wait for user input),
        // or we are waiting for that first response
        isInitialRequest = stop.getAddedModesCount() == 0 && stop.getModesKeys().size() > 1;
        currentMode = stop.getModeKey(0);
    }

    // request

    function enableRequests() {
        if (isInitialRequest) {
            // remind the user of the initial mode menu.
            // since it didn't exist in previous versions it's easy to forget
            SystemUtil.vibrateShort();
        }
        else {
            _requestDeparturesDelayed();
        }
    }

    function disableRequests() {
        _delayTimer.stop();
        _repeatTimer.stop();
    }

    hidden function _requestDeparturesDelayed() {
        var age = stop.getDataAgeMillis(currentMode);
        // never request more frequently than _REQUEST_TIME_INTERVAL.
        var delay = age == null ? 0 : _REQUEST_TIME_INTERVAL - age;

        // 50 ms is the minimum time value
        if (delay <= 50) {
            onDelayedDeparturesRequest();
        }
        else {
            _delayTimer.stop();
            _delayTimer.start(method(:onDelayedDeparturesRequest), delay, false);
        }
    }

    function onDelayedDeparturesRequest() {
        _requestDepartures();
        _startRepeatTimer();
    }

    hidden function _startRepeatTimer() {
        if (_repeatTimer.isInitialized()) {
            _repeatTimer.restart();
            return;
        }

        var screenTimer = new TimerRepr(new Lang.Method(WatchUi, :requestUpdate), 1);
        var requestTimer = new TimerRepr(method(:onTimer), _REQUEST_TIME_INTERVAL / _SCREEN_TIME_INTERVAL);

        _repeatTimer.start(_SCREEN_TIME_INTERVAL, [ screenTimer, requestTimer ]);
    }

    function onTimer() {
        if (stop.getResponse(currentMode) instanceof ResponseError
            && !stop.getResponse(currentMode).isTimerRefreshable()) {

            return;
        }

        _requestDepartures();
    }

    hidden function _requestDepartures() {
        new DeparturesService(stop).requestDepartures(currentMode);
    }

    // read

    //! Get only the departures that should be
    //! displayed on the current page
    function getPageResponse() {
        if (isInitialRequest || isModePaneState) {
            // should not happen, but check just in case
            Log.w("Called getPageResponse() when in mode menu");
            return null;
        }

        if (currentMode == null || currentMode.equals(Departure.MODE_ALL)) {
            currentMode = stop.getModeKey(0);

            if (currentMode == null) {
                return null;
            }
        }

        var modeResponse = stop.getModeResponse(currentMode);

        if (!(modeResponse instanceof Lang.Array)) {
            pageCount = 1;
            isDepartureState = false;
            return modeResponse;
        }

        _lastPageDepartureCount = modeResponse.size() % DEPARTURES_PER_PAGE;
        if (_lastPageDepartureCount == 0) {
            _lastPageDepartureCount = DEPARTURES_PER_PAGE;
        }
        pageCount = Math.ceil(modeResponse.size().toFloat() / DEPARTURES_PER_PAGE).toNumber();

        // coerce cursor
        pageCursor = MathUtil.min(pageCursor, pageCount - 1);

        // get page range
        var startIndex = pageCursor * DEPARTURES_PER_PAGE;
        var endIndex = startIndex + DEPARTURES_PER_PAGE;

        // slice to page range
        return modeResponse.slice(startIndex, endIndex);
    }

    function canNavigateToDeviation() {
        return !isDepartureState
            && !isInitialRequest
            && !isModePaneState
            && pageCursor == 0
            && stop.getDeviationMessages().size() != 0;
    }

    // write

    function toggleDepartureState() {
        isDepartureState = !isDepartureState;
        departureCursor = 0;
        WatchUi.requestUpdate();
    }

    function onScrollDown() {
        if (!isModePaneState
            && stop.getResponse(currentMode) instanceof ResponseError
            && stop.getResponse(currentMode).isUserRefreshable()) {

            // refresh
            stop.resetResponse(currentMode);
            _requestDepartures();
            WatchUi.requestUpdate();
        }
        else if (isDepartureState) {
            _incDepartureCursor();
        }
        else {
            _incPageCursor();
        }

        WatchUi.requestUpdate();
    }

    function onScrollUp() {
        if (isDepartureState) {
            _decDepartureCursor();
        }
        else {
            _decPageCursor();
        }

        WatchUi.requestUpdate();
    }

    //! @return true if successfully rotating
    hidden function _incPageCursor() {
        if (isInitialRequest || isModePaneState) {
            if (pageCursor < stop.getModesKeys().size() - 1) {
                pageCursor++;
                return true;
            }

            return false;
        }
        else if (pageCursor < pageCount - 1) {
            pageCursor++;
            return true;
        }

        return false;
    }

    //! @return true if successfully rotating
    hidden function _decPageCursor() {
        if (pageCursor > 0) {
            pageCursor--;
            return true;
        }
        else if (canNavigateToDeviation()) {
            DialogView.push(null, stop.getDeviationMessages(), Rez.Drawables.ic_warning, WatchUi.SLIDE_DOWN);
        }

        return false;
    }

    hidden function _incDepartureCursor() {
        if (departureCursor < DEPARTURES_PER_PAGE - 1
            && (pageCursor < pageCount - 1 || departureCursor < _lastPageDepartureCount - 1)) {

            departureCursor++;
        }
        else if (_incPageCursor()) {
            departureCursor = 0;
        }
    }

    hidden function _decDepartureCursor() {
        if (departureCursor > 0) {
            departureCursor--;
        }
        else if (_decPageCursor()) {
            departureCursor = DEPARTURES_PER_PAGE - 1;
        }
    }

    function onSelect() {
        // select departure
        if (isDepartureState) {
            var modeResponse = stop.getModeResponse(currentMode);
            var selectedDeparture = modeResponse[pageCursor * 4 + departureCursor];
            var messages = selectedDeparture.getDeviationMessages();

            if (messages.size() == 0) {
                messages.add(rez(Rez.Strings.lbl_detail_deviation_none));
            }

            DialogView.push(null, messages, Rez.Drawables.ic_warning, WatchUi.SLIDE_LEFT);
        }

        // select mode
        else if (isInitialRequest) {
            isInitialRequest = false;
            currentMode = stop.getModeKey(pageCursor);
            pageCursor = 0;

            _requestDeparturesDelayed();
        }
        else if (isModePaneState) {
            isModePaneState = false;
            currentMode = stop.getModeKey(pageCursor);
            pageCursor = 0;

            if (!stop.hasResponse(currentMode)) {
                onDelayedDeparturesRequest();
            }
            else {
                _requestDeparturesDelayed();
                WatchUi.requestUpdate();
            }
        }

        // enter mode menu
        else if (stop.getModesCount() > 1) {
            isModePaneState = true;
            // set cursor to index of current mode
            pageCursor = MathUtil.max(0, stop.getModesKeys().indexOf(currentMode));
            WatchUi.requestUpdate();
        }

        else {
            // always update screen on click
            WatchUi.requestUpdate();
        }
    }

}
