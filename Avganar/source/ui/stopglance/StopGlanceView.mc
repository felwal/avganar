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
using Toybox.WatchUi;

//! The glance displays app name and last saved nearest stop.
(:glance :glanceExclusive)
class StopGlanceView extends WatchUi.GlanceView {

    // init

    function initialize() {
        GlanceView.initialize();
    }

    // override GlanceView

    function onUpdate(dc) {
        GlanceView.onUpdate(dc);

        // draw
        Graphite.enableAntiAlias(dc);
        _draw(dc);
    }

    // draw

    hidden function _draw(dc) {
        var nearestStopName = NearbyStopsStorage.getNearestStopName();
        var title = rez(Rez.Strings.app_name);
        var caption = def(nearestStopName, rez(Rez.Strings.lbl_glance_caption_no_stops));
        var cy = dc.getHeight() / 2;

        // title
        var font = Graphics.FONT_GLANCE;
        var fh = dc.getFontHeight(font);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK); // TODO: remove?
        dc.drawText(0, cy - fh - px(1), font, title.toUpper(), Graphics.TEXT_JUSTIFY_LEFT);

        // caption
        dc.drawText(0, cy + px(2), Graphics.FONT_TINY, caption, Graphics.TEXT_JUSTIFY_LEFT);
    }

}
