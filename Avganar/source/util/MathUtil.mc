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

import Toybox.Graphics;
import Toybox.Lang;

using Toybox.Math;

module MathUtil {

    const TAU = 6.28318530717958647692;

    // geometry

    //! Get carteesian coordinates from polar coordinates
    //! @param angle The argument of the position, in radians
    //! @param x0, y0 The x- and y-coordinates of the center
    function polarPos(amp as Numeric, angle as Float, x0 as Numeric, y0 as Numeric) as Point2D {
        var x = amp * Math.cos(angle) + x0;
        // multiply by -1 to handle screen y increase downwards
        var y = -1 * amp * Math.sin(angle) + y0;
        return [ x, y ];
    }

    //! Calculate the leftmost x-coordinate of a circular screen at a specific y
    function minX(y as Numeric, r as Numeric) as Numeric? {
        if (y < 0 || y > 2 * r) {
            return null;
        }
        return -Math.sqrt(Math.pow(r, 2) - Math.pow(y - r, 2)) + r;
    }

    //! Calculate the rightmost x-coordinate of a circular screen at a specific y
    function maxX(y as Numeric, r as Numeric) as Numeric? {
        if (y < 0 || y > 2 * r) {
            return null;
        }
        return Math.sqrt(Math.pow(r, 2) - Math.pow(y - r, 2)) + r;
    }

    function deg(rad as Decimal) as Decimal {
        return 360 * rad / TAU;
    }


    function rad(deg as Decimal) as Decimal {
        return TAU * deg / 360;
    }

    // misc

    function min(a as Numeric, b as Numeric) as Numeric {
        return a <= b ? a : b;
    }

    function max(a as Numeric, b as Numeric) as Numeric {
        return a >= b ? a : b;
    }

    function coerceIn(value as Numeric, min as Numeric, max as Numeric) as Numeric? {
        return min > max ? null : (value < min ? min : (value > max ? max : value));
    }

    function abs(x as Numeric) as Numeric {
        return x < 0 ? -x : x;
    }

    //! The Monkey C modulo operator uses truncated division, which gives the remainder with same sign as the dividend.
    //! This uses floored division, which gives the remainder with same sign as the divisor.
    function modulo(dividend as Numeric, divisor as Numeric) as Numeric {
        var quotient = Math.floor(dividend.toFloat() / divisor.toFloat()).toNumber();
        var remainder = dividend - divisor * quotient;
        return remainder;
    }

    //! Get a share between 0–1. For each recursion, add that share of what's left.
    function recursiveShare(shareOfRemainder as Float, prevVal as Float, recursions as Number) as Float {
        var newVal = prevVal + (1 - prevVal) * shareOfRemainder;

        return recursions > 0
            ? recursiveShare(shareOfRemainder, newVal, recursions - 1)
            : newVal;
    }

}
