using Toybox.Lang;
using Carbon.Chem;
using Carbon.C14;

class Stop {

    var id;
    var name;
    var response;
    var deviationLevel = 0;

    hidden var _departuresTimeWindow;
    hidden var _timeStamp;

    // init

    function initialize(id, name) {
        me.id = id;
        me.name = name;
    }

    // set

    function setResponse(response_) {
        response = response_;
        _timeStamp = C14.now();

        // for each too large response_, halve the time window
        if (response instanceof ResponseError && response.isTooLarge()) {
            _departuresTimeWindow = _departuresTimeWindow == null
                ? SettingsStorage.getDefaultTimeWindow() / 2
                : _departuresTimeWindow / 2;
        }
        else {
            // only vibrate if we are not auto-rerequesting
            vibrate();
        }
    }

    function resetResponse() {
        response = null;
        _timeStamp = null;
    }

    function resetResponseError() {
        if (response instanceof ResponseError) {
            resetResponse();
        }
    }

    // get

    function getTimeWindow() {
        // we don't want to initialize `_departuresTimeWindow` with `SettingsStorage.getDefaultTimeWindow()`,
        // because then it wont sync when the setting is edited.
        return _departuresTimeWindow != null
            ? _departuresTimeWindow
            : SettingsStorage.getDefaultTimeWindow();
    }

    function getDataAgeMillis() {
        return response instanceof Lang.Array || response instanceof Lang.String
            ? C14.now().subtract(_timeStamp).value() * 1000
            : null;
    }

    function getModeCount() {
        if (response instanceof Lang.Array) {
            return response.size();
        }

        return 1;
    }

    function getModeResponse(mode) {
        if (response instanceof Lang.Array) {
            if (response.size() > 0) {
                do {
                    mode = Chem.coerceIn(mode, 0, response.size() - 1);
                    _removeDepartedDepartures(mode);
                }
                while (response.removeAll(null) && response.size() > 0);
            }

            return [ response.size() > 0
                ? response[mode]
                : rez(Rez.Strings.lbl_i_departures_none),
                mode ];
        }

        return [ response, 0 ];
    }

    function getTitleColor() {
        return deviationLevel >= 1
            ? AppColors.getDeviationColor(deviationLevel)
            : AppColors.TEXT_SECONDARY;
    }

    //

    hidden function _removeDepartedDepartures(mode) {
        if (response[mode] == null || !response[mode][0].hasDeparted()) {
            return;
        }

        var firstIndex = -1;

        for (var i = 1; i < response[mode].size(); i++) {
            // once we get the first departure that has not departed,
            // add it and everything after
            if (!response[mode][i].hasDeparted()) {
                firstIndex = i;
                break;
            }
        }

        if (firstIndex != -1) {
            response[mode] = response[mode].slice(firstIndex, null);
        }
        else {
            // add null because an ampty array is not matched with the equals() that removeAll() performes.
            response[mode] = null;
        }
    }

}
