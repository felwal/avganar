using Toybox.Graphics;
using Toybox.WatchUi;

class StopPreviewView extends WatchUi.View {

    // init

    function initialize() {
        View.initialize();
    }

    // override View

    function onUpdate(dc) {
        View.onUpdate(dc);

        // draw
        Graphite.enableAntiAlias(dc);
        _draw(dc);
    }

    // draw

    hidden function _draw(dc) {
        var stopName = NearbyStopsStorage.getNearestStopName();

        if (stopName == null) {
            WidgetUtil.drawDialog(dc, rez(Rez.Strings.lbl_preview_msg_no_stops));
        }
        else {
            _drawStop(dc, stopName);
        }

        // icon
        WidgetUtil.drawPreviewTitle(dc, rez(Rez.Strings.app_name), Rez.Drawables.ic_launcher, false);
    }

    hidden function _drawStop(dc, stopName) {
        var fonts = [ Graphics.FONT_LARGE, Graphics.FONT_MEDIUM ];
        var fh = dc.getFontHeight(fonts[0]);
        var height = 2 * fh;

        var minXAtTextBottom = MathUtil.minX(Graphite.getCenterY(dc) - fh / 2 + height, Graphite.getRadius(dc));
        var margin = minXAtTextBottom + px(2);
        var width = dc.getWidth() - 2 * margin;

        Graphite.drawTextArea(dc, Graphite.getCenterX(dc), Graphite.getCenterY(dc) - fh / 2, width, height,
            fonts, stopName, Graphics.TEXT_JUSTIFY_CENTER, AppColors.TEXT_PRIMARY);

        Graphite.resetColor(dc);
    }

}
