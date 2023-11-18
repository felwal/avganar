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
        _viewModel.incCursor();
        return true;
    }

    //! "UP"
    function onPreviousPage() {
        _viewModel.decCursor();
        return true;
    }

    function onSwipe(swipeEvent) {
        if (swipeEvent.getDirection() == WatchUi.SWIPE_LEFT) {
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
            _viewModel.isDepartureState = false;
            WatchUi.requestUpdate();
            return true;
        }

        return false;
    }

}
