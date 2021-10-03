
(:glance)
class StopRepository {

    protected var _position;
    protected var _storage;

    // init

    function initialize(position, storage) {
        _position = position;
        _storage = storage;

        //_storage.resetStops(); _position.setPosDeg(debugLat, debugLon);
    }

    // position

    protected function setPositionHandling(acquisitionType, onRegisterPosition) {
        // set location event listener and get last location while waiting
        _position.enableLocationEvents(acquisitionType);
        _position.registerLastKnownPosition(Activity.getActivityInfo());
        _position.onRegisterPosition = onRegisterPosition;
    }

    function disablePositionHandling() {
        _position.enableLocationEvents(Position.LOCATION_DISABLE);
        _position.onRegisterPosition = null;
    }

    function isPositionRegistered() {
        return _position.isPositionRegistered;
    }

    // storage

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

    function setPlaceholderStop() {
        if (!_storage.hasStops()) {
            var message;

            if (!_position.isPositioned()) {
                message = rez(Rez.Strings.lbl_i_stops_locating);
            }
            else {
                message = rez(Rez.Strings.lbl_i_stops_searching);
            }

            _storage.setPlaceholderStop(message);
        }
    }

}
