import Toybox.Lang;

using Toybox.WatchUi;

class StopDetailDelegate extends WatchUi.BehaviorDelegate {

    private var _model as StopDetailViewModel;

    //

    function initialize(container as Container) as Void {
        BehaviorDelegate.initialize();
        _model = container.stopDetailViewModel;
    }

    // override BehaviorDelegate

    //! "DOWN"
    function onNextPage() as Boolean {
        _model.incStopCursor();
        return true;
    }

    //! "UP"
    function onPreviousPage() as Boolean {
        _model.decStopCursor();
        return true;
    }

    //! "START-STOP"
    function onSelect() as Boolean {
        _model.incModeCursor();
        return true;
    }

}
