using Toybox.Application;
using Toybox.System;

(:glance)
const DEBUG = false;

(:glance)
class App extends Application.AppBase {

    // init

    function initialize() {
        AppBase.initialize();
    }

    // override AppBase

    function getInitialView() {
        if (!hasGlance() || DEBUG) {
            return [ new StopPreviewView(), new StopPreviewDelegate() ];
        }
        else {
            return getMainView();
        }
    }

    (:glance :glanceExclusive)
    function getGlanceView() {
        return [ new StopGlanceView() ];
    }

    //

    function getMainView() {
        FavoriteStopsStorage.load();
        NearbyStopsStorage.load();

        var viewModel = new StopListViewModel();
        var view = new StopListView(viewModel);
        var delegate = new StopListDelegate(viewModel);

        return [ view, delegate ];
    }

}
