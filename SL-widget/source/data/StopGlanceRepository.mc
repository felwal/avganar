
(:glance)
class StopGlanceRepository extends StopRepository {

    // init

    function initialize(position, storage, api) {
        StopRepository.initialize(position, storage, api);
    }

    // request

    function requestNearbyStops() {
        _api.requestNearbyStopsGlance(_position.getLatDeg(), _position.getLonDeg());
        //_api.requestNearbyStopsGlance(debugLat, debugLon);
    }

    function requestDepartures() {
        _api.requestDeparturesGlance();
    }

    // get

    function getStopString(stopIndex) {
        return getStop(stopIndex).toGlanceString();
    }

    // set

    function enablePositionHandling() {
        setPositionHandling(Position.LOCATION_ONE_SHOT, method(:requestNearbyStops));
    }

}
