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

    //! "long UP"
    function onMenu() {
        var menu = new WatchUi.Menu();

        menu.setTitle(rez(Rez.Strings.lbl_settings_title));
        menu.addItem(rez(Rez.Strings.lbl_settings_apis), SettingsMenuDelegate.ITEM_API);

        var delegate = new SettingsMenuDelegate();
        WatchUi.pushView(menu, delegate, WatchUi.SLIDE_BLINK);

        return true;
    }

    //! "START-STOP"
    function onSelect() {
        _viewModel.onSelect();
        return true;
    }

}
