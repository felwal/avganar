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

using Toybox.System;

//! Logging made (a bit) simpler.
//! Should not be included in release builds.
(:glance :debug)
module Log {

    function i(str as String) as Void {
        System.println("I: " + str);
    }

    function d(str as String) as Void {
        System.println("D: " + str);
    }

    function w(str as String) as Void {
        System.println("W: " + str);
    }

    function e(str as String) as Void {
        System.println("E: " + str);
    }

}
