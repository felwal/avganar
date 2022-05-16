using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Time;
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
        _draw(new DcCompat(dc));
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
        _viewModel.disableRequests();
    }

    // draw

    private function _draw(dcc) {
        var stop = _viewModel.stop;

        // text
        _drawHeader(dcc, stop.name);
        _drawFooter(dcc, stop.distance);

        // error
        if (stop.hasResponseError()) {
            var error = stop.getResponseError();

            // info
            dcc.drawDialog(error.title, error.message);

            // banner
            if (!error.hasConnection()) {
                dcc.drawExclamationBanner();
            }

            // start indicator
            if (error.isRerequestable()) {
                dcc.drawStartIndicatorWithBitmap(Rez.Drawables.ic_refresh);
            }
        }

        // departures
        else {
            _drawDepartures(dcc);

            // page indicator
            dcc.drawHorizontalPageIndicator(stop.getModeCount(), _viewModel.modeCursor);
            dcc.dc.setColor(Color.ON_PRIMARY, Color.PRIMARY);
            dcc.drawVerticalPageNumber(_viewModel.getPageCount(), _viewModel.pageCursor);
            dcc.drawVerticalPageArrows(_viewModel.getPageCount(), _viewModel.pageCursor, Color.CONTROL_NORMAL, Color.ON_PRIMARY);
            dcc.drawVerticalScrollbarSmall(_viewModel.getPageCount(), _viewModel.pageCursor);
        }
    }

    private function _drawHeader(dcc, text) {
        dcc.setColor(Color.TEXT_SECONDARY);
        dcc.dc.drawText(dcc.cx, 23, Graphene.FONT_XTINY, text.toUpper(), Graphics.TEXT_JUSTIFY_CENTER);
    }

    private function _drawFooter(dcc, distance) {
        // background
        dcc.setColor(Color.PRIMARY);
        dcc.dc.fillRectangle(0, dcc.h - 42, dcc.w, 42);

        // calc pos to align with page number
        var arrowEdgeOffset = 4;
        var arrowHeight = 8;
        var arrowNumberOffset = 8;
        var x = dcc.cx - 24;
        var yBottom = dcc.h - arrowEdgeOffset - arrowHeight - arrowNumberOffset;

        _drawDistance(dcc, distance, dcc.cx - 24, yBottom);
        _drawClockTime(dcc, dcc.cx + 24, yBottom);
    }

    private function _drawDistance(dcc, distance, x, yBottom) {
        if (distance == null) {
            return;
        }

        var font = Graphene.FONT_XTINY;
        var y = yBottom - dcc.dc.getFontHeight(font);

        // TODO: round to km with 1 decimal
        var text = distance + "m";

        dcc.dc.setColor(Color.ON_PRIMARY, Color.PRIMARY);
        dcc.dc.drawText(x, y, font, text, Graphics.TEXT_JUSTIFY_RIGHT);
    }

    private function _drawClockTime(dcc, x, yBottom) {
        var font = Graphene.FONT_XTINY;
        var y = yBottom - dcc.dc.getFontHeight(font);

        var info = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var text = info.hour.format("%02d") + ":" + info.min.format("%02d");

        dcc.dc.setColor(Color.ON_PRIMARY, Color.PRIMARY);
        dcc.dc.drawText(x, y, font, text, Graphics.TEXT_JUSTIFY_LEFT);
    }

    private function _drawDepartures(dcc) {
        var font = Graphene.FONT_TINY;
        var fontHeight = dcc.dc.getFontHeight(font);
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

            var xCircle = Chem.minX(yOffset + fontHeight / 2, dcc.r) + xOffset + rCircle;
            var xText = xCircle + rCircle + xOffset;

            // draw circle
            dcc.setColor(departure.getColor());
            dcc.dc.fillCircle(xCircle, yCircle, rCircle);

            // draw text
            dcc.setColor(departure.hasDeviations ? Color.DEVIATION : Color.TEXT_PRIMARY);
            dcc.dc.drawText(xText, yText, font, departure.toString(), Graphics.TEXT_JUSTIFY_LEFT);
        }
    }

}
