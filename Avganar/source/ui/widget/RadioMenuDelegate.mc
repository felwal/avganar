using Toybox.WatchUi;
using Carbon.Chem;

class RadioMenuDelegate extends WatchUi.Menu2InputDelegate {

    hidden var _menu;
    hidden var _callback;

    // init

    function initialize(title, labels, values, focus, callback) {
        Menu2InputDelegate.initialize();

        _callback = callback;
        _addItems(title, labels, values, focus);
    }

    hidden function _addItems(title, labels, values, focus) {
        _menu = new WatchUi.Menu2({ :title => title });

        var itemCount = labels == null
            ? values.size()
            : Chem.min(labels.size(), values.size());

        for (var i = 0; i < itemCount; i++) {
            _menu.addItem(new WatchUi.MenuItem(
                labels == null
                    ? values[i].toString()
                    : labels[i],
                "", values[i], {}
            ));
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
