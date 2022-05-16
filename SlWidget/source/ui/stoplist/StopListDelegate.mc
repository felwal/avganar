using Toybox.WatchUi;

class StopListDelegate extends WatchUi.BehaviorDelegate {

    private var _repo;
    private var _viewModel;

    // init

    function initialize(repo, viewModel) {
        BehaviorDelegate.initialize();
        _repo = repo;
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
        _pushSettings();
        return true;
    }

    //! "START-STOP"
    function onSelect() {
        if (_viewModel.hasStops()) {
            _pushStopDetail();
        }
        return true;
    }

    //! "BACK"
    function onBack() {
       if (hasGlance()) {
           return false;
       }
       else {
           WatchUi.popView(WatchUi.SLIDE_BLINK);
           return true;
       }
    }

    //

    private function _pushSettings() {
        var menu = new WatchUi.Menu();
        var delegate = new SettingsMenuDelegate();

        menu.setTitle(rez(Rez.Strings.lbl_settings_title));
        menu.addItem(rez(Rez.Strings.lbl_settings_api), SettingsMenuDelegate.ITEM_API);
        menu.addItem(rez(Rez.Strings.lbl_settings_about), SettingsMenuDelegate.ITEM_ABOUT);

        WatchUi.pushView(menu, delegate, WatchUi.SLIDE_BLINK);
    }

    private function _pushStopDetail() {
        var viewModel = new StopDetailViewModel(_repo, _viewModel.getSelectedStop());
        var view = new StopDetailView(viewModel);
        var delegate = new StopDetailDelegate(viewModel);

        WatchUi.pushView(view, delegate, WatchUi.SLIDE_LEFT);
    }

}
