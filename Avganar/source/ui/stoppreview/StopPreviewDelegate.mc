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

using Toybox.Application;
using Toybox.WatchUi;

class StopPreviewDelegate extends WatchUi.BehaviorDelegate {

    // init

    function initialize() {
        BehaviorDelegate.initialize();
    }

    // override BehaviorDelegate

    //! "START-STOP"
    function onSelect() {
        _pushStopList();
        return true;
    }

    //

    hidden function _pushStopList() {
        var viewAndDelegate = Application.getApp().getMainView();

        WatchUi.pushView(viewAndDelegate[0], viewAndDelegate[1], WatchUi.SLIDE_BLINK);
    }

}
