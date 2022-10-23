using Toybox.WatchUi;

class RadioMenuDelegate extends WatchUi.Menu2InputDelegate {

    private var _menu;
    private var _callback;

    // init

    function initialize(title, labels, values, focus, callback) {
        Menu2InputDelegate.initialize();

        _callback = callback;
        _addItems(title, labels, values, focus);
    }

    private function _addItems(title, labels, values, focus) {
        _menu = new WatchUi.Menu2({ :title => title });

        for (var i = 0; i < labels.size(); i++) {
            _menu.addItem(new WatchUi.MenuItem(labels[i], "", values[i], {}));
        }

        _menu.setFocus(focus);
    }

    function push() {
        WatchUi.pushView(_menu, me, WatchUi.SLIDE_LEFT);
    }

    // override Menu2InputDelegate

    function onSelect(item) {
        _callback.invoke(item.getId());
        onBack();
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }

}
