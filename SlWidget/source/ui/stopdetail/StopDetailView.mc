using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Lang;
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

    function onShow() {
        _viewModel.enableRequests();
    }

    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        // draw
        dc.setAntiAlias(true);
        _draw(dc);
    }

    function onHide() {
        _viewModel.disableRequests();
    }

    // draw

    private function _draw(dc) {
        var stop = _viewModel.stop;
        var response = _viewModel.getPageResponse();

        // text
        _drawHeader(dc, stop.name);
        _drawFooter(dc, stop.distance);

        // departures
        if (response instanceof Lang.Array) {
            _drawDepartures(dc, response);

            // page indicator
            WidgetUtil.drawHorizontalPageIndicator(dc, stop.getModeCount(), _viewModel.modeCursor);
            dc.setColor(AppColors.ON_PRIMARY, AppColors.PRIMARY);
            WidgetUtil.drawVerticalPageNumber(dc, _viewModel.pageCount, _viewModel.pageCursor);
            WidgetUtil.drawVerticalPageArrows(dc, _viewModel.pageCount, _viewModel.pageCursor, AppColors.CONTROL_NORMAL, AppColors.ON_PRIMARY_TERTIARY);
            WidgetUtil.drawVerticalScrollbarSmall(dc, _viewModel.pageCount, _viewModel.pageCursor);
        }

        // error/message
        else {
            // info
            WidgetUtil.drawDialog(dc, response == null
                ? rez(Rez.Strings.lbl_i_departures_requesting)
                : (response instanceof ResponseError ? response.getTitle() : response),
                "");

            if (response instanceof ResponseError) {
                // banner
                if (!response.hasConnection()) {
                    WidgetUtil.drawExclamationBanner(dc);
                }

                // start indicator
                if (response.isRerequestable()) {
                    WidgetUtil.drawStartIndicatorWithBitmap(dc, Rez.Drawables.ic_refresh);
                }
            }
        }
    }

    private function _drawHeader(dc, text) {
        Graphite.setColor(dc, AppColors.TEXT_SECONDARY);
        dc.drawText(Graphite.getCenterX(dc), 23, Graphene.FONT_XTINY, text.toUpper(), Graphics.TEXT_JUSTIFY_CENTER);
    }

    private function _drawFooter(dc, distance) {
        // background
        WidgetUtil.drawFooter(dc, 42, AppColors.PRIMARY, null, null, null);

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
            Graphite.setColor(dc, departure.hasDeviations ? AppColors.DEPARTURE_DEVIATION : AppColors.TEXT_PRIMARY);
            dc.drawText(xText, yText, font, departure.toString(), Graphics.TEXT_JUSTIFY_LEFT);
        }
    }

}
