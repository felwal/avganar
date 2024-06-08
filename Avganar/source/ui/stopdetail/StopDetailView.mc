// This file is part of Avgånär.
//
// Avgånär is free software: you can redistribute it and/or modify it under the terms of
// the GNU General Public License as published by the Free Software Foundation,
// either version 3 of the License, or (at your option) any later version.
//
// Avgånär is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
// without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with Avgånär.
// If not, see <https://www.gnu.org/licenses/>.

import Toybox.Graphics;
import Toybox.Lang;

using Toybox.Math;
using Toybox.Time;
using Toybox.WatchUi;

class StopDetailView extends WatchUi.View {

    hidden var _viewModel as StopDetailViewModel;

    // init

    function initialize(viewModel as StopDetailViewModel) {
        View.initialize();
        _viewModel = viewModel;
    }

    // override View

    function onShow() as Void {
        _viewModel.enableRequests();
    }

    function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);

        // draw
        Graphite.enableAntiAlias(dc);
        _draw(dc);
    }

    function onHide() as Void {
        _viewModel.disableRequests();
        _viewModel.stop.resetModesWithResponseErrors();
    }

    // draw

    hidden function _draw(dc as Dc) as Void {
        var stop = _viewModel.stop;

        var response = _viewModel.getPageResponse();
        var showActionFooter = response instanceof ResponseError && response.isUserRefreshable();

        _drawHeader(dc, stop);

        if (showActionFooter) {
            WidgetUtil.drawActionFooter(dc, rez(Rez.Strings.lbl_list_retry));
        }
        else {
            _drawFooter(dc, stop, _viewModel.isInitialRequest || _viewModel.isModePaneState);
        }

        if (_viewModel.isInitialRequest || _viewModel.isModePaneState) {
            _drawModeList(dc, stop);
            return;
        }

        // departures
        if (response instanceof Lang.Array) {
            _drawDepartures(dc, response);

            // indicator: page
            dc.setColor(AppColors.ON_PRIMARY, AppColors.PRIMARY);
            WidgetUtil.drawVerticalPageArrows(dc, _viewModel.pageCount, _viewModel.pageCursor,
                AppColors.TEXT_TERTIARY, AppColors.ON_PRIMARY_TERTIARY);
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

            if (response instanceof ResponseError && !response.hasConnection()) {
                WidgetUtil.drawExclamationBanner(dc);
            }
        }

        _drawModeIndicator(dc);
    }

    hidden function _drawModeIndicator(dc as Dc) as Void {
        if (!_viewModel.isModePaneState
            && (_viewModel.stop.getModesKeys().size() > 1 || _viewModel.isDepartureState)) {

            WidgetUtil.drawStartIndicator(dc);
        }
    }

    hidden function _drawModeList(dc as Dc, stop as StopType) as Void {
        var items = stop.getModesStrings();
        WidgetUtil.drawSideList(dc, items, _viewModel.pageCursor, true);
    }

    hidden function _drawHeader(dc as Dc, stop as StopType) as Void {
        // 19 is font height for XTINY on fr745.
        // set y to half and justify to vcenter for the title to
        // look alright even on devices with different font size for XTINY.
        var y = px(23) + px(19) / 2;

        Graphite.setColor(dc, AppColors.TEXT_SECONDARY);
        dc.drawText(Graphite.getCenterX(dc), y, Graphics.FONT_XTINY, stop.name.toUpper(),
            Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
    }

    hidden function _drawFooter(dc as Dc, stop as StopType, noDetails as Boolean) as Void {
        var hFooter = px(42);
        var h = dc.getHeight();

        // background
        WidgetUtil.drawFooter(dc, hFooter, AppColors.PRIMARY, null, null, null);

        if (noDetails) {
            return;
        }

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

        var modeKey = _viewModel.getCurrentModeKey();

        if (DeparturesService.isRequesting) {
            var hProgressBar = px(3);
            var yProgressBar = h - hFooter - hProgressBar;
            var failedCount = stop.getMode(modeKey).getFailedRequestCount();
            var progress = MathUtil.recursiveShare(0.33f, 0f, failedCount);

            WidgetUtil.drawProgressBar(dc, yProgressBar, hProgressBar, progress,
                AppColors.PRIMARY_LT, AppColors.ON_PRIMARY_TERTIARY);
        }

        // mode letter

        var modeLetter = Departure.getModeLetter(modeKey);

        if (modeLetter.equals("")) {
            return;
        }

        var xMode = cx + px(48);
        var yMode = y - px(7);
        var fontMode = Graphics.FONT_TINY;
        var fh = dc.getFontHeight(fontMode);
        var r = Math.ceil(fh / 2f);

        Graphite.setColor(dc, AppColors.BACKGROUND_INVERTED);
        dc.fillCircle(xMode, yMode + r, r + 2);

        dc.setColor(AppColors.PRIMARY_DK, AppColors.BACKGROUND_INVERTED);
        dc.drawText(xMode, yMode, fontMode, modeLetter, Graphics.TEXT_JUSTIFY_CENTER);
    }

    hidden function _drawDepartures(dc as Dc, pageDepartures as Array<Departure>) as Void {
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

            // highlight selected departure
            var isSelected = _viewModel.isDepartureState && _viewModel.departureCursor == d;

            // draw text
            var textColor = isSelected ? AppColors.DEPARTURE_SELECTED : departure.getTextColor();
            Graphite.setColor(dc, textColor);
            dc.drawText(xText, y, font, departure.toString(), Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);

            // mark realtime
            if (departure.isRealTime) {
                Graphite.setColor(dc, AppColors.DEPARTURE_REALTIME);
                dc.drawText(xText, y, font, departure.displayTime(), Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
            }

            // strikethrough
            if (departure.cancelled) {
                Graphite.strokeRectangle(dc, xText, y, dc.getWidth() - xText, px(1), px(2), textColor, AppColors.BACKGROUND);
            }
        }
    }

}
