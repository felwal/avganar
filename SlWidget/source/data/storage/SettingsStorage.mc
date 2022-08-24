using Toybox.Application.Storage;

class SettingsStorage {

    private static const _STORAGE_VIBRATE = "vibrate_on_response";

    // read

    static function getVibrateOnResponse() {
        var enabled = Storage.getValue(_STORAGE_VIBRATE);
        return enabled == null ? true : enabled;
    }

    // write

    static function setVibrateOnResponse(enabled) {
        Storage.setValue(_STORAGE_VIBRATE, enabled);
    }

}
