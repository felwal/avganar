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

using Toybox.Application;

(:glance)
class App extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // lifecycle

    function getInitialView() as [Views] or [Views, InputDelegates] {
        if (!SystemUtil.hasGlance()) {
            return [ new StopPreviewView(), new StopPreviewDelegate() ];
        }

        return getMainView();
    }

    (:glance :glanceExclusive)
    function getGlanceView() as [GlanceView] or [GlanceView, GlanceViewDelegate] or Null {
        return [ new StopGlanceView() ];
    }

    //

    function getMainView() as [StopListView, StopListDelegate] {
        FavoriteStopsStorage.load();
        NearbyStopsStorage.load();

        var viewModel = new StopListViewModel();
        var view = new StopListView(viewModel);
        var delegate = new StopListDelegate(viewModel);

        return [ view, delegate ];
    }

}
