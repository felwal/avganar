using Toybox.WatchUi;

class StopDetailDelegate extends WatchUi.BehaviorDelegate {

    hidden var _viewModel;

    // init

    function initialize(viewModel) {
        BehaviorDelegate.initialize();
        _viewModel = viewModel;
    }

    // override BehaviorDelegate

    //! "DOWN"
    function onNextPage() {
        _viewModel.incPageCursor();
        return true;
    }

    //! "UP"
    function onPreviousPage() {
        _viewModel.decPageCursor();
        return true;
    }

    function onSwipe(swipeEvent) {
        if (swipeEvent.getDirection() == WatchUi.SWIPE_LEFT) {
            _viewModel.onNextMode();
            return true;
        }

        return false;
    }

    //! "START-STOP"
    function onSelect() {
        _viewModel.onSelect();
        return true;
    }

}
