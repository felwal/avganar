using Toybox.WatchUi;
using Toybox.Graphics;
using Carbon.Graphene;
using Carbon.Graphite;

class StopPreviewView extends WatchUi.View {

    // init

    function initialize() {
        View.initialize();
    }

    // override View

    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        // draw
        dc.setAntiAlias(true);
        _draw(dc);
    }

    // draw

    private function _draw(dc) {
        var stopNames = NearbyStopsStorage.getNearestStopsNames(3);

        // icon
        WidgetUtil.drawBitmap(dc, Graphite.getCenterX(dc), 60, Rez.Drawables.ic_launcher);

        // 3 nearest stops
        if (stopNames.size() == 0) {
            WidgetUtil.drawDialog(dc, rez(Rez.Strings.lbl_preview_title_no_stops), "");
        }
        else {
            _drawStops(dc, stopNames);
        }
    }

    private function _drawStops(dc, stopNames) {
        var font = Graphene.FONT_TINY;
        var fontHeight = dc.getFontHeight(font);
        var lineHeight = 1.6;
        var lineHeightPx = fontHeight * lineHeight;

        for (var i = 0; i < stopNames.size(); i++) {
            var yText = Graphite.getCenterY(dc) + i * lineHeightPx;

            Graphite.setColor(dc, AppColors.TEXT_PRIMARY);
            dc.drawText(Graphite.getCenterX(dc), yText, font, stopNames[i], Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

}
