using Toybox.Application;

(:glance)
class Repository {

    private var _sl;
    private var _pos;

    //

    function initialize(sl, pos) {
        _sl = sl;
        _pos = pos;
    }

    // requst

    function requestNearbyStopsGlance() {
        _sl.requestNearbyStopsGlance(_pos.getLatDeg(), _pos.getLonDeg());
    }

    function requestNearbyStopsDetail() {
        _sl.requestNearbyStopsDetail(_pos.getLatDeg(), _pos.getLonDeg());
    }

    // read

    function getStopGlanceString(index) {
        return getStop(index).toGlanceString();
    }

    function getStopViewString(index) {
        return getStop(index).toViewString();
    }

    function getStop(index) {
        return _sl.stops[index];
    }

    // write

    function setPositionHandling(acquisitionType) {
        // set location event listener and get last location while waiting
        _pos.enableLocationEvents(acquisitionType);
        _pos.registerLastKnownPosition(Activity.getActivityInfo());
    }

    function addPlaceholderStops() {
        for (var i = 0; i < _sl.stops.size(); i++) {
            _sl.stops[i] = new Stop(-1, Application.loadResource(Rez.Strings.stops_searching));
        }
    }

}
