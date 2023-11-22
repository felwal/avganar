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

class DialogDelegate extends WatchUi.BehaviorDelegate {

    hidden var _viewModel;
    hidden var _transition;

    // init

    function initialize(viewModel, transition) {
        BehaviorDelegate.initialize();

        _viewModel = viewModel;
        _transition = transition;
    }

    // override BehaviorDelegate

    function onPreviousPage() {
        if (_transition == WatchUi.SLIDE_DOWN) {
            return _pop();
        }

        return false;
    }

    function onNextPage() {
        if (_transition == WatchUi.SLIDE_UP) {
            return _pop();
        }

        return false;
    }

    function onSwipe(swipeEvent) {
        if (swipeEvent.getDirection() == WatchUi.SWIPE_LEFT) {
            _viewModel.onNextMessage();
            return true;
        }

        return false;
    }

    function onSelect() {
        _viewModel.onNextMessage();
        return true;
    }

    function onBack() {
        return _pop();
    }

    //

    private function _pop() {
        WatchUi.popView(_transition);
        return true;
    }

}
