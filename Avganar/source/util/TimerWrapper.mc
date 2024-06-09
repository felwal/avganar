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

//! Synthesise multiple timers by only using one `Timer`.
class TimerWrapper {

    private var _timer as Timer.Timer;
    private var _baseTime as Number?;
    private var _reprs as Array<TimerRepr>?;

    function initialize() {
        _timer = new Timer.Timer();
    }

    //! @baseTime the smallest "timer" duration, of wich all other "timers"
    //! should be multiples
    function start(baseTime as Number, reprs as Array<TimerRepr>) as Void {
        _baseTime = baseTime;
        _reprs = reprs;

        _timer.start(method(:onTimer), _baseTime, true);
    }

    function stop() as Void {
        _timer.stop();
    }

    function restart() as Void {
        stop();
        _timer.start(method(:onTimer), _baseTime, true);
    }

    function isInitialized() as Boolean {
        return _reprs != null;
    }

    function onTimer() as Void {
        for (var i = 0; i < _reprs.size(); i++) {
            _reprs[i].onBaseTime();
        }
    }

}

//! Representation of a Timer.
class TimerRepr {

    private var _callback as Method;
    private var _multiple as Number;
    private var _currentMultiple = 0;

    function initialize(callback as Method, multipleOfBaseTime as Number) {
        _callback = callback;
        _multiple = multipleOfBaseTime;
    }

    function onBaseTime() as Void {
        _currentMultiple++;

        if (_currentMultiple >= _multiple) {
            _currentMultiple = 0;
            _callback.invoke();
        }
    }

}
