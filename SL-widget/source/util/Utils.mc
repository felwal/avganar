using Toybox.Math;
using Toybox.Application;

// math

//! The Monkey C modulo operator uses truncated division, which gives the remainder with same sign as the dividend.
//! This uses floored division, which gives the remainder with same sign as the divisor.
(:glance)
function mod(dividend, divisor) {
    var quotient = Math.floor(dividend.toFloat() / divisor.toFloat()).toNumber();
    var remainder = dividend - divisor * quotient;
    return remainder;
}

(:glance)
function coerceIn(value, min, max) {
    return min > max ? null : (value < min ? min : (value > max ? max : value));
}

// resource

(:glance)
function rez(rezId) {
    return Application.loadResource(rezId);
}
