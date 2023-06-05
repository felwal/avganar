using Toybox.System;
using Toybox.Time;

module TimeUtil {

    function now() {
        return new Time.Moment(Time.now().value());
    }

    //! Convert String on the format "YYYY-MM-DDThh:mm:ss" to Moment
    function iso8601StrToMoment(str) {
        if (str == null || str.length() != 19) {
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
