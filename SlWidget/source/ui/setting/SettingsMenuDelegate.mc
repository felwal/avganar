using Toybox.WatchUi;

class SettingsMenuDelegate extends WatchUi.MenuInputDelegate {

    static const ITEM_API = :apiInfo;

    // init

    function initialize() {
        MenuInputDelegate.initialize();
    }

    // override MenuInputDelegate

    function onMenuItem(item) {
        if (item == ITEM_API) {
            var view = new ApiInfoView();
            WatchUi.pushView(view, null, WatchUi.SLIDE_LEFT);
        }
    }

}
