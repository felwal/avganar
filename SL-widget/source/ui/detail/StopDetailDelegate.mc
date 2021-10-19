using Toybox.WatchUi;

class StopDetailDelegate extends WatchUi.BehaviorDelegate {

    private var _viewModel;

    // init

    function initialize(viewModel) {
        BehaviorDelegate.initialize();
        _viewModel = viewModel;
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
