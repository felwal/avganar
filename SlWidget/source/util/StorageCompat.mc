using Toybox.Application.Storage;

(:glance)
class StorageCompat {

    static function getValue(key, def) {
        var val = Storage.getValue(key);
        return val != null ? val : def;
    }

    static function getArray(key) {
        return getValue(key, []);
    }

}
