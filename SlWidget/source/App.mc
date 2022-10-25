using Toybox.Application;
using Toybox.System;

(:glance)
const DEBUG = false;

class App extends Application.AppBase {

    static var hasGlance;

    // init

    function initialize() {
        AppBase.initialize();

        var ds = System.getDeviceSettings();
        hasGlance = ds has :isGlanceModeEnabled && ds.isGlanceModeEnabled;
    }

    // override AppBase

    function getInitialView() {
        if (!hasGlance || DEBUG) {
            return _getPreviewView();
        }
        else {
            return getMainView();
        }
    }

    (:glance)
    function getGlanceView() {
        return [ new StopGlanceView() ];
    }

    //

    private function _getPreviewView() {
        return [ new StopPreviewView(), new StopPreviewDelegate() ];
    }

    function getMainView() {
        FavoriteStopsStorage.load();
        NearbyStopsStorage.load();

        var viewModel = new StopListViewModel();
        var view = new StopListView(viewModel);
        var delegate = new StopListDelegate(viewModel);

        return [ view, delegate ];
    }

}
