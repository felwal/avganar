using Toybox.Attention;

(:glance)
function def(val, def) {
    return val != null ? val : def;
}

function vibrate() {
    if (!shouldNotDisturb() && isVibrateOn() && SettingsStorage.getVibrateOnResponse()) {
        var vibeData = [ new Attention.VibeProfile(75, 300) ];
        Attention.vibrate(vibeData);
    }
}
