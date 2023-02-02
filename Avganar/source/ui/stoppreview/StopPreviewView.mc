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

        // 3 nearest stops
        if (stopNames.size() == 0) {
            WidgetUtil.drawDialog(dc, rez(Rez.Strings.lbl_preview_msg_no_stops));
        }
        else {
            _drawStops(dc, stopNames);
        }

        // icon
        WidgetUtil.drawPreviewTitle(dc, Rez.Drawables.ic_launcher, rez(Rez.Strings.app_name));
    }

    hidden function _drawStops(dc, stopNames) {
        var font = Graphics.FONT_TINY;
        var h = dc.getHeight() - 2 * pxY(dc, 36);
        var lineHeightPx = h / 4;

        Graphite.setColor(dc, AppColors.TEXT_SECONDARY);

        for (var i = 0; i < stopNames.size(); i++) {
            var yText = Graphite.getCenterY(dc) + i * lineHeightPx;

            dc.drawText(Graphite.getCenterX(dc), yText, font, stopNames[i], Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        }

        Graphite.resetColor(dc);
    }

}
