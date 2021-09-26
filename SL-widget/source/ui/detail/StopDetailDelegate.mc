using Toybox.WatchUi;

class StopDetailDelegate extends WatchUi.BehaviorDelegate {

    private var _model;

    //

    function initialize(container) {
        BehaviorDelegate.initialize();
        _model = container.stopDetailViewModel;
    }

    // override BehaviorDelegate

    function onNextPage() {
        _model.incStopCursor();
        return true;
    }

    function onPreviousPage() {
        _model.decStopCursor();
        return true;
    }

}
