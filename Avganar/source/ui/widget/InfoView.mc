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

using Toybox.WatchUi;

//! An asbtraction for an info/about page, similar to
//! the stock Menu/Settings/System/About page.
class InfoView extends WatchUi.View {

    private var _text as String;

    // init

    function initialize(text as String) {
        View.initialize();
        _text = text;
    }

    // lifecycle

    function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);
        Graphite.enableAntiAlias(dc);

        _draw(dc);
    }

    // draw

    private function _draw(dc as Dc) as Void {
        Graphite.fillBackground(dc, AppColors.BACKGROUND_INVERTED);
        Graphite.fillTextArea(dc, _text, AppColors.TEXT_INVERTED);
    }

}
