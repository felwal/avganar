using Toybox.WatchUi;

class DialogDelegate extends WatchUi.BehaviorDelegate {

    hidden var _viewModel;
    hidden var _transition;

    // init

    function initialize(viewModel, transition) {
        BehaviorDelegate.initialize();

        _viewModel = viewModel;
        _transition = transition;
    }

    // override BehaviorDelegate

    function onPreviousPage() {
        if (_transition == WatchUi.SLIDE_DOWN) {
            return _pop();
        }

        return false;
    }

    function onNextPage() {
        if (_transition == WatchUi.SLIDE_UP) {
            return _pop();
        }

        return false;
    }

    function onSwipe(swipeEvent) {
        if (swipeEvent.getDirection() == WatchUi.SWIPE_LEFT) {
            _viewModel.onNextMessage();
            return true;
        }

        return false;
    }

    function onSelect() {
        _viewModel.onNextMessage();
        return true;
    }

    function onBack() {
        return _pop();
    }

    //

    private function _pop() {
        WatchUi.popView(_transition);
        return true;
    }

}
