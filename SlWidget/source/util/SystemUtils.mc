using Toybox.Application;
using Toybox.Attention;
using Toybox.System;

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
    if (Attention has :vibrate && SettingsStorage.getVibrateOnResponse()) {
        var vibeData = [ new Attention.VibeProfile(75, 300) ];
        Attention.vibrate(vibeData);
    }
}
