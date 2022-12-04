using Toybox.WatchUi;

class SettingsMenuDelegate extends WatchUi.Menu2InputDelegate {

    static const ITEM_FAVORITE_ADD = :addFavorite;
    static const ITEM_FAVORITE_REMOVE = :removeFavorite;
    static const ITEM_FAVORITE_MOVE_UP = :moveFavoriteUp;
    static const ITEM_FAVORITE_MOVE_DOWN = :moveFavoriteDown;
    static const ITEM_VIBRATE = :vibrateOnResponse;
    static const ITEM_MAX_STOPS = :maxNoStops;
    static const ITEM_MAX_DEPARTURES = :maxNoDepartures;
    static const ITEM_TIME_WINDOW = :defaultTimeWindow;
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
        _menu = new WatchUi.Menu2({ :title => rez(Rez.Strings.lbl_settings_title) });

        // favorite settings
        if (_viewModel.isSelectedStopFavorite()) {
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
        else if (!_viewModel.isShowingMessage()) {
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

        // max stops
        _menu.addItem(new WatchUi.MenuItem(
            rez(Rez.Strings.lbl_settings_max_stops), SettingsStorage.getMaxStops().toString(),
            ITEM_MAX_STOPS, {}
        ));

        // max departures
        _menu.addItem(new WatchUi.MenuItem(
            rez(Rez.Strings.lbl_settings_max_departures), SettingsStorage.getMaxDepartures().toString(),
            ITEM_MAX_DEPARTURES, {}
        ));

        // default time window
        _menu.addItem(new WatchUi.MenuItem(
            rez(Rez.Strings.lbl_settings_time_window), SettingsStorage.getDefaultTimeWindow() + " min",
            ITEM_TIME_WINDOW, {}
        ));

        // about
        _menu.addItem(new WatchUi.MenuItem(
            rez(Rez.Strings.lbl_settings_about), "",
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
        else if (id == ITEM_MAX_STOPS) {
            var title = rez(Rez.Strings.lbl_settings_max_stops);
            var labels = [ "5", "10", "15", "20" ];
            var values = [ 5, 10, 15, 20 ];
            var focus = values.indexOf(SettingsStorage.getMaxStops());
            new RadioMenuDelegate(title, labels, values, focus, method(:onMaxStopsSelect)).push();
            return;
        }
        else if (id == ITEM_MAX_DEPARTURES) {
            var title = rez(Rez.Strings.lbl_settings_max_departures);
            var labels = [ "10", "20", "40", "60" ];
            var values = [ 10, 20, 40, 60 ];
            var focus = values.indexOf(SettingsStorage.getMaxDepartures());
            new RadioMenuDelegate(title, labels, values, focus, method(:onMaxDeparturesSelect)).push();
            return;
        }
        else if (id == ITEM_TIME_WINDOW) {
            var title = rez(Rez.Strings.lbl_settings_time_window);
            var labels = [ "1 min", "5 min", "15 min", "30 min", "45 min", "60 min" ];
            var values = [ 1, 5, 15, 30, 45, 60 ];
            var focus = values.indexOf(SettingsStorage.getDefaultTimeWindow());
            new RadioMenuDelegate(title, labels, values, focus, method(:onTimeWindowSelect)).push();
            return;
        }
        else if (id == ITEM_VIBRATE) {
            SettingsStorage.setVibrateOnResponse(item.isEnabled());
            return;
        }
        else if (id == ITEM_ABOUT) {
            view = new InfoView(rez(Rez.Strings.lbl_info_about));
        }
        else if (id == ITEM_RESET) {
            NearbyStopsStorage.setResponse([], [], null);
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

    function onMaxStopsSelect(value) {
        SettingsStorage.setMaxStops(value);

        var item = _menu.getItem(_menu.findItemById(ITEM_MAX_STOPS));
        item.setSubLabel(value.toString());
    }

    function onMaxDeparturesSelect(value) {
        SettingsStorage.setMaxDepartures(value);

        var item = _menu.getItem(_menu.findItemById(ITEM_MAX_DEPARTURES));
        item.setSubLabel(value.toString());
    }

    function onTimeWindowSelect(value) {
        SettingsStorage.setDefaultTimeWindow(value);

        var item = _menu.getItem(_menu.findItemById(ITEM_TIME_WINDOW));
        item.setSubLabel(value + " min");
    }

}
