using Toybox.Attention;

(:glance)
function enableAntiAlias(dc) {
    if (dc has :setAntiAlias) {
        dc.setAntiAlias(true);
    }
}

function vibrate() {
    if (!App.doNotDisturb && App.vibrateOn && Attention has :vibrate && SettingsStorage.getVibrateOnResponse()) {
        var vibeData = [ new Attention.VibeProfile(75, 300) ];
        Attention.vibrate(vibeData);
    }
}
