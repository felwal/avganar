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
        if (_viewModel.hasStops() && !_viewModel.isShowingMessage()) {
            _pushStopDetail();
        }
        return true;
    }

    //! "BACK"
    function onBack() {
        if (hasPreview()) {
            WatchUi.popView(WatchUi.SLIDE_BLINK);
            return true;
        }
        else {
            return false;
        }
    }

    //

    private function _pushSettings() {
        var delegate = new SettingsMenuDelegate(_viewModel);
        var menu = new WatchUi.Menu2({ :title => rez(Rez.Strings.lbl_settings_title) });

        if (_viewModel.isFavorite()) {
            var isInFavourites = _viewModel.stopCursor < _viewModel.getFavoriteCount();

            // move favorite
            if (isInFavourites && _viewModel.stopCursor != 0) {
                // move up
                menu.addItem(new WatchUi.MenuItem(
                    rez(Rez.Strings.lbl_settings_favorite_move_up), "",
                    SettingsMenuDelegate.ITEM_FAVORITE_MOVE_UP, {}
                ));
            }
            if (isInFavourites && _viewModel.stopCursor != _viewModel.getFavoriteCount() - 1) {
                // move down
                menu.addItem(new WatchUi.MenuItem(
                    rez(Rez.Strings.lbl_settings_favorite_move_down), "",
                    SettingsMenuDelegate.ITEM_FAVORITE_MOVE_DOWN, {}
                ));
            }

            // remove favorite
            menu.addItem(new WatchUi.MenuItem(
                rez(Rez.Strings.lbl_settings_favorite_remove), "",
                SettingsMenuDelegate.ITEM_FAVORITE_REMOVE, {}
            ));
        }
        else {
            // add favorite
            menu.addItem(new WatchUi.MenuItem(
                rez(Rez.Strings.lbl_settings_favorite_add), "",
                SettingsMenuDelegate.ITEM_FAVORITE_ADD, {}
            ));
        }

        // vibrate on response
        menu.addItem(new WatchUi.ToggleMenuItem(
            rez(Rez.Strings.lbl_settings_vibrate), { :enabled => "On", :disabled => "Off" },
            SettingsMenuDelegate.ITEM_VIBRATE, SettingsStorage.getVibrateOnResponse(), {}
        ));

        // api info
        menu.addItem(new WatchUi.MenuItem(
            rez(Rez.Strings.lbl_settings_api), "",
            SettingsMenuDelegate.ITEM_API, {}
        ));

        // about
        menu.addItem(new WatchUi.MenuItem(
            rez(Rez.Strings.lbl_settings_about), "",
            SettingsMenuDelegate.ITEM_ABOUT, {}
        ));

        WatchUi.pushView(menu, delegate, WatchUi.SLIDE_BLINK);
    }

    private function _pushStopDetail() {
        var viewModel = new StopDetailViewModel(_repo, _viewModel.getSelectedStop());
        var view = new StopDetailView(viewModel);
        var delegate = new StopDetailDelegate(viewModel);

        WatchUi.pushView(view, delegate, WatchUi.SLIDE_LEFT);
    }

}
