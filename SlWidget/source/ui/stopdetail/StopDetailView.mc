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
        _draw(new DcWrapper(dc));
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
        _viewModel.disableRequests();
    }

    // draw

    private function _draw(dcw) {
        var stop = _viewModel.stop;

        // text
        _drawHeader(dcw, stop.name);
        _drawFooter(dcw, stop.distance);

        // error
        if (!stop.hasDepartures()) {
            var error = stop.getResponseError();

            // info
            dcw.drawDialog(error.getTitle(), "");

            if (error instanceof ResponseError) {
                // banner
                if (!error.hasConnection()) {
                    dcw.drawExclamationBanner();
                }

                // start indicator
                if (error.isRerequestable()) {
                    dcw.drawStartIndicatorWithBitmap(Rez.Drawables.ic_refresh);
                }
            }
        }

        // departures
        else {
            var departures = _viewModel.getModeDepartures();
            var pageDepartures = _viewModel.getPageDepartures(departures);

            _drawDepartures(dcw, pageDepartures);

            // page indicator
            dcw.drawHorizontalPageIndicator(stop.getModeCount(), _viewModel.modeCursor);
            dcw.dc.setColor(Color.ON_PRIMARY, Color.PRIMARY);
            dcw.drawVerticalPageNumber(_viewModel.pageCount, _viewModel.pageCursor);
            dcw.drawVerticalPageArrows(_viewModel.pageCount, _viewModel.pageCursor, Color.CONTROL_NORMAL, Color.ON_PRIMARY_TERTIARY);
            dcw.drawVerticalScrollbarSmall(_viewModel.pageCount, _viewModel.pageCursor);
        }
    }

    private function _drawHeader(dcw, text) {
        dcw.setColor(Color.TEXT_SECONDARY);
        dcw.dc.drawText(dcw.cx, 23, Graphene.FONT_XTINY, text.toUpper(), Graphics.TEXT_JUSTIFY_CENTER);
    }

    private function _drawFooter(dcw, distance) {
        // background
        dcw.drawFooter(Color.PRIMARY, null);

        // calc pos to align with page number
        var arrowEdgeOffset = 4;
        var arrowHeight = 8;
        var arrowNumberOffset = 8;
        var x = dcw.cx - 24;
        var yBottom = dcw.h - arrowEdgeOffset - arrowHeight - arrowNumberOffset;

        _drawDistance(dcw, distance, dcw.cx - 24, yBottom);
        _drawClockTime(dcw, dcw.cx + 24, yBottom);
    }

    private function _drawDistance(dcw, distance, x, yBottom) {
        if (distance == null) {
            return;
        }

        var font = Graphene.FONT_XTINY;
        var y = yBottom - dcw.dc.getFontHeight(font);

        // TODO: round to km with 1 decimal
        var text = distance + "m";

        dcw.dc.setColor(Color.ON_PRIMARY, Color.PRIMARY);
        dcw.dc.drawText(x, y, font, text, Graphics.TEXT_JUSTIFY_RIGHT);
    }

    private function _drawClockTime(dcw, x, yBottom) {
        var font = Graphene.FONT_XTINY;
        var y = yBottom - dcw.dc.getFontHeight(font);

        var info = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var text = info.hour.format("%02d") + ":" + info.min.format("%02d");

        dcw.dc.setColor(Color.ON_PRIMARY, Color.PRIMARY);
        dcw.dc.drawText(x, y, font, text, Graphics.TEXT_JUSTIFY_LEFT);
    }

    private function _drawDepartures(dcw, pageDepartures) {
        var font = Graphene.FONT_TINY;
        var fontHeight = dcw.dc.getFontHeight(font);
        var lineHeight = 1.35;
        var lineHeightPx = fontHeight * lineHeight;
        var xOffset = 10;
        var yOffset = 50;
        var rCircle = 4;

        for (var d = 0; d < StopDetailViewModel.DEPARTURES_PER_PAGE && d < pageDepartures.size(); d++) {
            var departure = pageDepartures[d];

            var yText = yOffset + d * lineHeightPx;
            var yCircle = yText + fontHeight / 2;

            var xCircle = Chem.minX(yOffset + fontHeight / 2, dcw.r) + xOffset + rCircle;
            var xText = xCircle + rCircle + xOffset;

            // draw circle
            dcw.setColor(departure.getColor());
            dcw.dc.fillCircle(xCircle, yCircle, rCircle);

            // draw text
            dcw.setColor(departure.hasDeviations ? Color.DEVIATION : Color.TEXT_PRIMARY);
            dcw.dc.drawText(xText, yText, font, departure.toString(), Graphics.TEXT_JUSTIFY_LEFT);
        }
    }

}
