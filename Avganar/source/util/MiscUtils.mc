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

using Toybox.Attention;

(:glance)
function def(val, def) {
    return val != null ? val : def;
}

function vibrate() {
    if (!shouldNotDisturb() && isVibrateOn() && SettingsStorage.getVibrateOnResponse()) {
        var vibeData = [ new Attention.VibeProfile(75, 300) ];
        Attention.vibrate(vibeData);
    }
}
