using Toybox.Application.Storage;

module SettingsStorage {

    const _STORAGE_VIBRATE = "vibrate_on_response";
    const _STORAGE_MAX_STOPS = "max_no_stops";
    const _STORAGE_MAX_DEPARTURES = "max_no_departures";
    const _STORAGE_TIME_WINDOW = "default_time_window";

    // read

    function getVibrateOnResponse() {
        return StorageUtil.getValue(_STORAGE_VIBRATE, true);
    }

    function getMaxStops() {
        return StorageUtil.getValue(_STORAGE_MAX_STOPS, 20);
    }

    function getMaxDepartures() {
        return StorageUtil.getValue(_STORAGE_MAX_DEPARTURES, -1);
    }

    function getDefaultTimeWindow() {
        return StorageUtil.getValue(_STORAGE_TIME_WINDOW, 30);
    }

    // write

    function setVibrateOnResponse(enabled) {
        Storage.setValue(_STORAGE_VIBRATE, enabled);
    }

    function setMaxStops(maxNo) {
        Storage.setValue(_STORAGE_MAX_STOPS, maxNo);
    }

    function setMaxDepartures(maxNo) {
        Storage.setValue(_STORAGE_MAX_DEPARTURES, maxNo);
    }

    function setDefaultTimeWindow(timeWindow) {
        Storage.setValue(_STORAGE_TIME_WINDOW, timeWindow);
    }

}
