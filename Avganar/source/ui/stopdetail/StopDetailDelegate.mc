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

using Toybox.WatchUi;

class StopDetailDelegate extends WatchUi.BehaviorDelegate {

    hidden var _viewModel;

    // init

    function initialize(viewModel) {
        BehaviorDelegate.initialize();
        _viewModel = viewModel;
    }

    // override BehaviorDelegate

    //! "DOWN"
    function onNextPage() {
        _viewModel.onScrollDown();
        return true;
    }

    //! "UP"
    function onPreviousPage() {
        _viewModel.onScrollUp();
        return true;
    }

    function onSwipe(swipeEvent) {
        // enable swiping left between modes.
        // swiping right is disabled to avoid interference with ´onBack´.
        if (swipeEvent.getDirection() == WatchUi.SWIPE_LEFT && !_viewModel.isDepartureState) {
            _viewModel.onNextMode();
            return true;
        }

        return false;
    }

    //! "long UP"
    function onMenu() {
        _viewModel.toggleDepartureState();
        return true;
    }

    //! "START-STOP"
    function onSelect() {
        _viewModel.onSelect();
        return true;
    }

    function onBack() {
        if (_viewModel.isDepartureState) {
            // exit departure selection
            _viewModel.isDepartureState = false;
            WatchUi.requestUpdate();
            return true;
        }
        else if (_viewModel.isModePaneState && !_viewModel.isInitialRequest) {
            // exit mode menu
            _viewModel.isModePaneState = false;
            WatchUi.requestUpdate();
            return true;
        }

        return false;
    }

}
