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

using Toybox.WatchUi;

class StopListView extends WatchUi.View {

    hidden var _viewModel as StopListViewModel;

    // init

    function initialize(viewModel as StopListViewModel) {
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
    }

    // draw

    hidden function _draw(dc as Dc) as Void {
        _drawStops(dc);
        _drawLoadingStatus(dc);

        // error/message
        if (_viewModel.isShowingMessage()) {
            // info
            WidgetUtil.drawDialog(dc, _viewModel.getMessage());

            // retry
            if (_viewModel.isUserRefreshable()) {
                WidgetUtil.drawActionFooter(dc, getString(Rez.Strings.lbl_list_retry));
            }
        }
    }

    hidden function _drawStops(dc as Dc) as Void {
        var stopNames = _viewModel.getStopNames();
        var favCount = _viewModel.getFavoriteCount();
        var cursor = _viewModel.stopCursor;

        var favHints = [ favCount == 1
            ? getString(Rez.Strings.lbl_list_favorites_one) : getString(Rez.Strings.lbl_list_favorites),
            getString(Rez.Strings.lbl_list_favorites_none) ];
        var nearbyHints = [ getString(Rez.Strings.lbl_list_nearby), getString(Rez.Strings.lbl_list_nearby) ];

        var favColors = [ AppColors.PRIMARY, AppColors.ON_PRIMARY,
            AppColors.ON_PRIMARY_SECONDARY, AppColors.ON_PRIMARY_TERTIARY ];
        var nearbyColors = [ AppColors.BACKGROUND, AppColors.TEXT_PRIMARY,
            AppColors.TEXT_SECONDARY, AppColors.TEXT_TERTIARY ];

        MenuUtil.drawPanedList(dc, stopNames, favCount, cursor, favHints, nearbyHints,
            getString(Rez.Strings.app_name), favColors, nearbyColors);
    }

    hidden function _drawLoadingStatus(dc as Dc) as Void {
        var w = dc.getWidth();
        var progress;

        if (NearbyStopsService.isRequesting) {
            progress = MathUtil.recursiveShare(0.5f, 0.33f, NearbyStopsStorage.failedRequestCount);
        }
        else if (!SettingsStorage.getUseLocation()) {
            return;
        }
        else if (!Footprint.isPositionRegistered) {
            progress = 0.33f;
        }
        else {
            return;
        }

        var cursor = _viewModel.getNearbyCursor();
        var y;

        if (cursor == 0) {
            y = MenuUtil.HEIGHT_FOOTER_LARGE;
        }
        else if (cursor == 1) {
            y = MenuUtil.HEIGHT_FOOTER_SMALL;
        }
        else if (cursor == -1) {
            y = dc.getHeight() - MenuUtil.HEIGHT_FOOTER_LARGE;
        }
        else if (cursor == -2) {
            y = dc.getHeight() - MenuUtil.HEIGHT_FOOTER_SMALL;
        }
        else {
            return;
        }

        var hasFavs = _viewModel.getFavoriteCount() > 0;
        var h = px(hasFavs ? 3 : 2); // looks bigger between black/black
        var activeColor = hasFavs ? AppColors.PRIMARY_LT : AppColors.TEXT_SECONDARY;
        var inactiveColor = hasFavs ? AppColors.ON_PRIMARY_TERTIARY : null;

        WidgetUtil.drawProgressBar(dc, y, h, progress, activeColor, inactiveColor);
    }

}
