using Toybox.Lang;
using Carbon.C14;

class Stop {

    var id;
    var name;
    var distance;

    private var _departuresTimeWindow;
    private var _response;

    // init

    function initialize(id, name, distance) {
        self.id = id;
        self.name = name;
        self.distance = distance;

        setSearching();
    }

    // set

    function setSearching() {
        _response = new StatusMessage(rez(Rez.Strings.lbl_i_departures_requesting));
    }

    function setResponse(response) {
        _response = response;

        // for each too large response, halve the time window
        if (_response instanceof ResponseError && _response.isTooLarge()) {
            _departuresTimeWindow = _departuresTimeWindow == null
                ? SettingsStorage.getDefaultTimeWindow() / 2
                : _departuresTimeWindow / 2;
        }
        else {
            // only vibrate if we are not auto-rerequesting
            vibrate("departures response");
        }
    }

    // get

    function repr() {
        return "Stop(" + id + ", " + name + ")";
    }

    function equals(object) {
        return id == object.id;
    }

    function getTimeWindow() {
        // we don't want to initialize `_departuresTimeWindow` with `SettingsStorage.getDefaultTimeWindow()`,
        // because then it wont sync when the setting is edited.
        return _departuresTimeWindow != null
            ? _departuresTimeWindow
            : SettingsStorage.getDefaultTimeWindow();
    }

    function getDataAgeMillis() {
        return hasDepartures() ? _response.getDataAgeMillis() : null;
    }

    function hasDepartures() {
        return _response instanceof DeparturesResponse;
    }

    function getModeCount() {
        return hasDepartures() ? _response.getModeCount() : 1;
    }

    function getDepartures(mode) {
        return hasDepartures() ? _response.getDepartures(mode) : null;
    }

    function getResponseError() {
        return hasDepartures() ? null : _response;
    }

}
