using Toybox.WatchUi;

class StopListDelegate extends WatchUi.BehaviorDelegate {

    hidden var _viewModel;

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

    //! "long UP"
    function onMenu() {
        new SettingsMenuDelegate(_viewModel).push(WatchUi.SLIDE_BLINK);
        return true;
    }

    //! "START-STOP"
    function onSelect() {
        if (_viewModel.hasStops() && !_viewModel.isShowingMessage()) {
            _pushStopDetail();
        }
        return true;
    }

    //! "BACK"
    function onBack() {
        if (!hasGlance() || DEBUG) {
            WatchUi.popView(WatchUi.SLIDE_BLINK);
            return true;
        }

        return false;
    }

    //

    hidden function _pushStopDetail() {
        var viewModel = new StopDetailViewModel(_viewModel.getSelectedStop());
        var view = new StopDetailView(viewModel);
        var delegate = new StopDetailDelegate(viewModel);

        WatchUi.pushView(view, delegate, WatchUi.SLIDE_LEFT);
    }

}
