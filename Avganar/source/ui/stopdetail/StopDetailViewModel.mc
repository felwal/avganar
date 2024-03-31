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

    static hidden const _REFRESH_TIME_INTERVAL = 15 * 1000;
    static hidden const _REQUEST_TIME_INTERVAL = 2 * 60 * 1000;

    static const DEPARTURES_PER_PAGE = 4;

    var stop;
    var pageCount = 1;
    var pageCursor = 0;
    var modeCursor = 0;
    var departureCursor = 0;
    var isDepartureState = false;
    var isInitialRequest = true;

    hidden var _lastPageDepartureCount = 0;
    hidden var _delayTimer = new Timer.Timer();
    hidden var _repeatTimer = new TimerWrapper();

    // init

    function initialize(stop) {
        me.stop = stop;

        // when initial mode menu is open,
        // (ie dont request automatically; wait for user input),
        // or we are waiting for that first response
        isInitialRequest = stop.getResponse() == null && stop.getAddableModesCount() > 1;
    }

    // request

    function enableRequests() {
        if (!isInitialRequest) {
            _requestDeparturesDelayed();
        }
    }

    function disableRequests() {
        _delayTimer.stop();
        _repeatTimer.stop();
    }

    hidden function _requestDeparturesDelayed() {
        var age = stop.getDataAgeMillis();
        // never request more frequently than _REQUEST_TIME_INTERVAL.
        var delay = age == null ? 0 : _REQUEST_TIME_INTERVAL - age;

        // 50 ms is the minimum time value
        if (delay <= 50) {
            onDelayedDeparturesRequest();
        }
        else {
            _delayTimer.start(method(:onDelayedDeparturesRequest), delay, false);
        }
    }

    function onDelayedDeparturesRequest() {
        _requestDepartures(getCurrentModeKey());
        _startRepeatTimer();
    }

    hidden function _startRepeatTimer() {
        var screenTimer = new TimerRepr(new Lang.Method(WatchUi, :requestUpdate), 1);
        var requestTimer = new TimerRepr(method(:onTimer), _REQUEST_TIME_INTERVAL / _REFRESH_TIME_INTERVAL);

        _repeatTimer.start(_REFRESH_TIME_INTERVAL, [ screenTimer, requestTimer ]);
    }

    function onTimer() {
        if (stop.getResponse() instanceof ResponseError
            && !stop.getResponse().isTimerRefreshable()) {
            return;
        }

        _requestDepartures(getCurrentModeKey());
    }

    hidden function _requestDepartures(mode) {
        new DeparturesService(stop).requestDepartures(mode);
    }

    // read

    //! Get only the departures that should be
    //! displayed on the current page
    function getPageResponse() {
        if (isInitialRequest || isAddModesPaneSelected()) {
            // should not happen, but check just in case
            return null;
        }

        var responseAndMode = stop.getModeResponse(modeCursor);
        var modeResponse = responseAndMode[0];
        modeCursor = responseAndMode[1]; // the cursor might have been coerced
        responseAndMode = null;

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
            && !isAddModesPaneSelected()
            && pageCursor == 0
            && stop.getDeviationMessages().size() != 0;
    }

    function getCurrentModeKey() {
        // for auto-refreshing
        // TODO: only temporarily (?)

        // NOTE: migration to 1.8.0
        // iif products are unknown, return null => request all modes
        if (stop.getProducts() == null) {
            return null;
        }

        var mode = isAddModesPaneSelected() ? modeCursor - 1 : modeCursor;
        return stop.getAddedModeKey(mode);
    }

    function isAddModesPaneSelected() {
        return includeAddModesPane() ? modeCursor == getModePageCount() - 1 : false;
    }

    function getModePageCount() {
        return stop.getAddedModesCount() + (includeAddModesPane() ? 1 : 0);
    }

    function includeAddModesPane() {
        // if loading (response = null), there is 1 mode that isnt yet added
        // but also shouldnt count as addable. TODO: this is only a temp fix
        // to avoid showing hori page indicator when initially requesting
        // for a stop with only one mode.
        return stop.getAddableModesCount() > (stop.getResponse() == null ? 1 : 0);
    }

    // write

    function toggleDepartureState() {
        isDepartureState = !isDepartureState;
        departureCursor = 0;
        WatchUi.requestUpdate();
    }

    //! Scrolling down
    function incCursor() {
        if (stop.getResponse() instanceof ResponseError
            && stop.getResponse().isUserRefreshable()
            && !isAddModesPaneSelected()) {

            // refresh
            stop.resetResponse();
            _requestDepartures(getCurrentModeKey());
            WatchUi.requestUpdate();
        }
        else if (isDepartureState) {
            if (departureCursor < DEPARTURES_PER_PAGE - 1
                && (pageCursor < pageCount - 1 || departureCursor < _lastPageDepartureCount - 1)) {

                departureCursor++;
            }
            else if (_incPageCursor()) {
                departureCursor = 0;
            }
        }
        else {
            _incPageCursor();
        }

        WatchUi.requestUpdate();
    }

    //! Scrolling up
    function decCursor() {
        if (isDepartureState) {
            if (departureCursor > 0) {
                departureCursor--;
            }
            else if (_decPageCursor()) {
                departureCursor = DEPARTURES_PER_PAGE - 1;
            }
        }
        else {
            _decPageCursor();
        }

        WatchUi.requestUpdate();
    }

    hidden function _incPageCursor() {
        if (isInitialRequest) {
            if (pageCursor < stop.getAddableModesCount() - 1) {
                pageCursor++;
                return true;
            }

            return false;
        }
        else if (isAddModesPaneSelected()) {
            // +1 because of "Continue" item
            if (pageCursor < stop.getAddableModesCount()) {
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

    function onSelect() {
        if (isDepartureState) {
            var responseAndMode = stop.getModeResponse(modeCursor);
            var modeResponse = responseAndMode[0];
            var selectedDeparture = modeResponse[pageCursor * 4 + departureCursor];
            var messages = selectedDeparture.getDeviationMessages();

            if (messages.size() == 0) {
                messages.add(rez(Rez.Strings.lbl_detail_deviation_none));
            }

            DialogView.push(null, messages, Rez.Drawables.ic_warning, WatchUi.SLIDE_LEFT);
        }
        else if (isInitialRequest) {
            var mode = stop.getAddableModeKey(pageCursor);
            _requestDepartures(mode);

            isInitialRequest = false;
            pageCursor = 0;
        }
        else if (isAddModesPaneSelected()) {
            if (pageCursor == 0) {
                onNextMode();
            }
            else {
                // -1 because of "Confirm" item
                var mode = stop.getAddableModeKey(pageCursor - 1);
                _requestDepartures(mode);
                _incModeCursor();
            }
        }
        else {
            onNextMode();
        }
    }

    function onNextMode() {
        if (getModePageCount() > 1) {
            // rotate mode
            _incModeCursor();
            WatchUi.requestUpdate();
        }
    }

    hidden function _incModeCursor() {
        modeCursor = MathUtil.mod(modeCursor + 1, getModePageCount());
        pageCursor = 0;
        WatchUi.requestUpdate();
    }

}
