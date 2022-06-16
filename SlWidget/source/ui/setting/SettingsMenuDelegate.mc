using Toybox.WatchUi;

class SettingsMenuDelegate extends WatchUi.MenuInputDelegate {

    static const ITEM_FAVORITE_ADD = :addFavorite;
    static const ITEM_FAVORITE_REMOVE = :removeFavorite;
    static const ITEM_FAVORITE_MOVE_UP = :moveFavoriteUp;
    static const ITEM_FAVORITE_MOVE_DOWN = :moveFavoriteDown;
    static const ITEM_API = :apiInfo;
    static const ITEM_ABOUT = :aboutInfo;

    private var _viewModel;

    // init

    function initialize(viewModel) {
        MenuInputDelegate.initialize();
        _viewModel = viewModel;
    }

    // override MenuInputDelegate

    function onMenuItem(item) {
        var view = null;

        switch (item) {
            case ITEM_FAVORITE_ADD:
                _viewModel.addFavorite();
                return;
            case ITEM_FAVORITE_REMOVE:
                _viewModel.removeFavorite();
                return;
            case ITEM_FAVORITE_MOVE_UP:
                _viewModel.moveFavorite(-1);
                return;
            case ITEM_FAVORITE_MOVE_DOWN:
                _viewModel.moveFavorite(1);
                return;
            case ITEM_API:
                view = new InfoView(rez(Rez.Strings.lbl_info_api));
                break;
            case ITEM_ABOUT:
                view = new InfoView(rez(Rez.Strings.lbl_info_about));
                break;
        }

        WatchUi.pushView(view, null, WatchUi.SLIDE_LEFT);
    }

}
