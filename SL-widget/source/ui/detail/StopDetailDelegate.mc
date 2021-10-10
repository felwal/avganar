using Toybox.WatchUi;

class StopDetailDelegate extends WatchUi.BehaviorDelegate {

    private var _viewModel;

    // init

    function initialize(container) {
        BehaviorDelegate.initialize();
        _viewModel = container.stopDetailViewModel;
    }

    // override BehaviorDelegate

    //! "DOWN"
    function onNextPage() {
        _viewModel.incStopCursor();
        return true;
    }

    //! "UP"
    function onPreviousPage() {
        _viewModel.decStopCursor();
        return true;
    }

    //! "START-STOP"
    function onSelect() {
        _viewModel.onSelect();
        return true;
    }

}
