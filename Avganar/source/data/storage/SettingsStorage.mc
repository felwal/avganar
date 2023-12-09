// This file is part of Avgånär.
//
// Avgånär is free software: you can redistribute it and/or modify it under the terms of
// the GNU General Public License as published by the Free Software Foundation,
// either version 3 of the License, or (at your option) any later version.
//
// Avgånär is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
// without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with Avgånär.
// If not, see <https://www.gnu.org/licenses/>.

using Toybox.Application.Storage;

//! Handles storage for user preferences.
module SettingsStorage {

    const _STORAGE_LOCATION = "use_location";
    const _STORAGE_VIBRATE = "vibrate_on_response";
    const _STORAGE_MAX_STOPS = "max_no_stops";
    const _STORAGE_MAX_DEPARTURES = "max_no_departures";
    const _STORAGE_TIME_WINDOW = "default_time_window";
    const _STORAGE_MINUTE_SYMBOL = "minute_symbol";

    // read

    function getUseLocation() {
        return StorageUtil.getValue(_STORAGE_LOCATION, true);
    }

    function getVibrateOnResponse() {
        return StorageUtil.getValue(_STORAGE_VIBRATE, true);
    }

    function getMaxStops() {
        return StorageUtil.getValue(_STORAGE_MAX_STOPS, 15);
    }

    function getMaxDepartures() {
        return StorageUtil.getValue(_STORAGE_MAX_DEPARTURES, -1);
    }

    function getDefaultTimeWindow() {
        return StorageUtil.getValue(_STORAGE_TIME_WINDOW, 30);
    }

    function getMinuteSymbol() {
        var value = StorageUtil.getValue(_STORAGE_MINUTE_SYMBOL, "m");

        return value.equals("prime") ? rez(Rez.Strings.itm_detail_departure_minutes_tiny)
            : value.equals("m") ? rez(Rez.Strings.itm_detail_departure_minutes_short)
            : rez(Rez.Strings.itm_detail_departure_minutes_long);
    }

    // write

    function setUseLocation(enabled) {
        Storage.setValue(_STORAGE_LOCATION, enabled);
    }

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

    function setMinuteSymbol(symbol) {
        Storage.setValue(_STORAGE_MINUTE_SYMBOL, symbol);
    }

}
