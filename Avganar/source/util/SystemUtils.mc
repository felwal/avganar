using Toybox.Attention;
using Toybox.System;

function hasGlance() {
    var ds = System.getDeviceSettings();
    return ds has :isGlanceModeEnabled && ds.isGlanceModeEnabled;
}

function shouldNotDisturb() {
    var ds = System.getDeviceSettings();
    return ds has :doNotDisturb && ds.doNotDisturb;
}

function isVibrateOn() {
    var ds = System.getDeviceSettings();
    return Attention has :vibrate && ds has :vibrateOn && ds.vibrateOn;
}
