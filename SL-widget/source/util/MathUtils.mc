import Toybox.Lang;

using Toybox.Math;

//! The Monkey C modulo operator uses truncated division, which gives the remainder with same sign as the dividend.
//! This uses floored division, which gives the remainder with same sign as the divisor.
function mod(dividend as Number, divisor as Number) as Number {
    var quotient = Math.floor(dividend.toFloat() / divisor.toFloat()).toNumber();
    var remainder = dividend - divisor * quotient;
    return remainder;
}
