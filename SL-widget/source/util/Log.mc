import Toybox.Lang;

using Toybox.System;

(:glance)
class Log {

    static function i(str) as Void {
        System.println("I: " + str);
    }

    static function d(str) as Void {
        System.println("D: " + str);
    }

    static function w(str) as Void {
        System.println("W: " + str);
    }

    static function e(str) as Void {
        System.println("E: " + str);
    }

}
