using Toybox.Math;
using Toybox.Application;

// math

//! The Monkey C modulo operator uses truncated division, which gives the remainder with same sign as the dividend.
//! This uses floored division, which gives the remainder with same sign as the divisor.
function mod(dividend, divisor) {
    var quotient = Math.floor(dividend.toFloat() / divisor.toFloat()).toNumber();
    var remainder = dividend - divisor * quotient;
    return remainder;
}

function coerceIn(value, min, max) {
    return min > max ? null : (value < min ? min : (value > max ? max : value));
}

function min(a, b) {
    return a <= b ? a : b;
}

function max(a, b) {
    return a >= b ? a : b;
}

// resource

(:glance)
function rez(rezId) {
    return Application.loadResource(rezId);
}
