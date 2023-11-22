// This file is part of Avgånär.
//
// Avgånär is free software: you can redistribute it and/or modify it under the terms of
// the GNU General Public License as published by the Free Software Foundation,
// either version 3 of the License, or (at your option) any later version.
//
// Avgånär is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
// without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with Avgånär.
// If not, see <https://www.gnu.org/licenses/>.

using Toybox.WatchUi;

//! An abstraction for creating select-one options menus.
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
            : MathUtil.min(labels.size(), values.size());

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
