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

module StringUtil {

    function charAt(str as String, index as Number) as String {
        return str.substring(index, index + 1);
    }

    function replace(str as String, pattern as String, replacement as String) as String {
        var toRemoveStartInd = str.find(pattern);
        if (toRemoveStartInd == null) {
            return str;
        }

        var toRemoveEndInd = toRemoveStartInd + pattern.length();
        var firstHalf = str.substring(0, toRemoveStartInd);
        var secondHalf = str.substring(toRemoveEndInd, str.length());

        return firstHalf + replacement + secondHalf;
    }

    function remove(str as String, pattern as String) as String {
        return replace(str, pattern, "");
    }

    function removeEnding(str as String, pattern as String) as String {
        var toRemoveStartInd = str.find(pattern);
        if (toRemoveStartInd == null) {
            return str;
        }

        return str.substring(0, toRemoveStartInd);
    }

    function trim(str as String) as String {
        while (charAt(str, 0).equals(" ")) {
            str = str.substring(1, str.length());
        }

        while (charAt(str, str.length() - 1).equals(" ")) {
            str = str.substring(0, str.length() - 1);
        }

        return str;
    }

    function isEmpty(str as String?) as Boolean {
        return str == null || str.equals("");
    }

}
