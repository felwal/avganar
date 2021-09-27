using Toybox.WatchUi;

class StopDetailDelegate extends WatchUi.BehaviorDelegate {

    private var _model;

    //

    function initialize(container) {
        BehaviorDelegate.initialize();
        _model = container.stopDetailViewModel;
    }

    // override BehaviorDelegate

    //! "DOWN"
    function onNextPage() {
        _model.incStopCursor();
        return true;
    }

    //! "UP"
    function onPreviousPage() {
        _model.decStopCursor();
        return true;
    }

    //! "START-STOP"
    function onSelect() {
        _model.incModeCursor();
        return true;
    }

}
