using Toybox.Graphics;
using Toybox.WatchUi;
using Carbon.Graphene;

(:glance)
class StopGlanceView extends WatchUi.GlanceView {

    // init

    function initialize() {
        GlanceView.initialize();
    }

    // override GlanceView

    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        GlanceView.onUpdate(dc);

        // draw
        dc.setAntiAlias(true);
        _draw(dc);
    }

    // draw

    private function _draw(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

        var nearestStopName = NearbyStopsStorage.getNearestStopName();
        var title = nearestStopName == null ? rez(Rez.Strings.app_name) : rez(Rez.Strings.lbl_glance_title);
        var caption = nearestStopName == null ? rez(Rez.Strings.lbl_glance_caption_no_stops) : nearestStopName;

        // title
        dc.drawText(0, 8, Graphene.FONT_XTINY, title.toUpper(), Graphics.TEXT_JUSTIFY_LEFT);

        // caption
        var font = Graphics.FONT_TINY;
        var fontHeight = dc.getFontHeight(font);
        dc.drawText(0, dc.getHeight() - fontHeight - 4, font, caption, Graphics.TEXT_JUSTIFY_LEFT);
    }

}
