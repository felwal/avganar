using Toybox.Attention;

function vibrate() {
    if (!App.doNotDisturb && App.vibrateOn && Attention has :vibrate && SettingsStorage.getVibrateOnResponse()) {
        var vibeData = [ new Attention.VibeProfile(75, 300) ];
        Attention.vibrate(vibeData);
    }
}
