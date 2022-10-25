using Toybox.Attention;
using Toybox.System;

function hasGlance() {
    var ds = System.getDeviceSettings();
    return ds has :isGlanceModeEnabled && ds.isGlanceModeEnabled;
}

function hasPreview() {
    return !hasGlance() || DEBUG;
}

function vibrate() {
    if (Attention has :vibrate && SettingsStorage.getVibrateOnResponse()) {
        var vibeData = [ new Attention.VibeProfile(75, 300) ];
        Attention.vibrate(vibeData);
    }
}
