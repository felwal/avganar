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

import Toybox.Lang;
import Toybox.WatchUi;

//! An abstraction for creating select-one options menus.
class RadioMenuDelegate extends WatchUi.Menu2InputDelegate {

    hidden var _menu as Menu2;
    hidden var _callback as Method;

    // init

    function initialize(title as String, labels as Array<String>?,
        values as Array, focus as Number, callback as Method) {

        Menu2InputDelegate.initialize();

        _callback = callback;
        _menu = new WatchUi.Menu2({ :title => title });
        _addItems(labels, values, focus);
    }

    hidden function _addItems(labels as Array<String>?, values as Array, focus as Number) as Void {
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

    function push() as Void {
        WatchUi.pushView(_menu, me, WatchUi.SLIDE_LEFT);
    }

    // override Menu2InputDelegate

    function onSelect(item as MenuItem) as Void {
        _callback.invoke(item.getId());
        onBack();
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

}
