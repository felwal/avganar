using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Time;
using Carbon.Graphene;
using Carbon.Graphite;
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
        _draw(dc);
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
        _viewModel.disableRequests();
    }

    // draw

    private function _draw(dc) {
        var stop = _viewModel.stop;

        // text
        _drawHeader(dc, stop.name);
        _drawFooter(dc, stop.distance);

        // error
        if (!stop.hasDepartures()) {
            var error = stop.getResponseError();

            // info
            WidgetUtil.drawDialog(dc, error.getTitle(), "");

            if (error instanceof ResponseError) {
                // banner
                if (!error.hasConnection()) {
                    WidgetUtil.drawExclamationBanner(dc);
                }

                // start indicator
                if (error.isRerequestable()) {
                    WidgetUtil.drawStartIndicatorWithBitmap(dc, Rez.Drawables.ic_refresh);
                }
            }
        }

        // departures
        else {
            var departures = _viewModel.getModeDepartures();
            var pageDepartures = _viewModel.getPageDepartures(departures);

            _drawDepartures(dc, pageDepartures);

            // page indicator
            WidgetUtil.drawHorizontalPageIndicator(dc, stop.getModeCount(), _viewModel.modeCursor);
            dc.setColor(AppColors.ON_PRIMARY, AppColors.PRIMARY);
            WidgetUtil.drawVerticalPageNumber(dc, _viewModel.pageCount, _viewModel.pageCursor);
            WidgetUtil.drawVerticalPageArrows(dc, _viewModel.pageCount, _viewModel.pageCursor, AppColors.CONTROL_NORMAL, AppColors.ON_PRIMARY_TERTIARY);
            WidgetUtil.drawVerticalScrollbarSmall(dc, _viewModel.pageCount, _viewModel.pageCursor);
        }
    }

    private function _drawHeader(dc, text) {
        Graphite.setColor(dc, AppColors.TEXT_SECONDARY);
        dc.drawText(Graphite.getCenterX(dc), 23, Graphene.FONT_XTINY, text.toUpper(), Graphics.TEXT_JUSTIFY_CENTER);
    }

    private function _drawFooter(dc, distance) {
        // background
        WidgetUtil.drawFooterSmall(dc, AppColors.PRIMARY, null);

        // calc pos to align with page number
        var arrowEdgeOffset = 4;
        var arrowHeight = 8;
        var arrowNumberOffset = 8;
        var x = Graphite.getCenterX(dc) - 24;
        var yBottom = dc.getHeight() - arrowEdgeOffset - arrowHeight - arrowNumberOffset;

        _drawDistance(dc, distance, Graphite.getCenterX(dc) - 24, yBottom);
        _drawClockTime(dc, Graphite.getCenterX(dc) + 24, yBottom);
    }

    private function _drawDistance(dc, distance, x, yBottom) {
        if (distance == null) {
            return;
        }

        var font = Graphene.FONT_XTINY;
        var y = yBottom - dc.getFontHeight(font);

        // TODO: round to km with 1 decimal
        var text = distance + "m";

        dc.setColor(AppColors.ON_PRIMARY, AppColors.PRIMARY);
        dc.drawText(x, y, font, text, Graphics.TEXT_JUSTIFY_RIGHT);
    }

    private function _drawClockTime(dc, x, yBottom) {
        var font = Graphene.FONT_XTINY;
        var y = yBottom - dc.getFontHeight(font);

        var info = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var text = info.hour.format("%02d") + ":" + info.min.format("%02d");

        dc.setColor(AppColors.ON_PRIMARY, AppColors.PRIMARY);
        dc.drawText(x, y, font, text, Graphics.TEXT_JUSTIFY_LEFT);
    }

    private function _drawDepartures(dc, pageDepartures) {
        var font = Graphene.FONT_TINY;
        var fontHeight = dc.getFontHeight(font);
        var lineHeight = 1.35;
        var lineHeightPx = fontHeight * lineHeight;
        var xOffset = 10;
        var yOffset = 50;
        var rCircle = 4;

        for (var d = 0; d < StopDetailViewModel.DEPARTURES_PER_PAGE && d < pageDepartures.size(); d++) {
            var departure = pageDepartures[d];

            var yText = yOffset + d * lineHeightPx;
            var yCircle = yText + fontHeight / 2;

            var xCircle = Chem.minX(yOffset + fontHeight / 2, Graphite.getRadius(dc)) + xOffset + rCircle;
            var xText = xCircle + rCircle + xOffset;

            // draw circle
            Graphite.setColor(dc, departure.getColor());
            dc.fillCircle(xCircle, yCircle, rCircle);

            // draw text
            Graphite.setColor(dc, departure.hasDeviations ? AppColors.DEVIATION : AppColors.TEXT_PRIMARY);
            dc.drawText(xText, yText, font, departure.toString(), Graphics.TEXT_JUSTIFY_LEFT);
        }
    }

}
