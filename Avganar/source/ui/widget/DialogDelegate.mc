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
import Toybox.WatchUi;

class DialogDelegate extends WatchUi.BehaviorDelegate {

    private var _viewModel as DialogViewModel;
    private var _transition as SlideType;

    // init

    function initialize(viewModel as DialogViewModel, transition as SlideType) {
        BehaviorDelegate.initialize();

        _viewModel = viewModel;
        _transition = transition;
    }

    // input

    function onPreviousPage() as Boolean {
        if (_transition == WatchUi.SLIDE_DOWN) {
            return _pop();
        }

        return false;
    }

    function onNextPage() as Boolean {
        if (_transition == WatchUi.SLIDE_UP) {
            return _pop();
        }

        return false;
    }

    function onSwipe(swipeEvent as SwipeEvent) as Boolean {
        if (swipeEvent.getDirection() == WatchUi.SWIPE_LEFT) {
            _viewModel.onNextMessage();
            return true;
        }

        return false;
    }

    function onSelect() as Boolean {
        _viewModel.onNextMessage();
        return true;
    }

    function onBack() as Boolean {
        return _pop();
    }

    //

    private function _pop() as Boolean {
        WatchUi.popView(_transition);
        return true;
    }

}
