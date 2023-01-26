using Toybox.Graphics;
using Toybox.Lang;
using Toybox.Time;
using Toybox.WatchUi;
using Carbon.Chem;
using Carbon.Graphite;

class StopDetailView extends WatchUi.View {

    hidden var _viewModel;

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
        View.onUpdate(dc);

        // draw
        enableAntiAlias(dc);
        _draw(dc);
    }

    function onHide() {
        _viewModel.disableRequests();
        _viewModel.stop.resetResponseError();
    }

    // draw

    hidden function _draw(dc) {
        var stop = _viewModel.stop;
        var response = _viewModel.getPageResponse();

        // text
        _drawHeader(dc, stop.name);
        _drawFooter(dc);

        // departures
        if (response instanceof Lang.Array) {
            _drawDepartures(dc, response);

            // page indicator
            WidgetUtil.drawHorizontalPageIndicator(dc, stop.getModeCount(), _viewModel.modeCursor);
            dc.setColor(AppColors.ON_PRIMARY, AppColors.PRIMARY);
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

    hidden function _drawHeader(dc, text) {
        // 19 is font height for XTINY on fr745.
        // set y to half and justify to vcenter for the title to
        // look alright even on devices with different font size for XTINY.
        var y = pxY(dc, 23) + pxY(dc, 19) / 2;

        Graphite.setColor(dc, AppColors.TEXT_SECONDARY);
        dc.drawText(Graphite.getCenterX(dc), y, Graphics.FONT_XTINY, text.toUpper(),
            Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
    }

    hidden function _drawFooter(dc) {
        // background
        WidgetUtil.drawFooter(dc, pxY(dc, 42), AppColors.PRIMARY, null, null, null);

        // draw clock time

        // calc pos to align with page number
        var arrowEdgeOffset = pxY(dc, 4);
        var arrowHeight = pxY(dc, 8);
        var arrowNumberOffset = pxY(dc, 8);

        var font = Graphics.FONT_XTINY;
        var y = dc.getHeight() - arrowEdgeOffset - arrowHeight - arrowNumberOffset - dc.getFontHeight(font);

        // make sure the text is fully within the footer.
        // important for devices where XTINY is not really tiny.
        y = Chem.max(y, dc.getHeight() - pxY(dc, 42));

        var info = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var text = info.hour.format("%02d") + ":" + info.min.format("%02d");

        dc.setColor(AppColors.ON_PRIMARY, AppColors.PRIMARY);
        dc.drawText(Graphite.getCenterX(dc), y, font, text, Graphics.TEXT_JUSTIFY_CENTER);
    }

    hidden function _drawDepartures(dc, pageDepartures) {
        var font = Graphics.FONT_TINY;
        var xOffset = pxX(dc, 10);
        var yOffset = pxY(dc, 68);
        var rCircle = px(dc, 4);

        var h = dc.getHeight() - yOffset * 2;
        var lineHeightPx = h / (StopDetailViewModel.DEPARTURES_PER_PAGE - 1);

        for (var d = 0; d < StopDetailViewModel.DEPARTURES_PER_PAGE && d < pageDepartures.size(); d++) {
            var departure = pageDepartures[d];

            var y = yOffset + d * lineHeightPx;
            var xCircle = Chem.minX(yOffset, Graphite.getRadius(dc)) + xOffset + rCircle;
            var xText = xCircle + rCircle + xOffset;

            // draw circle
            Graphite.setColor(dc, departure.getModeColor());
            dc.fillCircle(xCircle, y, rCircle);

            // draw text
            Graphite.setColor(dc, departure.getDeviationColor());
            dc.drawText(xText, y, font, departure.toString(), Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

}
