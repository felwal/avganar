
(:glance)
class StopDetailRepository extends StopRepository {

    // init

    function initialize(position, storage, api) {
        StopRepository.initialize(position, storage, api);
    }

    // request

    function requestNearbyStops() {
        _api.requestNearbyStopsDetail(_position.getLatDeg(), _position.getLonDeg());
        //_api.requestNearbyStopsGlance(debugLat, debugLon);
    }

    function requestDepartures(index) {
        _api.stopCursorDetail = index;
        _api.requestDeparturesDetail();
    }

    // get

    function getStopString(stopIndex, modeIndex) {
        return getStop(stopIndex).toDetailString(modeIndex);
    }

    // set

    function enablePositionHandling() {
        setPositionHandling(Position.LOCATION_ONE_SHOT, method(:requestNearbyStops));
    }

}
