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

using Toybox.Application;
using Toybox.WatchUi;

module RezUtil {

    function drawBitmap(dc, x, y, rezId) {
        var bitmap = new WatchUi.Bitmap({ :rezId => rezId });

        bitmap.setLocation(x - bitmap.width / 2, y - bitmap.height / 2);
        bitmap.draw(dc);
    }

}

(:glance)
function rez(rezId) {
    return Application.loadResource(rezId);
}
