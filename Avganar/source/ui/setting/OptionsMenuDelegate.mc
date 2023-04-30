using Toybox.WatchUi;

class OptionsMenuDelegate extends WatchUi.Menu2InputDelegate {

    static const ITEM_FAVORITE_ADD = :addFavorite;
    static const ITEM_FAVORITE_REMOVE = :removeFavorite;
    static const ITEM_FAVORITE_MOVE_UP = :moveFavoriteUp;
    static const ITEM_FAVORITE_MOVE_DOWN = :moveFavoriteDown;
    static const ITEM_SETTINGS = :settings;
    static const ITEM_ABOUT = :aboutInfo;
    static const ITEM_RESET = :resetStorage;

    hidden var _viewModel;
    hidden var _menu;

    // init

    function initialize(viewModel) {
        Menu2InputDelegate.initialize();
        _viewModel = viewModel;
        _addItems();
    }

    hidden function _addItems() {
        _menu = new WatchUi.Menu2({ :title => rez(Rez.Strings.lbl_options_title) });

        // favorite settings
        if (_viewModel.isSelectedStopFavorite()) {
            var isInFavorites = _viewModel.stopCursor < _viewModel.getFavoriteCount();

            // move favorite
            if (isInFavorites && _viewModel.stopCursor != 0) {
                // move up
                _menu.addItem(new WatchUi.MenuItem(
                    rez(Rez.Strings.lbl_options_favorite_move_up), "",
                    ITEM_FAVORITE_MOVE_UP, {}
                ));
            }
            if (isInFavorites && _viewModel.stopCursor != _viewModel.getFavoriteCount() - 1) {
                // move down
                _menu.addItem(new WatchUi.MenuItem(
                    rez(Rez.Strings.lbl_options_favorite_move_down), "",
                    ITEM_FAVORITE_MOVE_DOWN, {}
                ));
            }

            // remove favorite
            _menu.addItem(new WatchUi.MenuItem(
                rez(Rez.Strings.lbl_options_favorite_remove), "",
                ITEM_FAVORITE_REMOVE, {}
            ));
        }
        else if (!_viewModel.isShowingMessage()) {
            // add favorite
            _menu.addItem(new WatchUi.MenuItem(
                rez(Rez.Strings.lbl_options_favorite_add), "",
                ITEM_FAVORITE_ADD, {}
            ));
        }

        // settings
        _menu.addItem(new WatchUi.MenuItem(
            rez(Rez.Strings.lbl_options_settings), "",
            ITEM_SETTINGS, {}
        ));

        // about
        _menu.addItem(new WatchUi.MenuItem(
            rez(Rez.Strings.lbl_options_about), "",
            ITEM_ABOUT, {}
        ));

        // reset
        _menu.addItem(new WatchUi.MenuItem(
            "Reset storage", "",
            ITEM_RESET, {}
        ));
    }

    function push(transition) {
        WatchUi.pushView(_menu, me, transition);
    }

    // override Menu2InputDelegate

    function onSelect(item) {
        var view = null;
        var id = item.getId();

        if (id == ITEM_FAVORITE_ADD) {
            _viewModel.addFavorite();
        }
        else if (id == ITEM_FAVORITE_REMOVE) {
            _viewModel.removeFavorite();
        }
        else if (id == ITEM_FAVORITE_MOVE_UP) {
            _viewModel.moveFavorite(-1);
        }
        else if (id == ITEM_FAVORITE_MOVE_DOWN) {
            _viewModel.moveFavorite(1);
        }
        else if (id == ITEM_SETTINGS) {
            new SettingsMenuDelegate().push(WatchUi.SLIDE_LEFT);
            return;
        }
        else if (id == ITEM_ABOUT) {
            var text = rez(Rez.Strings.app_version) + ". " + rez(Rez.Strings.lbl_info_about);
            view = new InfoView(text);
        }
        else if (id == ITEM_RESET) {
            // does not request immediatly,
            // but thats ok since it is a dev-temp
            NearbyStopsStorage.setResponse([], [], null);
        }

        if (view == null) {
            // if no new view is opened, close the menu
            onBack();
        }
        else {
            WatchUi.pushView(view, null, WatchUi.SLIDE_LEFT);
        }
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_BLINK);
        return true;
    }

}
