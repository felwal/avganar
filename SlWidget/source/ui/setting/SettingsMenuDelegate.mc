using Toybox.WatchUi;

class SettingsMenuDelegate extends WatchUi.Menu2InputDelegate {

    static const ITEM_FAVORITE_ADD = :addFavorite;
    static const ITEM_FAVORITE_REMOVE = :removeFavorite;
    static const ITEM_FAVORITE_MOVE_UP = :moveFavoriteUp;
    static const ITEM_FAVORITE_MOVE_DOWN = :moveFavoriteDown;
    static const ITEM_API = :apiInfo;
    static const ITEM_ABOUT = :aboutInfo;

    private var _viewModel;

    // init

    function initialize(viewModel) {
        Menu2InputDelegate.initialize();
        _viewModel = viewModel;
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

}
