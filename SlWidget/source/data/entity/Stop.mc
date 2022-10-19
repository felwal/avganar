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

    function toString() {
        return id.toString();
    }

    // set

    function setSearching() {
        _response = new ResponseError(ResponseError.CODE_STATUS_REQUESTING_DEPARTURES);
    }

    function setResponse(response) {
        _response = response;

        // for each too large response, halve the time window
        if (hasResponseError() && _response.isTooLarge()) {
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

    function hasResponseError() {
        return _response instanceof ResponseError;
    }

    function getModeCount() {
        return hasDepartures() ? _response.getModeCount() : null;
    }

    function getDepartures(mode) {
        return hasDepartures() ? _response.getDepartures(mode) : null;
    }

    function getResponseError() {
        return hasResponseError() ? _response : null;
    }

}
