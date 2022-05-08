using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Carbon.Graphene;
using Carbon.Chem;

class StopDetailView extends WatchUi.View {

    private var _viewModel;

    // init

    function initialize(viewModel) {
        View.initialize();
        _viewModel = viewModel;
    }

    // override View

    //! Load resources
    function onLayout(dc) {
        setLayout(Rez.Layouts.stopdetail_layout(dc));
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
        var stop = _viewModel.stop;

        // text
        _drawHeader(dk, stop.name);
        _drawDepartures(dk);
        _drawBottomBar(dk);
        _drawClockTime(dk);

        // page indicator
        dk.drawHorizontalPageIndicator(stop.getModeCount(), _viewModel.modeCursor);
        dk.dc.setColor(Graphene.COLOR_WHITE, Color.BOTTOM_BAR);
        dk.drawVerticalPageNumber(_viewModel.getPageCount(), _viewModel.pageCursor);
        dk.drawVerticalPageArrows(_viewModel.getPageCount(), _viewModel.pageCursor);
        //dk.drawVerticalScrollbarSmall(_viewModel.getPageCount(), _viewModel.pageCursor);

        // banner
        if (!stop.hasConnection()) {
            dk.drawExclamationBanner();
        }

        // start indicator
        if (stop.areDeparturesRerequestable()) {
            dk.drawStartIndicatorWithBitmap(Rez.Drawables.ic_refresh);
        }
    }

    private function _drawHeader(dk, text) {
        dk.setColor(Graphene.COLOR_LT_GRAY);
        dk.dc.drawText(dk.cx, 23, Graphene.FONT_XTINY, text.toUpper(), Graphics.TEXT_JUSTIFY_CENTER);
    }

    private function _drawDepartures(dk) {
        var font = Graphene.FONT_TINY;
        var fontHeight = dk.dc.getFontHeight(font);
        var lineHeight = 1.35;
        var lineHeightPx = fontHeight * lineHeight;
        var xOffset = 10;
        var yOffset = 50;
        var rCircle = 4;

        var departures = _viewModel.getPageDepartures();

        for (var d = 0; d < StopDetailViewModel.DEPARTURES_PER_PAGE && d < departures.size(); d++) {
            var departure = departures[d];

            var yText = yOffset + d * lineHeightPx;
            var yCircle = yText + fontHeight / 2;

            /*
            // don't draw outside screen
            if (yCircle > h - yOffset) {
                break;
            }
            */

            var xCircle = Chem.minX(yOffset + fontHeight / 2, dk.r) + xOffset + rCircle;
            var xText = xCircle + rCircle + xOffset;

            dk.setColor(departure.getColor());
            dk.dc.fillCircle(xCircle, yCircle, rCircle);
            dk.resetColor();
            dk.dc.drawText(xText, yText, font, departure.toString(), Graphics.TEXT_JUSTIFY_LEFT);
        }
    }

    private function _drawBottomBar(dk) {
        dk.setColor(Color.BOTTOM_BAR);
        dk.dc.fillRectangle(0, dk.h - 42, dk.w, 42);

        //dk.setColor(Graphene.COLOR_DK_GRAY);
        //dk.dc.drawCircle(dk.cx, dk.cy, dk.r + 2);
    }

    private function _drawClockTime(dk) {
        var font = Graphene.FONT_XTINY;
        var fh = dk.dc.getFontHeight(font);
        var arrowEdgeOffset = 4;
        var arrowHeight = 8;
        var arrowNumberOffset = 8;
        var x = dk.cx + 24;
        var y = dk.h - arrowEdgeOffset - arrowHeight - fh - arrowNumberOffset;

        var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var text = info.hour.format("%02d") + ":" + info.min.format("%02d");

        //dk.setColor(Color.CONTROL_NORMAL);
        dk.dc.setColor(Graphene.COLOR_WHITE, Color.BOTTOM_BAR);
        dk.dc.drawText(x, y, font, text, Graphics.TEXT_JUSTIFY_LEFT);
    }

}
