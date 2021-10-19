
(:glance)
class StopGlanceRepository extends StopRepository {

    private var _api;

    // init

    function initialize(position, storage) {
        StopRepository.initialize(position, storage);
        _api = SlApi.glanceRequester(storage);
    }

    // api

    function requestNearbyStops() {
        _api.requestNearbyStops(_position.getLatDeg(), _position.getLonDeg());
        //_api.requestNearbyStops(debugLat, debugLon);
    }

    function requestDepartures() {
        _api.requestDepartures();
    }

    // position

    function enablePositionHandling() {
        setPositionHandling(Position.LOCATION_ONE_SHOT, method(:requestNearbyStops));
    }

    // storage

    function loadStorage() {
        _storage.loadGlance();
    }

    function getStopString(stopIndex) {
        var stop = getStop(stopIndex);
        if (stop != null) {
            return stop.toGlanceString();
        }
        return rez(Rez.Strings.lbl_i_stops_none_found);
    }

}
