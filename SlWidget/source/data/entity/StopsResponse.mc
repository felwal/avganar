class StopsResponse {

    private var _stops;

    function initialize(stops) {
        _stops = stops;
    }

    //

    function getStops() {
        return _stops;
    }

    function hasStops() {
        return _stops.size() > 0;
    }

    function getStop(index) {
        return ArrCompat.coerceGet(_stops, index);
    }

    function getStopCount() {
        return _stops.size();
    }

}
