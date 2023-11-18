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

class DialogViewModel {

    var title;
    var messages;
    var iconRezId = null;
    var pageCursor = 0;

    //

    function initialize(title, messages, iconRezId) {
        me.title = title;
        me.messages = messages;
        me.iconRezId = iconRezId;
    }

    function getMessage() {
        return ArrUtil.get(messages, pageCursor, "");
    }

    function onNextMessage() {
        if (messages.size() <= 1) {
            return;
        }

        // rotate page
        pageCursor = MathUtil.mod(pageCursor + 1, messages.size());
        WatchUi.requestUpdate();
    }

}
