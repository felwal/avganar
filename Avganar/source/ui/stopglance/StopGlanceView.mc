using Toybox.Graphics;
using Toybox.WatchUi;

(:glance :glanceExclusive)
class StopGlanceView extends WatchUi.GlanceView {

    // init

    function initialize() {
        GlanceView.initialize();
    }

    // override GlanceView

    function onUpdate(dc) {
        GlanceView.onUpdate(dc);

        // draw
        Graphite.enableAntiAlias(dc);
        _draw(dc);
    }

    // draw

    hidden function _draw(dc) {
        var nearestStopName = NearbyStopsStorage.getNearestStopName();
        var title = rez(Rez.Strings.app_name);
        var caption = nearestStopName == null ? rez(Rez.Strings.lbl_glance_caption_no_stops) : nearestStopName;
        var cy = dc.getHeight() / 2;

        // title
        var font = Graphics.FONT_GLANCE;
        var fh = dc.getFontHeight(font);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(0, cy - fh - px(1), font, title.toUpper(), Graphics.TEXT_JUSTIFY_LEFT);

        // caption
        dc.drawText(0, cy + px(2), Graphics.FONT_TINY, caption, Graphics.TEXT_JUSTIFY_LEFT);
    }

}
