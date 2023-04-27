using Toybox.Application;

(:glance)
class App extends Application.AppBase {

    // init

    function initialize() {
        AppBase.initialize();
    }

    // override AppBase

    function getInitialView() {
        if (!hasGlance()) {
            return [ new StopPreviewView(), new StopPreviewDelegate() ];
        }

        return getMainView();
    }

    (:glance :glanceExclusive)
    function getGlanceView() {
        return [ new StopGlanceView() ];
    }

    //

    function getMainView() {
        FavoriteStopsStorage.load();
        NearbyStopsStorage.load();

        // this function is gitignored.
        // define it to keep favorites between
        // development and testing release builds.
        //addDevFavStops();

        var viewModel = new StopListViewModel();
        var view = new StopListView(viewModel);
        var delegate = new StopListDelegate(viewModel);

        return [ view, delegate ];
    }

}
