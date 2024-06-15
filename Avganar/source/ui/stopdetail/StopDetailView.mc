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

    private var _viewModel as StopDetailViewModel;

    // init

    function initialize(viewModel as StopDetailViewModel) {
        View.initialize();
        _viewModel = viewModel;
    }

    // lifecycle

    function onShow() as Void {
        _viewModel.enableRequests();
    }

    function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);
        Graphite.enableAntiAlias(dc);

        _draw(dc);
    }

    function onHide() as Void {
        _viewModel.disableRequests();
        _viewModel.stop.resetModesWithResponseErrors();
    }

    // draw

    private function _draw(dc as Dc) as Void {
        var stop = _viewModel.stop;
        var response = _viewModel.getPageResponse();

        var showActionFooter = response instanceof ResponseError && response.isUserRefreshable();
        var showModeMenu = _viewModel.isInitialRequest || _viewModel.isModeMenuState;

        _drawHeader(dc, stop.name);

        // footer
        if (showActionFooter) {
            WidgetUtil.drawActionFooter(dc, getString(Rez.Strings.lbl_list_retry));
        }
        else {
            _drawFooter(dc, !showModeMenu);
        }

        // mode menu
        if (showModeMenu) {
            MenuUtil.drawSideMenu(dc, stop.getModesStrings(), _viewModel.pageCursor, true);
            return;
        }

        // response
        if (response instanceof Lang.Array) {
            _drawResponseOk(dc, response);
        }
        else if (response instanceof ResponseError) {
            _drawResponseError(dc, response);
        }
        else {
            WidgetUtil.drawDialog(dc, getString(Rez.Strings.msg_i_departures_requesting));
        }

        // indicator
        if (stop.getModesKeys().size() > 1 || _viewModel.isDepartureState) {
            WidgetUtil.drawStartIndicator(dc);
        }
    }

    private function _drawResponseOk(dc as Dc, departures as Array<Departure>) as Void {
        if (departures.size() == 0) {
            WidgetUtil.drawDialog(dc, getString(Rez.Strings.msg_i_departures_none));
        }
        else {
            _drawDepartures(dc, departures);

            // scrollbar
            dc.setColor(AppColors.ON_PRIMARY, AppColors.PRIMARY);
            WidgetUtil.drawVerticalPageArrows(dc, _viewModel.pageCount, _viewModel.pageCursor,
                AppColors.TEXT_TERTIARY, AppColors.ON_PRIMARY_TERTIARY);
            WidgetUtil.drawVerticalScrollbarSmall(dc, _viewModel.pageCount, _viewModel.pageCursor);
        }

        // stop deviation
        if (_viewModel.canNavigateToDeviation()) {
            Graphite.setColor(dc, AppColors.WARNING);
            WidgetUtil.drawTopPageArrow(dc);
            Graphite.resetColor(dc);
        }
    }

    private function _drawDepartures(dc as Dc, departures as Array<Departure>) as Void {
        var font = Graphics.FONT_TINY;
        var xOffset = px(10);
        var yOffset = px(68);
        var rCircle = px(4);

        var h = dc.getHeight() - yOffset * 2;
        var lineHeightPx = h / (StopDetailViewModel.DEPARTURES_PER_PAGE - 1);

        for (var i = 0; i < StopDetailViewModel.DEPARTURES_PER_PAGE && i < departures.size(); i++) {
            var departure = departures[i];

            var y = yOffset + i * lineHeightPx;
            var xCircle = MathUtil.minX(yOffset, Graphite.getRadius(dc)) + xOffset + rCircle;
            var xText = xCircle + rCircle + xOffset;

            // draw circle
            Graphite.setColor(dc, departure.getModeColor());
            dc.fillCircle(xCircle, y, rCircle);

            // highlight selected departure
            var isSelected = _viewModel.isDepartureState && _viewModel.departureCursor == i;

            // draw text
            var justification = Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER;
            var textColor = isSelected ? AppColors.DEPARTURE_SELECTED : departure.getDeviationColor();
            Graphite.setColor(dc, textColor);
            dc.drawText(xText, y, font, departure.toString(), justification);

            // mark realtime
            if (departure.isRealTime) {
                Graphite.setColor(dc, AppColors.DEPARTURE_REALTIME);
                dc.drawText(xText, y, font, departure.displayTime(), justification);
            }

            // strikethrough
            if (departure.cancelled) {
                Graphite.strokeRectangle(dc, xText, y, dc.getWidth() - xText, px(1), px(2), textColor, AppColors.BACKGROUND);
            }
        }
    }

    private function _drawResponseError(dc as Dc, error as ResponseError) as Void {
        WidgetUtil.drawDialog(dc, error.getTitle());

        if (!error.hasConnection()) {
            WidgetUtil.drawErrorBanner(dc);
        }
    }

    private function _drawHeader(dc as Dc, title as String) as Void {
        // 19 is font height for XTINY on fr745.
        // set y to half and justify to vcenter for the title to
        // look alright even on devices with different font size for XTINY.
        var y = px(23) + px(19) / 2;

        Graphite.setColor(dc, AppColors.TEXT_SECONDARY);
        dc.drawText(Graphite.getCenterX(dc), y, Graphics.FONT_XTINY, title.toUpper(),
            Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function _drawFooter(dc as Dc, drawDetails as Boolean) as Void {
        var hFooter = MenuUtil.HEIGHT_FOOTER_SMALL;
        var h = dc.getHeight();

        // background
        WidgetUtil.drawFooter(dc, hFooter, AppColors.PRIMARY, null, null, null);

        if (!drawDetails) {
            return;
        }

        var modeKey = _viewModel.getCurrentModeKey();

        _drawFooterClockTime(dc, hFooter);
        _drawFooterProgressBar(dc, hFooter, modeKey);
        _drawFooterModeSymbol(dc, hFooter, modeKey);
    }

    private function _drawFooterClockTime(dc as Dc, hFooter as Numeric) as Void {
        var h = dc.getHeight();

        // calc pos to align with page number
        var arrowEdgeOffset = WidgetUtil.ARROW_EDGE_OFFSET;
        var arrowHeight = WidgetUtil.ARROW_SIZE;
        var arrowTextOffset = px(8);

        var font = Graphics.FONT_TINY;
        var yTextTop = h - arrowEdgeOffset - arrowHeight - arrowTextOffset - dc.getFontHeight(font);

        // make sure the text is fully within the footer.
        yTextTop = MathUtil.max(yTextTop, h - hFooter);

        var info = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var text = info.hour.format("%02d") + ":" + info.min.format("%02d");

        dc.setColor(AppColors.ON_PRIMARY, AppColors.PRIMARY);
        dc.drawText(Graphite.getCenterX(dc), yTextTop, font, text, Graphics.TEXT_JUSTIFY_CENTER);
    }

    private function _drawFooterProgressBar(dc as Dc, hFooter as Numeric, modeKey as String) as Void {
        if (!DeparturesService.isRequesting) {
            return;
        }

        var hProgressBar = px(3);
        var yProgressBar = dc.getHeight() - hFooter - hProgressBar;
        var failedCount = _viewModel.stop.getMode(modeKey).getFailedRequestCount();
        var progress = MathUtil.recursiveShare(0.33f, 0f, failedCount);

        WidgetUtil.drawProgressBar(dc, yProgressBar, hProgressBar, progress,
            AppColors.PRIMARY_LT, AppColors.ON_PRIMARY_TERTIARY);
    }

    private function _drawFooterModeSymbol(dc as Dc, hFooter as Numeric, modeKey as String) as Void {
        var symbol = Mode.getSymbol(modeKey);

        if (symbol.equals("")) {
            return;
        }

        var cx = Graphite.getCenterX(dc) + px(48);
        var cy = dc.getHeight() - hFooter + px(7); //y - px(7);
        var font = Graphics.FONT_TINY;
        var fh = dc.getFontHeight(font);
        var rCircle = Math.ceil(fh / 2f) + px(2);

        Graphite.setColor(dc, AppColors.BACKGROUND_INVERTED);
        dc.fillCircle(cx, cy, rCircle);

        dc.setColor(AppColors.PRIMARY_DK, AppColors.BACKGROUND_INVERTED);
        dc.drawText(cx, cy, font, symbol,
            Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
    }

}
