using Toybox.Application;
using Toybox.WatchUi;

class StopPreviewDelegate extends WatchUi.BehaviorDelegate {

    // init

    function initialize() {
        BehaviorDelegate.initialize();
    }

    // override BehaviorDelegate

    //! "START-STOP"
    function onSelect() {
        _pushStopList();
        return true;
    }

    //

    private function _pushStopList() {
        var viewAndDelegate = Application.getApp().getMainView();

        WatchUi.pushView(viewAndDelegate[0], viewAndDelegate[1], WatchUi.SLIDE_IMMEDIATE);
    }

}
