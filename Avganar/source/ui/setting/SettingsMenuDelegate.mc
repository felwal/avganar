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

using Toybox.WatchUi;

//! The StopList settings menu, handling user preferences.
class SettingsMenuDelegate extends WatchUi.Menu2InputDelegate {

    static const ITEM_LOCATION = :useLocation;
    static const ITEM_VIBRATE = :vibrateOnResponse;
    static const ITEM_MAX_STOPS = :maxNoStops;
    static const ITEM_MAX_DEPARTURES = :maxNoDepartures;
    static const ITEM_TIME_WINDOW = :defaultTimeWindow;
    static const ITEM_MINUTE_SYMBOL = :minuteSymbol;

    hidden var _menu;

    // init

    function initialize() {
        Menu2InputDelegate.initialize();
        _addItems();
    }

    hidden function _addItems() {
        _menu = new WatchUi.Menu2({ :title => rez(Rez.Strings.lbl_settings_title) });

        // use location
        _menu.addItem(new WatchUi.ToggleMenuItem(
            rez(Rez.Strings.itm_settings_location), { :enabled => "On", :disabled => "Off" },
            ITEM_LOCATION, SettingsStorage.getUseLocation(), {}
        ));

        // vibrate on response
        _menu.addItem(new WatchUi.ToggleMenuItem(
            rez(Rez.Strings.itm_settings_vibrate), { :enabled => "On", :disabled => "Off" },
            ITEM_VIBRATE, SettingsStorage.getVibrateOnResponse(), {}
        ));

        // max stops
        _menu.addItem(new WatchUi.MenuItem(
            rez(Rez.Strings.itm_settings_max_stops), SettingsStorage.getMaxStops().toString(),
            ITEM_MAX_STOPS, {}
        ));

        // max departures
        _menu.addItem(new WatchUi.MenuItem(
            rez(Rez.Strings.itm_settings_max_departures),
            SettingsStorage.getMaxDepartures() == -1
                ? rez(Rez.Strings.itm_settings_max_departures_unlimited)
                : SettingsStorage.getMaxDepartures().toString(),
            ITEM_MAX_DEPARTURES, {}
        ));

        // default time window
        _menu.addItem(new WatchUi.MenuItem(
            rez(Rez.Strings.itm_settings_time_window), SettingsStorage.getDefaultTimeWindow() + " min",
            ITEM_TIME_WINDOW, {}
        ));

        // minute symbol
        _menu.addItem(new WatchUi.MenuItem(
            rez(Rez.Strings.itm_settings_minute_symbol), SettingsStorage.getMinuteSymbol(),
            ITEM_MINUTE_SYMBOL, {}
        ));
    }

    function push(transition) {
        WatchUi.pushView(_menu, me, transition);
    }

    // override Menu2InputDelegate

    function onSelect(item) {
        var id = item.getId();

        if (id == ITEM_LOCATION) {
            SettingsStorage.setUseLocation(item.isEnabled());
            return;
        }
        else if (id == ITEM_VIBRATE) {
            SettingsStorage.setVibrateOnResponse(item.isEnabled());
            return;
        }
        else if (id == ITEM_MAX_STOPS) {
            var title = rez(Rez.Strings.itm_settings_max_stops);
            var values = [ 5, 10, 15, 20 ];
            var focus = values.indexOf(SettingsStorage.getMaxStops());
            new RadioMenuDelegate(title, null, values, focus, method(:onMaxStopsSelect)).push();
            return;
        }
        else if (id == ITEM_MAX_DEPARTURES) {
            var title = rez(Rez.Strings.itm_settings_max_departures);
            var labels = [ "10", "20", "40", "60", rez(Rez.Strings.itm_settings_max_departures_unlimited) ];
            var values = [ 10, 20, 40, 60, -1 ];
            var focus = values.indexOf(SettingsStorage.getMaxDepartures());
            new RadioMenuDelegate(title, labels, values, focus, method(:onMaxDeparturesSelect)).push();
            return;
        }
        else if (id == ITEM_TIME_WINDOW) {
            var title = rez(Rez.Strings.itm_settings_time_window);
            var labels = [ "5 min", "15 min", "30 min", "45 min", "60 min" ];
            var values = [ 5, 15, 30, 45, 60 ];
            var focus = values.indexOf(SettingsStorage.getDefaultTimeWindow());
            new RadioMenuDelegate(title, labels, values, focus, method(:onTimeWindowSelect)).push();
            return;
        }
        else if (id == ITEM_MINUTE_SYMBOL) {
            var title = rez(Rez.Strings.itm_settings_minute_symbol);
            var labels = [
                rez(Rez.Strings.itm_detail_departure_minutes_long),
                rez(Rez.Strings.itm_detail_departure_minutes_short),
                rez(Rez.Strings.itm_detail_departure_minutes_tiny) ];
            var values = [ "min", "m", "prime" ];
            var focus = labels.indexOf(SettingsStorage.getMinuteSymbol());
            new RadioMenuDelegate(title, labels, values, focus, method(:onMinuteSymbolSelect)).push();
            return;
        }
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }

    //

    function onMaxStopsSelect(value) {
        SettingsStorage.setMaxStops(value);

        var item = _menu.getItem(_menu.findItemById(ITEM_MAX_STOPS));
        item.setSubLabel(value.toString());
    }

    function onMaxDeparturesSelect(value) {
        SettingsStorage.setMaxDepartures(value);

        var item = _menu.getItem(_menu.findItemById(ITEM_MAX_DEPARTURES));
        item.setSubLabel(value == -1
            ? rez(Rez.Strings.itm_settings_max_departures_unlimited)
            : value.toString());
    }

    function onTimeWindowSelect(value) {
        SettingsStorage.setDefaultTimeWindow(value);

        var item = _menu.getItem(_menu.findItemById(ITEM_TIME_WINDOW));
        item.setSubLabel(value + " min");
    }

    function onMinuteSymbolSelect(value) {
        SettingsStorage.setMinuteSymbol(value);

        var item = _menu.getItem(_menu.findItemById(ITEM_MINUTE_SYMBOL));
        item.setSubLabel(SettingsStorage.getMinuteSymbol());
    }

}
