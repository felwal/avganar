using Toybox.Application;
using Carbon.Footprint;

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
        var footprint = new Carbon.Footprint();
        var favStorage = new FavoriteStopsStorage();
        var stopFactory = new StopFactory(favStorage);
        var nearbyStorage = new NearbyStopsStorage(stopFactory);
        var stopsService = new SlNearbyStopsService(nearbyStorage, stopFactory);
        var repo = new Repository(footprint, nearbyStorage, favStorage, stopFactory, stopsService);

        var viewModel = new StopListViewModel(repo);
        var view = new StopListView(viewModel);
        var delegate = new StopListDelegate(repo, viewModel);

        return [ view, delegate ];
    }

}
