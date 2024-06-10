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

import Toybox.Lang;
import Toybox.Timer;

using Toybox.Math;
using Toybox.WatchUi;

class StopDetailViewModel {

    static const DEPARTURES_PER_PAGE = 4;

    static private const _TIME_INTERVAL_SCREEN = 15 * 1000;
    static private const _TIME_INTERVAL_REQUEST = 2 * 60 * 1000;

    var stop as StopType;
    var pageCount as Number = 1;
    var pageCursor as Number = 0;
    var departureCursor as Number = 0;
    var isDepartureState as Boolean = false;
    var isModeMenuState as Boolean = false;
    var isInitialRequest as Boolean = true; // TODO: replace with check against _currentModeKey?

    private var _currentModeKey as String;
    private var _lastPageDepartureCount as Number = 0;
    private var _delayTimer as Timer.Timer = new Timer.Timer();
    private var _repeatTimer as TimeUtil.TimerWrapper = new TimeUtil.TimerWrapper();

    // init

    function initialize(stop as StopType) {
        me.stop = stop;

        // when initial mode menu is open,
        // (ie dont request automatically; wait for user input),
        // or we are waiting for that first response
        isInitialRequest = stop.getAddedModesCount() == 0 && stop.getModesKeys().size() > 1;
        _currentModeKey = stop.getModeKey(0);
    }

    // request

    function enableRequests() as Void {
        if (isInitialRequest) {
            // remind the user of the initial mode menu.
            // since it didn't exist in previous versions it's easy to forget
            SystemUtil.vibrateShort();
        }
        else {
            _requestDeparturesDelayed();
        }
    }

    function disableRequests() as Void {
        _delayTimer.stop();
        _repeatTimer.stop();
    }

    private function _requestDeparturesDelayed() as Void {
        var age = stop.getMode(_currentModeKey).getDataAgeMillis();
        // never request more frequently than _TIME_INTERVAL_REQUEST.
        var delay = age == null ? 0 : _TIME_INTERVAL_REQUEST - age;

        // 50 ms is the minimum time value
        if (delay <= 50) {
            onDelayedDeparturesRequest();
        }
        else {
            _delayTimer.stop();
            _delayTimer.start(method(:onDelayedDeparturesRequest), delay, false);
        }
    }

    function onDelayedDeparturesRequest() as Void {
        _requestDepartures();
        _startRepeatTimer();
    }

    private function _startRepeatTimer() as Void {
        if (_repeatTimer.isInitialized()) {
            _repeatTimer.restart();
            return;
        }

        var screenTimer = new TimeUtil.TimerRepr(new Lang.Method(WatchUi, :requestUpdate), 1);
        var requestTimer = new TimeUtil.TimerRepr(method(:onTimer), _TIME_INTERVAL_REQUEST / _TIME_INTERVAL_SCREEN);

        _repeatTimer.start(_TIME_INTERVAL_SCREEN, [ screenTimer, requestTimer ]);
    }

    function onTimer() as Void {
        var response = stop.getMode(_currentModeKey).getResponse();

        if (response instanceof ResponseError && !response.isTimerRefreshable()) {
            return;
        }

        _requestDepartures();
    }

    private function _requestDepartures() as Void {
        new DeparturesService(stop).requestDepartures(_currentModeKey);
        WatchUi.requestUpdate();
    }

    // read

    function getCurrentModeKey() as String {
        // NOTE: API limitation
        return !_currentModeKey.equals(Mode.KEY_ALL)
            ? _currentModeKey
            : stop.getModeKey(0);
    }

    //! Get only the departures that should be
    //! displayed on the current page
    function getPageResponse() as DeparturesResponse {
        if (isInitialRequest || isModeMenuState) {
            // should not happen, but check just in case
            return null;
        }

        _currentModeKey = getCurrentModeKey();
        var response = stop.getMode(_currentModeKey).getResponse();

        if (!(response instanceof Lang.Array) || response.size() == 0) {
            pageCount = 1;
            isDepartureState = false;
            return response;
        }

        _lastPageDepartureCount = response.size() % DEPARTURES_PER_PAGE;

        if (_lastPageDepartureCount == 0) {
            _lastPageDepartureCount = DEPARTURES_PER_PAGE;
        }

        pageCount = Math.ceil(response.size().toFloat() / DEPARTURES_PER_PAGE).toNumber();
        pageCursor = MathUtil.min(pageCursor, pageCount - 1); // coerce cursor

        // get page range
        var startIndex = pageCursor * DEPARTURES_PER_PAGE;
        var endIndex = startIndex + DEPARTURES_PER_PAGE;

        // slice to page range
        return response.slice(startIndex, endIndex);
    }

