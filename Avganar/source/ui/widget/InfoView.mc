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

using Toybox.Graphics;
using Toybox.Math;
using Toybox.WatchUi;

//! An asbtraction for an info/about page, similar to
//! the stock Menu/Settings/System/About page.
class InfoView extends WatchUi.View {

    hidden var _text;

    // init

    function initialize(text) {
        View.initialize();
        _text = text;
    }

    // override View

    function onUpdate(dc) {
        View.onUpdate(dc);

        // draw
        Graphite.enableAntiAlias(dc);
        _draw(dc);
    }

    // draw

    function _draw(dc) {
        Graphite.fillBackground(dc, AppColors.BACKGROUND_INVERTED);
        Graphite.fillTextArea(dc, _text, AppColors.TEXT_INVERTED);
    }

}
