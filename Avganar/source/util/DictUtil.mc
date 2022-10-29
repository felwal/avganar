module DictUtil {

    function hasKey(dict, key) {
        return dict != null && dict.hasKey(key) && dict[key] != null;
    }

    function get(dict, key, def) {
        return hasKey(dict, key) ? dict[key] : def;
    }

}
