using Toybox.Application;
using Toybox.System;

(:glance)
function rez(rezId) {
    return Application.loadResource(rezId);
}

function hasGlance() {
    var ds = System.getDeviceSettings();
    return ds has :isGlanceModeEnabled && ds.isGlanceModeEnabled;
}
