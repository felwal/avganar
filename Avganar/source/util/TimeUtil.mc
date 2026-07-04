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
import Toybox.Time;
import Toybox.Timer;

using Toybox.System;

module TimeUtil {

    //! Convert String on the format "YYYY-MM-DDThh:mm:ss" to Moment
    function iso8601StrToMoment(str as String?) as Moment? {
        if (str == null || str.length() != 19) {
            //Log.w(str + " not in ISO8601 (YYYY-MM-DDThh:mm:ss)");
            return null;
        }

        var year = str.substring(0, 4).toNumber();
        var month = str.substring(5, 7).toNumber();
        var day = str.substring(8, 10).toNumber();
        var hour = str.substring(11, 13).toNumber();
        var minute = str.substring(14, 16).toNumber();
        var second = str.substring(17, 19).toNumber();

        var options = {
            :year => year,
            :month => month,
            :day => day,
            :hour => hour,
            :minute => minute,
            :second => second
        };

        return Time.Gregorian.moment(options);
    }

    function localIso8601StrToMoment(str as String?) as Moment? {
        var moment = iso8601StrToMoment(str);

        if (moment != null) {
            // subtract timezone offset
            var utcOffsetSec = System.getClockTime().timeZoneOffset;
            var utcOffsetDur = new Time.Duration(utcOffsetSec);
            moment = moment.subtract(utcOffsetDur);
        }

        return moment;
    }

    // classes

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
        private var _currentMultiple as Number = 0;

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

}
