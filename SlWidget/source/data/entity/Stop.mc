using Toybox.Lang;
using Carbon.C14;

class Stop {

    var id;
    var name;
    var distance;

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

    function setSearching() {
        _response = new ResponseError(ResponseError.CODE_STATUS_REQUESTING_DEPARTURES);
    }

    // set

    function setResponse(response) {
        _response = response;
        _responseTime = C14.now();
        vibrate("departures response");
    }

    // get

    function repr() {
        return "Stop(" + id + ", " + name + ")";
    }

    function equals(object) {
        return id == object.id;
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

}
