using Toybox.Application.Storage;

(:glance)
module StorageUtil {

    function getValue(key, def) {
        var val = Storage.getValue(key);
        return def(val, def);
    }

    function getArray(key) {
        return getValue(key, []);
    }

}
