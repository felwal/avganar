using Toybox.System;

(:glance)
module Log {

    function i(str) {
        if (DEBUG) {
            System.println("I: " + str);
        }
    }

    function d(str) {
        if (DEBUG) {
            System.println("D: " + str);
        }
    }

    function w(str) {
        if (DEBUG) {
            System.println("W: " + str);
        }
    }

    function e(str) {
        if (DEBUG) {
            System.println("E: " + str);
        }
    }

}
