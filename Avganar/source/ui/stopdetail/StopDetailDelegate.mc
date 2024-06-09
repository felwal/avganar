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

class StopDetailDelegate extends WatchUi.BehaviorDelegate {

    hidden var _viewModel as StopDetailViewModel;

    // init

    function initialize(viewModel as StopDetailViewModel) {
        BehaviorDelegate.initialize();
        _viewModel = viewModel;
    }

    // input

    //! "DOWN"
    function onNextPage() as Boolean {
        _viewModel.onScrollDown();
        return true;
    }

    //! "UP"
    function onPreviousPage() as Boolean {
        _viewModel.onScrollUp();
        return true;
    }

    //! "long UP"
    function onMenu() as Boolean  {
        _viewModel.toggleDepartureState();
        return true;
    }

    //! "START-STOP"
    function onSelect() as Boolean  {
        _viewModel.onSelect();
        return true;
    }

    function onBack() as Boolean  {
        if (_viewModel.isDepartureState) {
            // exit departure selection
            _viewModel.isDepartureState = false;
            WatchUi.requestUpdate();
            return true;
        }
        else if (_viewModel.isModeMenuState && !_viewModel.isInitialRequest) {
            // exit mode menu
            _viewModel.isModeMenuState = false;
            WatchUi.requestUpdate();
            return true;
        }

        return false;
    }

}
