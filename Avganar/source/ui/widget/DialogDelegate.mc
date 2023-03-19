using Toybox.WatchUi;

class DialogDelegate extends WatchUi.BehaviorDelegate {

    hidden var _transition;

    // init

    function initialize(transition) {
        BehaviorDelegate.initialize();
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

    function onBack() {
        return _pop();
    }

    //

    private function _pop() {
        WatchUi.popView(_transition);
        return true;
    }

}
