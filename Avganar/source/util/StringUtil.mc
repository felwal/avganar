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

    function replaceWord(str as String, pattern as String, replacement as String) as String {
        var patternStartInd = str.find(pattern);
        if (patternStartInd == null) {
            return str;
        }

        var patternEndInd = patternStartInd + pattern.length();

        // not a distinct word
        if ((patternEndInd != str.length() && !charAt(str, patternEndInd).equals(" "))
            || (patternStartInd != 0 && !charAt(str, patternStartInd - 1).equals(" "))) {

            return str;
        }

        var firstHalf = str.substring(0, patternStartInd);
        var secondHalf = str.substring(patternEndInd, str.length());

        return firstHalf + replacement + secondHalf;
    }

    function trim(str as String) as String {
        while (charAt(str, 0).equals(" ")
            || charAt(str, 0).equals("\n")) {

            str = str.substring(1, str.length());
        }

        while (charAt(str, str.length() - 1).equals(" ")
            || charAt(str, str.length() - 1).equals("\n")) {

            str = str.substring(0, str.length() - 1);
        }

        return str;
    }

    function isEmpty(str as String?) as Boolean {
        return str == null || str.equals("");
    }

}
