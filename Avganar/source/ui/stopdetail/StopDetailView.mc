using Toybox.Graphics;
using Toybox.Lang;
using Toybox.Math;
using Toybox.Time;
using Toybox.WatchUi;

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
        Graphite.enableAntiAlias(dc);
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
        _drawHeader(dc, stop);
        _drawFooter(dc, stop);

        // departures
        if (response instanceof Lang.Array) {
            _drawDepartures(dc, response);

            // page indicator
            WidgetUtil.drawHorizontalPageIndicator(dc, stop.getModeCount(), _viewModel.modeCursor);
            dc.setColor(AppColors.ON_PRIMARY, AppColors.PRIMARY);
            WidgetUtil.drawVerticalPageArrows(dc, _viewModel.pageCount, _viewModel.pageCursor, AppColors.CONTROL_NORMAL, AppColors.ON_PRIMARY_TERTIARY);
            WidgetUtil.drawVerticalScrollbarSmall(dc, _viewModel.pageCount, _viewModel.pageCursor);

            // stop deviation
            if (_viewModel.canNavigateToDeviation()) {
                Graphite.setColor(dc, AppColors.WARNING);
                WidgetUtil.drawTopPageArrow(dc);
                Graphite.resetColor(dc);
            }
        }

        // error/message
        else {
            // info
            WidgetUtil.drawDialog(dc, response == null
                ? rez(Rez.Strings.msg_i_departures_requesting)
                : (response instanceof ResponseError ? response.getTitle() : response));

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

    hidden function _drawHeader(dc, stop) {
        // 19 is font height for XTINY on fr745.
        // set y to half and justify to vcenter for the title to
        // look alright even on devices with different font size for XTINY.
        var y = px(23) + px(19) / 2;

        Graphite.setColor(dc, AppColors.TEXT_SECONDARY);
        dc.drawText(Graphite.getCenterX(dc), y, Graphics.FONT_XTINY, stop.name.toUpper(),
            Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
    }

    hidden function _drawFooter(dc, stop) {
        var hFooter = px(42);
        var h = dc.getHeight();

        // background
        WidgetUtil.drawFooter(dc, hFooter, AppColors.PRIMARY, null, null, null);

        // clock time

        // calc pos to align with page number
        var arrowEdgeOffset = px(4);
        var arrowHeight = px(8);
        var arrowTextOffset = px(8);

        var font = Graphics.FONT_TINY;
        var y = h - arrowEdgeOffset - arrowHeight - arrowTextOffset - dc.getFontHeight(font);
        var cx = Graphite.getCenterX(dc);

        // make sure the text is fully within the footer.
        y = MathUtil.max(y, h - hFooter);

        var info = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var text = info.hour.format("%02d") + ":" + info.min.format("%02d");

        dc.setColor(AppColors.ON_PRIMARY, AppColors.PRIMARY);
        dc.drawText(cx, y, font, text, Graphics.TEXT_JUSTIFY_CENTER);

        // progress bar

        if (DeparturesService.isRequesting || stop.getResponse() == null) {
            var hProgressBar = px(3);
            var yProgressBar = h - hFooter - hProgressBar;
            var progress = _recursiveThird(0, stop.getFailedRequestCount());

            WidgetUtil.drawProgressBar(dc, yProgressBar, hProgressBar, progress,
                AppColors.PRIMARY_LT, AppColors.ON_PRIMARY_TERTIARY);
        }

        // mode symbol

        var modeSymbol = stop.getModeSymbol(_viewModel.modeCursor);

        if (modeSymbol.equals("")) {
            return;
        }

        var xMode = cx + px(48);
        var yMode = y - px(7);
        var fontMode = Graphics.FONT_TINY;
        var fh = dc.getFontHeight(fontMode);
        var r = Math.ceil(fh / 2f);

        Graphite.setColor(dc, Graphene.COLOR_WHITE);
        dc.fillCircle(xMode, yMode + r, r + 2);

        dc.setColor(AppColors.PRIMARY_DK, Graphene.COLOR_WHITE);
        dc.drawText(xMode, yMode, fontMode, modeSymbol, Graphics.TEXT_JUSTIFY_CENTER);
    }

    hidden function _recursiveThird(prevVal, level) {
        var newVal = prevVal + (1 - prevVal) * 0.33f;
        return level <= 0 ? newVal : _recursiveThird(newVal, level - 1);
    }

    hidden function _drawDepartures(dc, pageDepartures) {
        var font = Graphics.FONT_TINY;
        var xOffset = px(10);
        var yOffset = px(68);
        var rCircle = px(4);

        var h = dc.getHeight() - yOffset * 2;
        var lineHeightPx = h / (StopDetailViewModel.DEPARTURES_PER_PAGE - 1);

        for (var d = 0; d < StopDetailViewModel.DEPARTURES_PER_PAGE && d < pageDepartures.size(); d++) {
            var departure = pageDepartures[d];

            var y = yOffset + d * lineHeightPx;
            var xCircle = MathUtil.minX(yOffset, Graphite.getRadius(dc)) + xOffset + rCircle;
            var xText = xCircle + rCircle + xOffset;

            // draw circle
            Graphite.setColor(dc, departure.getModeColor());
            dc.fillCircle(xCircle, y, rCircle);

            // draw text
            var textColor = departure.getTextColor();
            Graphite.setColor(dc, textColor);
            dc.drawText(xText, y, font, departure.toString(), Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);

            // strikethrough
            if (departure.cancelled) {
                Graphite.strokeRectangle(dc, xText, y, dc.getWidth() - xText, px(1), px(2), textColor, Graphene.COLOR_BLACK);
            }
        }
    }

}
