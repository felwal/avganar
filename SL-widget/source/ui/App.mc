import Toybox.Lang;

using Toybox.Application;
using Toybox.WatchUi;

class App extends Application.AppBase {

    private var _container as Container;

    function initialize() as Void {
        AppBase.initialize();
    }

    // override AppBase

    //! onStart() is called on application start up
    function onStart(state as Dictionary) as Void {
        _container = new Container();
    }

    //! onStop() is called when your application is exiting
    function onStop(state as Dictionary) as Void {
    }

    //! Return the initial view of your application here
    function getInitialView() as Array<WatchUi.View or WatchUi.InputDelegate> {
        return [ new StopDetailView(_container), new StopDetailDelegate(_container) ];
    }

    //! Return the initial glance view of your application here
    (:glance)
    function getGlanceView() as Array<WatchUi.GlanceView or WatchUi.InputDelegate> {
        return [ new StopGlanceView(_container) ];
    }

}
