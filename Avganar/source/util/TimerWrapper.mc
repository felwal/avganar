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

using Toybox.Timer;

//! Synthesise multiple timers by only using one `Timer`.
class TimerWrapper {

    hidden var _timer;
    hidden var _baseTime;
    hidden var _reprs;

    function initialize() {
        _timer = new Timer.Timer();
    }

    //! @baseTime the smallest "timer" duration, of wich all other "timers"
    //! should be multiples
    function start(baseTime, reprs) {
        _baseTime = baseTime;
        _reprs = reprs;

        _timer.start(method(:onTimer), _baseTime, true);
    }

    function stop() {
        _timer.stop();
    }

    function onTimer() {
        for (var i = 0; i < _reprs.size(); i++) {
            _reprs[i].onBaseTime();
        }
    }

}

//! Representation of a Timer.
class TimerRepr {

    hidden var _callback;
    hidden var _multiple;
    hidden var _currentMultiple = 0;

    function initialize(callback, multipleOfBaseTime) {
        _callback = callback;
        _multiple = multipleOfBaseTime;
    }

    function onBaseTime() {
        _currentMultiple++;

        if (_currentMultiple >= _multiple) {
            _currentMultiple = 0;
            _callback.invoke();
        }
    }

}
