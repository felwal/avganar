using Toybox.Application.Storage;

(:glance)
class StorageUtil {

    static function getValue(key, def) {
        var val = Storage.getValue(key);
        return val != null ? val : def;
    }

    static function getArray(key) {
        return getValue(key, []);
    }

}
