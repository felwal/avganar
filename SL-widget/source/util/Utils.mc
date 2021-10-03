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
function addArrays(arr1, arr2) {
    var sum = [];

    for (var i = 0; i < arr1.size() && i < arr2.size(); i++) {
        sum.add(arr1[i] + arr2[i]);
    }

    return sum;
}

// type

(:glance)
function hasKey(dict, key) {
    return dict != null && dict.hasKey(key) && dict[key] != null;
}

// resource

(:glance)
function rez(rezId) {
    return Application.loadResource(rezId);
}
