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
using Toybox.System;

function hasGlance() {
    var ds = System.getDeviceSettings();
    return ds has :isGlanceModeEnabled && ds.isGlanceModeEnabled;
}

function shouldNotDisturb() {
    var ds = System.getDeviceSettings();
    return ds has :doNotDisturb && ds.doNotDisturb;
}

function isVibrateOn() {
    var ds = System.getDeviceSettings();
    return Attention has :vibrate && ds has :vibrateOn && ds.vibrateOn;
}

function isLangSwe() {
    var ds = System.getDeviceSettings();
    return ds.systemLanguage == System.LANGUAGE_SWE;
}
