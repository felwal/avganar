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
        if (_viewModel.decStopCursor()) {
            return true;
        }

        DialogView.push(
            rez(Rez.Strings.lbl_dialog_no_favorites_title),
            rez(Rez.Strings.lbl_dialog_no_favorites_msg),
            WatchUi.SLIDE_DOWN);

        return true;
    }

    //! "long UP"
    function onMenu() {
        new OptionsMenuDelegate(_viewModel).push(WatchUi.SLIDE_BLINK);
        return true;
    }

    //! "START-STOP"
    function onSelect() {
        if (_viewModel.hasStops() && !_viewModel.isShowingMessage()) {
            _pushStopDetail();
        }
        else {
            _viewModel.onSelectMessage();
        }

        return true;
    }

    //! "BACK"
    function onBack() {
        if (!hasGlance()) {
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
