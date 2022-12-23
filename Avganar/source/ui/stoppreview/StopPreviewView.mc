using Toybox.Graphics;
using Toybox.WatchUi;
using Carbon.Graphite;

class StopPreviewView extends WatchUi.View {

    // init

    function initialize() {
        View.initialize();
    }

    // override View

    function onUpdate(dc) {
        View.onUpdate(dc);

        // draw
        enableAntiAlias(dc);
        _draw(dc);
    }

    // draw

    hidden function _draw(dc) {
        var stopNames = NearbyStopsStorage.getNearestStopsNames(3);

        // icon
        RezUtil.drawBitmap(dc, Graphite.getCenterX(dc), pxY(dc, 60), Rez.Drawables.ic_launcher);

        // 3 nearest stops
        if (stopNames.size() == 0) {
            WidgetUtil.drawDialog(dc, rez(Rez.Strings.lbl_preview_title_no_stops), "");
        }
        else {
            _drawStops(dc, stopNames);
        }
    }

    hidden function _drawStops(dc, stopNames) {
        var font = Graphics.FONT_TINY;
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
