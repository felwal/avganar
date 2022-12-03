module DictUtil {

    function hasValue(dict, key) {
        return dict != null && dict.hasKey(key) && dict[key] != null;
    }

    function get(dict, key, def) {
        return hasValue(dict, key) ? dict[key] : def;
    }

}
