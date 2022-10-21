using Toybox.Application.Storage;

class SettingsStorage {

    private static const _STORAGE_VIBRATE = "vibrate_on_response";
    private static const _STORAGE_TIME_WINDOW = "default_time_window";

    // read

    static function getVibrateOnResponse() {
        return StorageUtil.getValue(_STORAGE_VIBRATE, true);
    }

    static function getDefaultTimeWindow() {
        return StorageUtil.getValue(_STORAGE_TIME_WINDOW, 30);
    }

    // write

    static function setVibrateOnResponse(enabled) {
        Storage.setValue(_STORAGE_VIBRATE, enabled);
    }

    static function setDefaultTimeWindow(timeWindow) {
        Storage.setValue(_STORAGE_TIME_WINDOW, timeWindow);
    }

}
