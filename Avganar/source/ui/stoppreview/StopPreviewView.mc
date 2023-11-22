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

//! The preview is functionally equivalent to and replaces `StopGlanceView`
//! on devices not supporting glance.
//! This is mostly to reduce computation on merely scrolling past the widget.
class StopPreviewView extends WatchUi.View {

    // init

    function initialize() {
        View.initialize();
    }

    // override View

    function onUpdate(dc) {
        View.onUpdate(dc);

        // draw
        Graphite.enableAntiAlias(dc);
        _draw(dc);
    }

    // draw

    hidden function _draw(dc) {
        var stopName = NearbyStopsStorage.getNearestStopName();

        if (stopName == null) {
            WidgetUtil.drawDialog(dc, rez(Rez.Strings.lbl_preview_msg_no_stops));
        }
        else {
            _drawStop(dc, stopName);
        }

        // icon
        WidgetUtil.drawPreviewTitle(dc, rez(Rez.Strings.app_name), Rez.Drawables.ic_launcher, false);
    }

    hidden function _drawStop(dc, stopName) {
        var fonts = [ Graphics.FONT_LARGE, Graphics.FONT_MEDIUM ];
        var fh = dc.getFontHeight(fonts[0]);
        var height = 2 * fh;

        var minXAtTextBottom = MathUtil.minX(Graphite.getCenterY(dc) - fh / 2 + height, Graphite.getRadius(dc));
        var margin = minXAtTextBottom + px(2);
        var width = dc.getWidth() - 2 * margin;

        Graphite.drawTextArea(dc, Graphite.getCenterX(dc), Graphite.getCenterY(dc) - fh / 2, width, height,
            fonts, stopName, Graphics.TEXT_JUSTIFY_CENTER, AppColors.TEXT_PRIMARY);

        Graphite.resetColor(dc);
    }

}
