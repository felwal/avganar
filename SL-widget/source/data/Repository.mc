
class Repository {

    protected var _position;
    protected var _storage;

    private var _getStopCursorMethod;

    // init

    function initialize(position, storage) {
        _position = position;
        _storage = storage;
    }

    // api

    function requestNearbyStops() {
        var stopCursor = _getStopCursorMethod.invoke();
        SlApi.detailRequester(_storage, stopCursor, false).requestNearbyStops(_position.getLatDeg(), _position.getLonDeg());
    }

    function requestDepartures(index) {
        SlApi.detailRequester(_storage, index, false).requestDepartures();
    }

    function requestFewerDepartures(index) {
        SlApi.detailRequester(_storage, index, true).requestDepartures();
    }

    // position

    function enablePositionHandling(getStopCursorMethod) {
        _getStopCursorMethod = getStopCursorMethod;
        _setPositionHandling(Position.LOCATION_ONE_SHOT, method(:requestNearbyStops));
    }

    private function _setPositionHandling(acquisitionType, onRegisterPosition) {
        // set location event listener and get last location while waiting
        _position.onRegisterPosition = onRegisterPosition;
        _position.enableLocationEvents(acquisitionType);
        _position.registerLastKnownPosition(Activity.getActivityInfo());
    }

    function disablePositionHandling() {
        _position.enableLocationEvents(Position.LOCATION_DISABLE);
        _position.onRegisterPosition = null;
    }

    function isPositionRegistered() {
        return _position.isPositionRegistered;
    }

    // storage

    function getStopString(stopIndex, modeIndex) {
        var stop = getStop(stopIndex);
        if (stop != null) {
            return stop.toDetailString(modeIndex);
        }
        return rez(Rez.Strings.lbl_i_stops_none_found);
    }

    function getStop(index) {
        return _storage.getStop(index);
    }

    function getStopCount() {
        return _storage.getStopCount();
    }

    function getModeCount(stopIndex) {
        return getStop(stopIndex).getModeCount();
    }

    function getStopIndexRotated(index, amount) {
        return mod(index + amount, getStopCount());
    }

    function getModeIndexRotated(stopIndex, modeIndex) {
        return mod(modeIndex + 1, getModeCount(stopIndex));
    }

    function setStopsSearhing() {
        if (!_storage.hasStops()) {
            var message;

            if (!_position.isPositioned()) {
                message = rez(Rez.Strings.lbl_i_stops_locating);
            }
            else {
                message = rez(Rez.Strings.lbl_i_stops_searching);
            }

            _storage.setPlaceholderStop(null, message);
        }
    }

    function setDeparturesSearching(stopIndex) {
        _storage.setPlaceholderDeparture(stopIndex, null, rez(Rez.Strings.lbl_i_departures_searching));
    }

}
