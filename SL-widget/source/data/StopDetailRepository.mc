
(:glance)
class StopDetailRepository extends StopRepository {

    private var _getStopCursorMethod;

    // init

    function initialize(position, storage) {
        StopRepository.initialize(position, storage);
    }

    // api

    function requestNearbyStops() {
        var stopCursor = _getStopCursorMethod.invoke();
        SlApi.detailRequester(_storage, stopCursor).requestNearbyStops(_position.getLatDeg(), _position.getLonDeg());
        //_api.requestNearbyStops(debugLat, debugLon);
    }

    function requestDepartures(index) {
        SlApi.detailRequester(_storage, index).requestDepartures();
    }

    // position

    function enablePositionHandling(getStopCursorMethod) {
        _getStopCursorMethod = getStopCursorMethod;
        setPositionHandling(Position.LOCATION_ONE_SHOT, method(:requestNearbyStops));
    }

    // storage

    function getStopString(stopIndex, modeIndex) {
        return getStop(stopIndex).toDetailString(modeIndex);
    }

}
