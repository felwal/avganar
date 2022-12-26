using Toybox.System;

function hasGlance() {
    var ds = System.getDeviceSettings();
    return ds has :isGlanceModeEnabled && ds.isGlanceModeEnabled;
}

function doNotDisturb() {
    var ds = System.getDeviceSettings();
    return ds has :doNotDisturb && ds.doNotDisturb;
}

function isVibrateOn() {
    var ds = System.getDeviceSettings();
    return ds has :vibrateOn && ds.vibrateOn;
}
