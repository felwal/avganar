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
        var viewModel = new StopGlanceViewModel();
        var view = new StopGlanceView(viewModel);

        return [ view ];
    }

    //

    private function _getPreviewView() {
        var viewModel = new StopPreviewViewModel();
        var view = new StopPreviewView(viewModel);
        var delegate = new StopPreviewDelegate(viewModel);

        return [ view, delegate ];
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
