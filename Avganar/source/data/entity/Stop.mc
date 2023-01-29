using Toybox.Lang;
using Carbon.Chem;
using Carbon.C14;
using Carbon.Graphene;

class Stop {

    var name;

    hidden var _id;
    hidden var _response;
    hidden var _deviationLevel = 0;
    hidden var _departuresTimeWindow;
    hidden var _timeStamp;

    // init

    function initialize(id, name) {
        _id = id;
        me.name = name;
    }

    function equals(other) {
        return (other instanceof Stop || other instanceof StopDouble || other instanceof StopDummy)
            && other.getId() == _id && other.name.equals(name);
    }

    // set

    function setResponse(response) {
        _response = response;
        _timeStamp = C14.now();

        // for each too large response, halve the time window
        if (_response instanceof ResponseError && _response.isTooLarge()) {
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
        _response = null;
        _timeStamp = null;
    }

    function resetResponseError() {
        if (_response instanceof ResponseError) {
            resetResponse();
        }
    }

    function setDeviationLevel(level) {
        _deviationLevel = level;
    }

    // get

    function getId() {
        return _id;
    }

    function getResponse() {
        return _response;
    }

    function getTimeWindow() {
        // we don't want to initialize `_departuresTimeWindow` with `SettingsStorage.getDefaultTimeWindow()`,
        // because then it wont sync when the setting is edited.
        return _departuresTimeWindow != null
            ? _departuresTimeWindow
            : SettingsStorage.getDefaultTimeWindow();
    }

    function getDataAgeMillis() {
        return _response instanceof Lang.Array || _response instanceof Lang.String
            ? C14.now().subtract(_timeStamp).value() * 1000
            : null;
    }

    function getModeCount() {
        if (_response instanceof Lang.Array) {
            return _response.size();
        }

        return 1;
    }

    function getModeResponse(mode) {
        if (_response instanceof Lang.Array) {
            if (_response.size() > 0) {
                do {
                    mode = Chem.coerceIn(mode, 0, _response.size() - 1);
                    _removeDepartedDepartures(mode);
                }
                while (_response.removeAll(null) && _response.size() > 0);
            }

            return [ _response.size() > 0 ? _response[mode] : rez(Rez.Strings.lbl_i_departures_none),
                mode ];
        }

        return [ _response, 0 ];
    }

    function getTitleColor() {
        if (_deviationLevel >= 8) {
            return Graphene.COLOR_RED;
        }
        else if (_deviationLevel >= 6) {
            return Graphene.COLOR_VERMILION;
        }
        else if (_deviationLevel >= 4) {
            return Graphene.COLOR_AMBER;
        }
        else if (_deviationLevel >= 3) {
            return Graphene.COLOR_YELLOW;
        }
        else if (_deviationLevel >= 2) {
            return Graphene.COLOR_LT_YELLOW;
        }
        else if (_deviationLevel >= 1) {
            return Graphene.COLOR_LR_YELLOW;
        }

        return AppColors.TEXT_SECONDARY;
    }

    //

    hidden function _removeDepartedDepartures(mode) {
        if (_response[mode] == null || !_response[mode][0].hasDeparted()) {
            return;
        }

        var firstIndex = -1;

        for (var i = 1; i < _response[mode].size(); i++) {
            // once we get the first departure that has not departed,
            // add it and everything after
            if (!_response[mode][i].hasDeparted()) {
                firstIndex = i;
                break;
            }
        }

        if (firstIndex != -1) {
            _response[mode] = _response[mode].slice(firstIndex, null);
        }
        else {
            // add null because an ampty array is not matched with the equals() that removeAll() performes.
            _response[mode] = null;
        }
    }

}
