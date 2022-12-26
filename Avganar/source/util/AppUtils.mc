using Toybox.Attention;
using Toybox.Math;
using Carbon.Chem;
using Carbon.Graphite;

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

//

function degToY(dc, deg) {
    return (-Math.sin(Chem.rad(deg)) / 2 + 0.5) * dc.getHeight();
}

function pxX(dc, pxOn240x240) {
    return Graphite.getWidthByRatio(dc, pxOn240x240 / 240f);
}

function pxY(dc, pxOn240x240) {
    return Graphite.getHeightByRatio(dc, pxOn240x240 / 240f);
}

function px(dc, pxOn240x240) {
    return Graphite.getSizeByRatio(dc, pxOn240x240 / 240f);
}

(:glance)
function pxGlanceX(dc, pxOn240x240) {
    return Graphite.getHeightByRatio(dc, pxOn240x240 / 151f);
}

(:glance)
function pxGlanceY(dc, pxOn240x240) {
    return Graphite.getHeightByRatio(dc, pxOn240x240 / 63f);
}
