using Toybox.Application;

(:glance)
const DEBUG = false;

class App extends Application.AppBase {

    // init

    function initialize() {
        AppBase.initialize();
    }

    // override AppBase

    //! onStart() is called on application start up
    function onStart(state) {
    }

    //! onStop() is called when your application is exiting
    function onStop(state) {
    }

    //! Return the initial view of your application here
    function getInitialView() {
        if (hasPreview()) {
            return _getPreviewView();
        }
        else {
            return getMainView();
        }
    }

    //! Return the initial glance view of your application here
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
