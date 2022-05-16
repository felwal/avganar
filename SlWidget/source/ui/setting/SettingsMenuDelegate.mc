using Toybox.WatchUi;

class SettingsMenuDelegate extends WatchUi.MenuInputDelegate {

    static const ITEM_API = :apiInfo;
    static const ITEM_ABOUT = :aboutInfo;

    // init

    function initialize() {
        MenuInputDelegate.initialize();
    }

    // override MenuInputDelegate

    function onMenuItem(item) {
        var view = null;

        switch (item) {
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
