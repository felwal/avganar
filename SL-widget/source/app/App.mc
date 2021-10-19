using Toybox.Application;

class App extends Application.AppBase {

    // model
    private var _position;
    private var _storage;

    // init

    function initialize() {
        AppBase.initialize();
    }

    // override AppBase

    //! onStart() is called on application start up
    function onStart(state) {
        _position = new PositionModel();
        _storage = new StorageModel();
    }

    //! onStop() is called when your application is exiting
    function onStop(state) {
    }

    //! Return the initial view of your application here
    function getInitialView() {
        var repo = new StopDetailRepository(_position, _storage);
        var viewModel = new StopDetailViewModel(repo);
        var view = new StopDetailView(viewModel);
        var delegate = new StopDetailDelegate(viewModel);

        return [ view, delegate ];
    }

    //! Return the initial glance view of your application here
    /*(:glance)
    function getGlanceView() {
        var repo = new StopGlanceRepository(_position, _storage);
        var viewModel = new StopGlanceViewModel(repo);
        var view = new StopGlanceView(viewModel);

        return [ view ];
    }*/

}
