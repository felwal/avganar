using Toybox.Application;
using Carbon.Footprint;

(:glance)
class App extends Application.AppBase {

    // model
    private var _footprint;
    private var _storage;

    // init

    function initialize() {
        AppBase.initialize();
    }

    // override AppBase

    //! onStart() is called on application start up
    function onStart(state) {
        _footprint = new Carbon.Footprint();
        _storage = new StorageModel();
    }

    //! onStop() is called when your application is exiting
    function onStop(state) {
    }

    //! Return the initial view of your application here
    function getInitialView() {
        var repo = new Repository(_footprint, _storage);
        var viewModel = new StopListViewModel(repo);
        var view = new StopListView(viewModel);
        var delegate = new StopListDelegate(repo, viewModel);

        return [ view, delegate ];
    }

    //! Return the initial glance view of your application here
    (:glance)
    function getGlanceView() {
        var viewModel = new StopGlanceViewModel(_storage);
        var view = new StopGlanceView(viewModel);

        return [ view ];
    }

}
