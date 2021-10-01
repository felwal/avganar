using Toybox.Application;

class App extends Application.AppBase {

    private var _container;

    // init

    function initialize() {
        AppBase.initialize();
    }

    // override AppBase

    //! onStart() is called on application start up
    function onStart(state) {
        _container = new Container();
    }

    //! onStop() is called when your application is exiting
    function onStop(state) {
    }

    //! Return the initial view of your application here
    function getInitialView() {
        return [ new StopDetailView(_container), new StopDetailDelegate(_container) ];
    }

    //! Return the initial glance view of your application here
    (:glance)
    function getGlanceView() {
        return [ new StopGlanceView(_container) ];
    }

}
