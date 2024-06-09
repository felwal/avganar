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

import Toybox.Graphics;
import Toybox.Lang;

class DialogViewModel {

    var title as String;
    var messages as Array<String>;
    var iconRezId as ResourceId?;
    var pageCursor as Number = 0;

    //

    function initialize(title as String, messages as Array<String>, iconRezId as ResourceId?) {
        me.title = title;
        me.messages = messages;
        me.iconRezId = iconRezId;
    }

    function getMessage() as String {
        return ArrUtil.get(messages, pageCursor, "");
    }

    function onNextMessage() as Void {
        if (messages.size() <= 1) {
            return;
        }

        // rotate page
        pageCursor = MathUtil.modulo(pageCursor + 1, messages.size());
        WatchUi.requestUpdate();
    }

}
