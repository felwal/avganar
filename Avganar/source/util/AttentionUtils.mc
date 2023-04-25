using Toybox.Attention;

function vibrate() {
    if (!shouldNotDisturb() && isVibrateOn() && SettingsStorage.getVibrateOnResponse()) {
        var vibeData = [ new Attention.VibeProfile(75, 300) ];
        Attention.vibrate(vibeData);
    }
}
