using Toybox.Application;
using Toybox.Attention;
using Toybox.System;
using Toybox.Math;

// app

(:glance)
function buildStops(ids, names) {
    var stops = [];

    for (var i = 0; i < ids.size() && i < names.size(); i++) {
        var stop = new Stop(ids[i], names[i], null);
        stops.add(stop);
    }

    return stops;
}

// math

//! The Monkey C modulo operator uses truncated division, which gives the remainder with same sign as the dividend.
//! This uses floored division, which gives the remainder with same sign as the divisor.
function mod(dividend, divisor) {
    var quotient = Math.floor(dividend.toFloat() / divisor.toFloat()).toNumber();
    var remainder = dividend - divisor * quotient;
    return remainder;
}

(:glance)
function coerceIn(value, min, max) {
    return min > max ? null : (value < min ? min : (value > max ? max : value));
}

function min(a, b) {
    return a <= b ? a : b;
}

function max(a, b) {
    return a >= b ? a : b;
}

//! In radians
function distanceBetween(lat1, lon1, lat2, lon2) {
    var R = 6371000;

    var phi1 = lat1 - Math.PI / 2;
    var phi2 = lat2 - Math.PI / 2;

    var x1 = R * Math.sin(phi1) * Math.cos(lon1);
    var y1 = R * Math.sin(phi1) * Math.sin(lon1);
    var z1 = R * Math.cos(phi1);

    var x2 = R * Math.sin(phi2) * Math.cos(lon2);
    var y2 = R * Math.sin(phi2) * Math.sin(lon2);
    var z2 = R * Math.cos(phi2);

    var dx = x2 - x1;
    var dy = y2 - y1;
    var dz = z2 - z1;

    var distance = Math.sqrt(dx * dx + dy * dy + dz * dz);

    return distance;
}

// resource

(:glance)
function rez(rezId) {
    return Application.loadResource(rezId);
}

// system

(:glance)
function hasGlance() {
    var ds = System.getDeviceSettings();
    return ds has :isGlanceModeEnabled && ds.isGlanceModeEnabled;
}

function vibrate(reason) {
    if (Attention has :vibrate) {
        var vibeData = [ new Attention.VibeProfile(25, 100) ];
        Attention.vibrate(vibeData);
        //Log.d("vibrate: " + reason);
    }
}
