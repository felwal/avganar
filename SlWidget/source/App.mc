using Toybox.Application;

(:glance)
const DEBUG = false;

class App extends Application.AppBase {

    // init

    function initialize() {
        AppBase.initialize();
    }

    // override AppBase

    function getInitialView() {
        if (hasPreview()) {
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
