using Toybox.WatchUi;

class SettingsMenuDelegate extends WatchUi.Menu2InputDelegate {

    static const ITEM_FAVORITE_ADD = :addFavorite;
    static const ITEM_FAVORITE_REMOVE = :removeFavorite;
    static const ITEM_FAVORITE_MOVE_UP = :moveFavoriteUp;
    static const ITEM_FAVORITE_MOVE_DOWN = :moveFavoriteDown;
    static const ITEM_VIBRATE = :vibrateOnResponse;
    static const ITEM_TIME_WINDOW = :defaultTimeWindow;
    static const ITEM_API = :apiInfo;
    static const ITEM_ABOUT = :aboutInfo;

    private var _viewModel;
    private var _menu;

    // init

    function initialize(viewModel) {
        Menu2InputDelegate.initialize();
        _viewModel = viewModel;
        _addItems();
    }

    private function _addItems() {
        _menu = new WatchUi.Menu2({ :title => rez(Rez.Strings.lbl_settings_title) });

        if (_viewModel.isFavorite()) {
            var isInFavorites = _viewModel.stopCursor < _viewModel.getFavoriteCount();

            // move favorite
            if (isInFavorites && _viewModel.stopCursor != 0) {
                // move up
                _menu.addItem(new WatchUi.MenuItem(
                    rez(Rez.Strings.lbl_settings_favorite_move_up), "",
                    ITEM_FAVORITE_MOVE_UP, {}
                ));
            }
            if (isInFavorites && _viewModel.stopCursor != _viewModel.getFavoriteCount() - 1) {
                // move down
                _menu.addItem(new WatchUi.MenuItem(
                    rez(Rez.Strings.lbl_settings_favorite_move_down), "",
                    ITEM_FAVORITE_MOVE_DOWN, {}
                ));
            }

            // remove favorite
            _menu.addItem(new WatchUi.MenuItem(
                rez(Rez.Strings.lbl_settings_favorite_remove), "",
                ITEM_FAVORITE_REMOVE, {}
            ));
        }
        else {
            // add favorite
            _menu.addItem(new WatchUi.MenuItem(
                rez(Rez.Strings.lbl_settings_favorite_add), "",
                ITEM_FAVORITE_ADD, {}
            ));
        }

        // vibrate on response
        _menu.addItem(new WatchUi.ToggleMenuItem(
            rez(Rez.Strings.lbl_settings_vibrate), { :enabled => "On", :disabled => "Off" },
            ITEM_VIBRATE, SettingsStorage.getVibrateOnResponse(), {}
        ));

        // default time window
        _menu.addItem(new WatchUi.MenuItem(
            rez(Rez.Strings.lbl_settings_time_window), SettingsStorage.getDefaultTimeWindow() + " min",
            ITEM_TIME_WINDOW, {}
        ));

        // api info
        _menu.addItem(new WatchUi.MenuItem(
            rez(Rez.Strings.lbl_settings_api), "",
            ITEM_API, {}
        ));

        // about
        _menu.addItem(new WatchUi.MenuItem(
            rez(Rez.Strings.lbl_settings_about), "",
            ITEM_ABOUT, {}
        ));
    }

    function push(transition) {
        WatchUi.pushView(_menu, me, transition);
    }

    // override Menu2InputDelegate

    function onSelect(item) {
        var view = null;

        switch (item.getId()) {
            case ITEM_FAVORITE_ADD:
                _viewModel.addFavorite();
                break;
            case ITEM_FAVORITE_REMOVE:
                _viewModel.removeFavorite();
                break;
            case ITEM_FAVORITE_MOVE_UP:
                _viewModel.moveFavorite(-1);
                break;
            case ITEM_FAVORITE_MOVE_DOWN:
                _viewModel.moveFavorite(1);
                break;
            case ITEM_TIME_WINDOW:
                var title = rez(Rez.Strings.lbl_settings_time_window);
                var labels = [ "60 min", "45 min", "30 min", "15 min" ];
                var values = [ 60, 45, 30, 15 ];
                var focus = values.indexOf(SettingsStorage.getDefaultTimeWindow());
                new RadioMenuDelegate(title, labels, values, focus, method(:onListMenuDelegateSelect)).push();
                return;
            case ITEM_VIBRATE:
                SettingsStorage.setVibrateOnResponse(item.isEnabled());
                return;
            case ITEM_API:
                view = new InfoView(rez(Rez.Strings.lbl_info_api));
                break;
            case ITEM_ABOUT:
                view = new InfoView(rez(Rez.Strings.lbl_info_about));
                break;
        }

        if (view == null) {
            WatchUi.popView(WatchUi.SLIDE_BLINK);
        }
        else {
            WatchUi.pushView(view, null, WatchUi.SLIDE_LEFT);
        }
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_BLINK);
        return true;
    }

    //

    function onListMenuDelegateSelect(value) {
        SettingsStorage.setDefaultTimeWindow(value);

        var item = _menu.getItem(_menu.findItemById(ITEM_TIME_WINDOW));
        item.setSubLabel(value + " min");
    }

}
