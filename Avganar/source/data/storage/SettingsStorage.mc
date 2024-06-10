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

import Toybox.Lang;

using Toybox.Application.Storage;

//! Handles storage for user preferences.
module SettingsStorage {

    const _STORAGE_LOCATION = "use_location";
    const _STORAGE_VIBRATE = "vibrate_on_response";
    const _STORAGE_MAX_STOPS = "max_no_stops";
    const _STORAGE_MAX_DEPARTURES = "max_no_departures";
    const _STORAGE_TIME_WINDOW = "default_time_window";
    const _STORAGE_MINUTE_SYMBOL = "minute_symbol";

    var _useLocation as Boolean = true;
    var _vibrateOnResponse as Boolean = true;
    var _maxStops as Number = 15;
    var _maxDepartures as Number = -1;
    var _defaultTimeWindow as Number = 30;
    var _minuteSymbol as String = "m";

    //

    function load() as Void {
        _useLocation = StorageUtil.getValue(_STORAGE_LOCATION, _useLocation);
        _vibrateOnResponse = StorageUtil.getValue(_STORAGE_VIBRATE, _vibrateOnResponse);
        _maxStops = StorageUtil.getValue(_STORAGE_MAX_STOPS, _maxStops);
        _maxDepartures = StorageUtil.getValue(_STORAGE_MAX_DEPARTURES, _maxDepartures);
        _defaultTimeWindow = StorageUtil.getValue(_STORAGE_TIME_WINDOW, _defaultTimeWindow);
        _minuteSymbol = StorageUtil.getValue(_STORAGE_MINUTE_SYMBOL, _minuteSymbol);
    }

    // get

    function getUseLocation() as Boolean {
        return _useLocation;
    }

    function getVibrateOnResponse() as Boolean {
        return _vibrateOnResponse;
    }

    function getMaxStops() as Number {
        return _maxStops;
    }

    function getMaxDepartures() as Number {
        return _maxDepartures;
    }

    function getDefaultTimeWindow() as Number {
        return _defaultTimeWindow;
    }

    function getMinuteSymbol() as String {
        return _minuteSymbol.equals("prime") ? getString(Rez.Strings.itm_detail_departure_time_minutes_tiny)
            : _minuteSymbol.equals("m") ? getString(Rez.Strings.itm_detail_departure_time_minutes_short)
            : getString(Rez.Strings.itm_detail_departure_time_minutes_long);
    }

    // set

    function setUseLocation(enabled as Boolean) as Void {
        _useLocation = enabled;
        Storage.setValue(_STORAGE_LOCATION, enabled);
    }

    function setVibrateOnResponse(enabled as Boolean) as Void {
        _vibrateOnResponse = enabled;
        Storage.setValue(_STORAGE_VIBRATE, enabled);
    }

    function setMaxStops(maxNo as Number) as Void {
        _maxStops = maxNo;
        Storage.setValue(_STORAGE_MAX_STOPS, maxNo);
    }

    function setMaxDepartures(maxNo as Number) as Void {
        _maxDepartures = maxNo;
        Storage.setValue(_STORAGE_MAX_DEPARTURES, maxNo);
    }

    function setDefaultTimeWindow(timeWindow as Number) as Void {
        _defaultTimeWindow = timeWindow;
        Storage.setValue(_STORAGE_TIME_WINDOW, timeWindow);
    }

    function setMinuteSymbol(symbol as String) as Void {
        _minuteSymbol = symbol;
        Storage.setValue(_STORAGE_MINUTE_SYMBOL, symbol);
    }

}
