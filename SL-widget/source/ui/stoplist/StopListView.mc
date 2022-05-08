using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Carbon.Graphene;
using Carbon.Chem;

class StopListView extends WatchUi.View {

    var _viewModel;

    // init

    function initialize(viewModel) {
        View.initialize();
        _viewModel = viewModel;
    }

    // override View

    //! Load resources
    function onLayout(dc) {
        setLayout(Rez.Layouts.stoplist_layout(dc));
    }

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    function onShow() {
        _viewModel.enableRequests();
    }

    //! Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        // draw
        dc.setAntiAlias(true);
        _draw(new Dk(dc));
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
        _viewModel.disableRequests();
    }

    // draw

    private function _draw(dk) {
        var stops = _viewModel.getStops();

        // text
        _drawStops(dk, stops);
        //_drawGpsStatus(dk);

        // page indicator
        dk.drawVerticalPageArrows(_viewModel.getStopCount(), _viewModel.stopCursor);

        if (stops.size() == 1) {
            // banner
            if (!stops[0].hasConnection()) {
                dk.drawExclamationBanner();
            }

            // start indicator
            if (stops[0].areStopsRerequestable()) {
                dk.drawStartIndicatorWithBitmap(Rez.Drawables.ic_refresh);
            }
        }
    }

    private function _drawStops(dk, stops) {
        var font = Graphene.FONT_TINY;
        var fontHeight = dk.dc.getFontHeight(font);
        var lineHeight = 1.6;
        var lineHeightPx = fontHeight * lineHeight;

        var cursor = _viewModel.stopCursor;

        // only draw 2 stops above and 2 below cursor
        var stopOffset = 2;
        var firstStopIndex = max(0, cursor - stopOffset);
        var lastStopIndex = min(stops.size(), cursor + stopOffset + 1);

        for (var i = firstStopIndex; i < lastStopIndex; i++) {
            var stop = stops[i];

            var yText = dk.cy + (i - cursor) * lineHeightPx;

            /*
            // don't draw outside screen
            if (yCircle > h) {
                break;
            }
            */

            if (i == cursor) {
                dk.resetColor();
                dk.dc.drawText(dk.cx, yText, Graphene.FONT_LARGE, stop.name, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
            }
            else {
                dk.setColor(Graphene.COLOR_LT_GRAY);
                dk.dc.drawText(dk.cx, yText, font, stop.name, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
            }
        }
    }

    private function _drawGpsStatus(dk) {
        var font = Graphene.FONT_XTINY;
        var fh = dk.dc.getFontHeight(font);
        var arrowEdgeOffset = 4;
        var arrowHeight = 8;
        var arrowNumberOffset = 8;
        var x = dk.cx - 24;
        var y = dk.h - arrowEdgeOffset - arrowHeight - fh - arrowNumberOffset;

        var hasGps = _viewModel.isPositionRegistered();

        var text = hasGps ? "GPS" : "---";
        var color = hasGps ? Graphene.COLOR_GREEN : Color.CONTROL_NORMAL;

        dk.setColor(color);
        dk.dc.drawText(x, y, font, text, Graphics.TEXT_JUSTIFY_RIGHT);
    }

}
