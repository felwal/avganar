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
        enableAntiAlias(dc);
        _draw(dc);
    }

    // draw

    hidden function _draw(dc) {
        var nearestStopName = NearbyStopsStorage.getNearestStopName();
        var title = rez(Rez.Strings.app_name);
        var caption = nearestStopName == null ? rez(Rez.Strings.lbl_glance_caption_no_stops) : nearestStopName;

        // title
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(0, px(8), Graphics.FONT_XTINY, title.toUpper(), Graphics.TEXT_JUSTIFY_LEFT);

        // caption
        var font = Graphics.FONT_TINY;
        var fontHeight = dc.getFontHeight(font);
        dc.drawText(0, dc.getHeight() - fontHeight - px(4), font, caption, Graphics.TEXT_JUSTIFY_LEFT);
    }

}
