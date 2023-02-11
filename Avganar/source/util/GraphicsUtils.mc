using Toybox.Math;
using Carbon.Chem;
using Carbon.Graphite;

(:glance)
function enableAntiAlias(dc) {
    if (dc has :setAntiAlias) {
        dc.setAntiAlias(true);
    }
}

function degToY(dc, deg) {
    return (-Math.sin(Chem.rad(deg)) / 2 + 0.5) * dc.getHeight();
}

(:glance)
function px(dp) {
    return Math.round(dp * rez(Rez.JsonData.pxPerDp));
}
