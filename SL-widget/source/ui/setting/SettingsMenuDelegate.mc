using Toybox.WatchUi;

class SettingsMenuDelegate extends WatchUi.MenuInputDelegate {

    static const ITEM_API = :apiInfo;

    //

    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item) {
        if (item == ITEM_API) {
            var view = new ApiInfoView();
            WatchUi.pushView(view, null, WatchUi.SLIDE_LEFT);
        }
    }

}