    function canNavigateToDeviation() as Boolean {
        return !isDepartureState
            && !isInitialRequest
            && !isModeMenuState
            && pageCursor == 0
            && stop.getDeviationMessages().size() != 0;
    }

    // input

    function toggleDepartureState() as Void {
        isDepartureState = !isDepartureState;
        departureCursor = 0;
        WatchUi.requestUpdate();
    }

    function onScrollDown() as Void {
        var response = stop.getMode(_currentModeKey).getResponse();

        if (!isModeMenuState
            && response instanceof ResponseError && response.isUserRefreshable()) {

            // refresh
            stop.resetMode(_currentModeKey);
            _requestDepartures();
            return;
        }

        var wasCursorModified = isDepartureState
            ? _incDepartureCursor()
            : _incPageCursor();

        // only refresh if changed
        if (wasCursorModified) {
            WatchUi.requestUpdate();
        }
    }

    function onScrollUp() as Void {
        var wasCursorModified = isDepartureState
            ? _decDepartureCursor()
            : _decPageCursor();

        // only refresh if changed
        if (wasCursorModified) {
            WatchUi.requestUpdate();
        }
    }

    //! @return true if successfully rotating
    private function _incPageCursor() as Boolean {
        if (isInitialRequest || isModeMenuState) {
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
    private function _decPageCursor() as Boolean {
        if (pageCursor > 0) {
            pageCursor--;
            return true;
        }
        else if (canNavigateToDeviation()) {
            DialogView.push(null, stop.getDeviationMessages(), Rez.Drawables.ic_warning, WatchUi.SLIDE_DOWN);
        }

        return false;
    }

    //! @return true if successfully rotating
    private function _incDepartureCursor() as Boolean {
        if (departureCursor < DEPARTURES_PER_PAGE - 1
            && (pageCursor < pageCount - 1 || departureCursor < _lastPageDepartureCount - 1)) {

            departureCursor++;
            return true;
        }
        else if (_incPageCursor()) {
            departureCursor = 0;
            return true;
        }

        return false;
    }

    //! @return true if successfully rotating
    private function _decDepartureCursor() as Boolean {
        if (departureCursor > 0) {
            departureCursor--;
            return true;
        }
        else if (_decPageCursor()) {
            departureCursor = DEPARTURES_PER_PAGE - 1;
            return true;
        }

        return false;
    }

    function onSelect() as Void {
        // select departure
        if (isDepartureState) {
            var response = stop.getMode(_currentModeKey).getResponse();
            var selectedDeparture = response[pageCursor * 4 + departureCursor];
            var messages = selectedDeparture.getDeviationMessages();

            if (messages.size() == 0) {
                messages.add(getString(Rez.Strings.lbl_detail_deviation_none));
            }

            DialogView.push(null, messages, Rez.Drawables.ic_warning, WatchUi.SLIDE_LEFT);
        }

        // select mode
        else if (isInitialRequest) {
            isInitialRequest = false;
            _currentModeKey = stop.getModeKey(pageCursor);
            pageCursor = 0;

            _requestDeparturesDelayed();
        }
        else if (isModeMenuState) {
            isModeMenuState = false;
            _currentModeKey = stop.getModeKey(pageCursor);
            pageCursor = 0;

            if (!stop.hasMode(_currentModeKey)) {
                onDelayedDeparturesRequest();
            }
            else {
                _requestDeparturesDelayed();
                WatchUi.requestUpdate();
            }
        }

        // enter mode menu
        else if (stop.getModesCount() > 1) {
            isModeMenuState = true;
            // set cursor to index of current mode
            pageCursor = MathUtil.max(0, stop.getModesKeys().indexOf(_currentModeKey));
            WatchUi.requestUpdate();
        }

        else {
            // always update screen on click
            WatchUi.requestUpdate();
        }
    }

}
