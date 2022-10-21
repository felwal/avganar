using Carbon.Chem;

(:glance)
module ArrUtil {

    function equals(arr1, arr2) {
        if (arr1.size() != arr2.size()) { return false; }

        for (var i = 0; i < arr1.size(); i++) {
            if (arr1[i] != arr2[i]) { return false; }
        }

        return true;
    }

    function in(arr, item) {
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

    function coerceGet(arr, index) {
        return arr.size() > 0
            ? arr[Chem.coerceIn(index, 0, arr.size() - 1)]
            : null;
    }

    function swap(arr, i, j) {
        var temp = arr[i];
        arr[i] = arr[j];
        arr[j] = temp;
    }

}
