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

(:glance)
module ArrUtil {

    function filled(size, value) {
        var arr = [];

        for (var i = 0; i < size; i++) {
            arr.add(value);
        }

        return arr;
    }

    function equals(arr1, arr2) {
        if (arr1.size() != arr2.size()) { return false; }

        for (var i = 0; i < arr1.size(); i++) {
            if (arr1[i] != arr2[i]) { return false; }
        }

        return true;
    }

    function contains(arr, item) {
        return arr.indexOf(item) != -1;
    }

    function removeAt(arr, index) {
        return arr.remove(arr[index]);
    }

    function merge(arr1, arr2) {
        var arr = new [arr1.size() + arr2.size()];

        for (var i = 0; i < arr1.size(); i++) {
            arr[i] = arr1[i];
        }
        for (var i = 0; i < arr2.size(); i++) {
            arr[arr1.size() + i] = arr2[i];
        }

        return arr;
    }

    function add(arr1, arr2) {
        var sum = [];
        for (var i = 0; i < arr1.size() && i < arr2.size(); i++) {
            sum.add(arr1[i] + arr2[i]);
        }
        return sum;
    }

    function get(arr, index, def) {
        return index >= 0 && index < arr.size()
            ? arr[index]
            : def;
    }

    function getAll(arr, indices) {
        var items = [];

        for (var i = 0; i < indices.size(); i++) {
            var index = indices[i];
            if (index < arr.size()) {
                items.add(arr[index]);
            }
        }

        return items;
    }

    function indicesOf(arr, item) {
        var indices = [];

        for (var i = 0; i < arr.size(); i++) {
            if (arr[i].equals(item)) {
                indices.add(i);
            }
        }

        return indices;
    }

    function coerceGet(arr, index) {
        return arr.size() > 0
            ? arr[MathUtil.coerceIn(index, 0, arr.size() - 1)]
            : null;
    }

    function swap(arr, i, j) {
        var temp = arr[i];
        arr[i] = arr[j];
        arr[j] = temp;
    }

}
