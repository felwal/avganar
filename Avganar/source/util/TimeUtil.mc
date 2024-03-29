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

using Toybox.System;
using Toybox.Time;

module TimeUtil {

    function now() {
        return new Time.Moment(Time.now().value());
    }

    //! Convert String on the format "YYYY-MM-DDThh:mm:ss" to Moment
    function iso8601StrToMoment(str) {
        if (str == null || str.length() != 19) {
            //Log.w(str + " not of ISO8601 (YYYY-MM-DDThh:mm:ss)");
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

    function localIso8601StrToMoment(str) {
        var moment = iso8601StrToMoment(str);

        if (moment != null) {
            // subtract timezone offset
            var utcOffsetSec = System.getClockTime().timeZoneOffset;
            var utcOffsetDur = new Time.Duration(utcOffsetSec);
            moment = moment.subtract(utcOffsetDur);
        }

        return moment;
    }

}
