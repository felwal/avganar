using Toybox.System;

(:glance)
class Log {

    static function i(str) {
        if (DEBUG) {
            System.println("I: " + str);
        }
    }

    static function d(str) {
        if (DEBUG) {
            System.println("D: " + str);
        }
    }

    static function w(str) {
        if (DEBUG) {
            System.println("W: " + str);
        }
    }

    static function e(str) {
        if (DEBUG) {
            System.println("E: " + str);
        }
    }

}
