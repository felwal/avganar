using Toybox.Math;

//! The Monkey C modulo operator uses truncated division, which gives the remainder with same sign as the dividend.
//! This uses floored division, which gives the remainder with same sign as the divisor.
function mod(dividend, divisor) {
    var quotient = Math.floor(dividend.toFloat() / divisor.toFloat()).toNumber();
    var remainder = dividend - divisor * quotient;
    return remainder;
}
