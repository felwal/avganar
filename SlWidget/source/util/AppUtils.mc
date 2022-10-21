using Toybox.Attention;

function hasPreview() {
    return !hasGlance() || DEBUG;
}

function vibrate(reason) {
    if (Attention has :vibrate && SettingsStorage.getVibrateOnResponse()) {
        var vibeData = [ new Attention.VibeProfile(75, 300) ];
        Attention.vibrate(vibeData);
    }
}
