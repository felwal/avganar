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

using Toybox.Attention;
using Toybox.System;

module SystemUtil {

    function hasGlance() as Boolean {
        var ds = System.getDeviceSettings();
        return ds has :isGlanceModeEnabled && ds.isGlanceModeEnabled;
    }

    function isLangSwe() as Boolean {
        var ds = System.getDeviceSettings();
        return ds.systemLanguage == System.LANGUAGE_SWE;
    }

    // vibration

    function shouldNotDisturb() as Boolean {
        var ds = System.getDeviceSettings();
        return ds has :doNotDisturb && ds.doNotDisturb;
    }

    function isVibrateOn() as Boolean {
        var ds = System.getDeviceSettings();
        return Attention has :vibrate && ds has :vibrateOn && ds.vibrateOn;
    }

    function shouldVibrate() as Boolean {
        return !shouldNotDisturb() && isVibrateOn() && SettingsStorage.getVibrateOnResponse();
    }

    function vibrate(cycle as Number, length as Number) as Void {
        if (shouldVibrate()) {
            var vibeData = [ new Attention.VibeProfile(cycle, length) ];
            Attention.vibrate(vibeData);
        }
    }

    function vibrateLong() as Void {
        vibrate(75, 300);
    }

    function vibrateShort() as Void {
        vibrate(75, 100);
    }

}
