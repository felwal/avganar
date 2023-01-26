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
        var title = nearestStopName == null ? rez(Rez.Strings.app_name) : rez(Rez.Strings.lbl_glance_title);
        var caption = nearestStopName == null ? rez(Rez.Strings.lbl_glance_caption_no_stops) : nearestStopName;

        // title
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(0, pxGlanceY(dc, 8), Graphics.FONT_XTINY, title.toUpper(), Graphics.TEXT_JUSTIFY_LEFT);

        // caption

        var font = Graphics.FONT_TINY;
        var fontHeight = dc.getFontHeight(font);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(0, dc.getHeight() - fontHeight - pxGlanceY(dc, 4), font, caption, Graphics.TEXT_JUSTIFY_LEFT);
    }

}
