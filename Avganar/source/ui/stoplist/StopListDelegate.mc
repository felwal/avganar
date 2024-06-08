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

import Toybox.Lang;

using Toybox.WatchUi;

class StopListDelegate extends WatchUi.BehaviorDelegate {

    hidden var _viewModel as StopListViewModel;

    // init

    function initialize(viewModel as StopListViewModel) {
        BehaviorDelegate.initialize();
        _viewModel = viewModel;
    }

    // override BehaviorDelegate

    //! "DOWN"
    function onNextPage() as Boolean {
        _viewModel.onScrollDown();
        return true;
    }

    //! "UP"
    function onPreviousPage() as Boolean {
        if (_viewModel.onScrollUp()) {
            return true;
        }

        // favorites empty page / instructions
        DialogView.push(getString(Rez.Strings.lbl_dialog_no_favorites_title),
            [ getString(Rez.Strings.lbl_dialog_no_favorites_msg) ],
            null, WatchUi.SLIDE_DOWN);

        return true;
    }

    //! "long UP"
    function onMenu() as Boolean {
        new OptionsMenuDelegate(_viewModel).push(WatchUi.SLIDE_BLINK);
        return true;
    }

    //! "START-STOP"
    function onSelect() as Boolean {
        if (_viewModel.hasStops() && !_viewModel.isShowingMessage()) {
            _pushStopDetail();
        }
        else {
            _viewModel.onSelectMessage();
        }

        return true;
    }

    //! "BACK"
    function onBack() as Boolean {
        if (!SystemUtil.hasGlance()) {
            WatchUi.popView(WatchUi.SLIDE_BLINK);
            return true;
        }

        return false;
    }

    //

    hidden function _pushStopDetail() as Void {
        var viewModel = new StopDetailViewModel(_viewModel.getSelectedStop());
        var view = new StopDetailView(viewModel);
        var delegate = new StopDetailDelegate(viewModel);

        WatchUi.pushView(view, delegate, WatchUi.SLIDE_LEFT);
    }

}
