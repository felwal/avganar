using Toybox.Application.Storage;

class SettingsStorage {

    private static const _STORAGE_VIBRATE = "vibrate_on_response";
    private static const _STORAGE_TIME_WINDOW = "default_time_window";

    // read

    static function getVibrateOnResponse() {
        var enabled = Storage.getValue(_STORAGE_VIBRATE);
        return enabled == null ? true : enabled;
    }

    static function getDefaultTimeWindow() {
        var timeWindow = Storage.getValue(_STORAGE_TIME_WINDOW);
        return timeWindow == null ? 60 : timeWindow;
    }

    // write

    static function setVibrateOnResponse(enabled) {
        Storage.setValue(_STORAGE_VIBRATE, enabled);
    }

    static function setDefaultTimeWindow(timeWindow) {
        Storage.setValue(_STORAGE_TIME_WINDOW, timeWindow);
    }

}
