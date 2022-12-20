using Toybox.Application;
using Toybox.System;

(:glance)
const DEBUG = true;

(:glance)
class App extends Application.AppBase {

    static var hasGlance = false;
    static var doNotDisturb = false;
    static var vibrateOn = true;

    // init

    function initialize() {
        AppBase.initialize();

        var ds = System.getDeviceSettings();
        if (ds != null) {
            hasGlance = ds has :isGlanceModeEnabled && ds.isGlanceModeEnabled;
            doNotDisturb = ds has :doNotDisturb && ds.doNotDisturb;
            vibrateOn = ds has :vibrateOn && ds.vibrateOn;
        }
    }

    // override AppBase

    function getInitialView() {
        if (!hasGlance || DEBUG) {
            return [ new StopPreviewView(), new StopPreviewDelegate() ];
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

    function getMainView() {
        FavoriteStopsStorage.load();
        NearbyStopsStorage.load();

        var viewModel = new StopListViewModel();
        var view = new StopListView(viewModel);
        var delegate = new StopListDelegate(viewModel);

        return [ view, delegate ];
    }

}
