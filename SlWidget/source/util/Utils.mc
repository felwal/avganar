using Toybox.Application;
using Toybox.Attention;
using Toybox.System;
using Toybox.Math;

// app

function buildStops(ids, names) {
    var stops = [];

    for (var i = 0; i < ids.size() && i < names.size(); i++) {
        var stop = new Stop(ids[i], names[i], null);
        stops.add(stop);
    }

    return stops;
}

// resource

(:glance)
function rez(rezId) {
    return Application.loadResource(rezId);
}

// system

function hasGlance() {
    var ds = System.getDeviceSettings();
    return ds has :isGlanceModeEnabled && ds.isGlanceModeEnabled;
}

function hasPreview() {
    return !hasGlance() || DEBUG;
}

function vibrate(reason) {
    if (Attention has :vibrate) {
        var vibeData = [ new Attention.VibeProfile(25, 100) ];
        Attention.vibrate(vibeData);
        //Log.d("vibrate: " + reason);
    }
}
