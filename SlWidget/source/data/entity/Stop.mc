using Toybox.Lang;
using Carbon.C14;

class Stop {

    private static const _DEFAULT_TIME_WINDOW = 60; // max 60 (minutes)

    var id;
    var name;
    var distance;

    private var _departuresTimeWindow = _DEFAULT_TIME_WINDOW;
    private var _response;
    private var _responseTime;

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
        _responseTime = C14.now();

        // for each too large response, halve the time window
        if (hasResponseError() && _response.isTooLarge()) {
            _departuresTimeWindow /= 2;
        }

        vibrate("departures response");
    }

    private function _removeDepartedDepartures(mode) {
        var departures = _response[mode];
        var firstIndex = -1;

        if (!departures[0].hasDeparted()) {
            return;
        }

        for (var i = 1; i < departures.size(); i++) {
            // once we get the first departure that has not departed,
            // add it and everything after
            if (!departures[i].hasDeparted()) {
                firstIndex = i;
                break;
            }
        }

        if (firstIndex != -1) {
            _response[mode] = departures.slice(firstIndex, null);
        }
        else {
            _response[mode] = [];
            // TODO: set searching
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
        return _departuresTimeWindow;
    }

    function getDataAgeMillis() {
        return _responseTime == null ? null : C14.now().subtract(_responseTime).value() * 1000;
    }

    function hasResponseError() {
        return _response instanceof ResponseError;
    }

    function getModeCount() {
        return hasResponseError() ? null : _response.size();
    }

    function getDepartures(mode) {
        if (hasResponseError()) {
            return null;
        }

        if (mode < 0 || mode >= _response.size()) {
            Log.w("getDepartures 'mode' (" + mode + ") out of range [0," + _response.size() + "]; returning []");
            return [];
        }

        _removeDepartedDepartures(mode);
        return _response[mode];
    }

    function getResponseError() {
        return hasResponseError() ? _response : null;
    }

}
