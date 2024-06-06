import Toybox.Lang;

module StringUtil {

    function charAt(str as String, index as Number) as String {
        return str.substring(index, index + 1);
    }

}
