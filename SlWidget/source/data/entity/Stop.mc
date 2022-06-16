using Toybox.Lang;

(:glance)
class Stop {

    var id;
    var name;
    var distance;

    private var _response;

    // init

    function initialize(id, name, distance) {
        self.id = id;
        self.name = name;
        self.distance = distance;

        setSearching();
    }

    function setSearching() {
        _response = new ResponseError(ResponseError.ERROR_CODE_REQUESTING_DEPARTURES);
    }

    // set

    function setResponse(response) {
        _response = response;
    }

    // get

    function repr() {
        return "Stop(" + id + ", " + name + ")";
    }

    function equals(object) {
        return id == object.id;
    }

    function hasResponseError() {
        return _response instanceof ResponseError;
    }

    function getModeCount() {
        return hasResponseError() ? null : _response.size();
    }

    function getDepartureCount(mode) {
        if (hasResponseError()) {
            return null;
        }

        if (mode < 0 || mode >= _response.size()) {
            Log.w("getDepartureCount 'mode' (" + mode + ") out of range [0," + _response.size() + "]; returning 0");
            return 0;
        }
        else if (!(_response[mode] instanceof Lang.Array)) {
            Log.w("departures[" + mode + "] (not Array): " + _response[mode] + "; returning 0");
            return 0;
        }
        return _response[mode].size();
    }

    function getDepartures(mode) {
        if (hasResponseError()) {
            return null;
        }

        if (mode >= 0 && mode < _response.size()) {
            return _response[mode];
        }
        else {
            Log.w("getDepartures 'mode' (" + mode + ") out of range [0," + _response.size() + "]; returning []");
            return [];
        }
    }

    function getAllDepartures() {
        return hasResponseError() ? null : _response;
    }

    function getResponseError() {
        return hasResponseError() ? _response : null;
    }

    function hasDepartures() {
        return !hasResponseError() && _response.size() > 0 && _response[0].size() > 0;
    }

    function getFirstDeparture() {
        if (hasResponseError()) {
            return null;
        }

        Log.d("departures shape: (" + _response.size() + ", " + (_response.size() > 0 ? _response[0].size() : "") + ")");
        return hasDepartures() ? _response[0][0] : null;
    }

}
