
(:glance)
class StopGlanceViewModel {

    private var _storage;

    // init

    function initialize(storage) {
        _storage = storage;
    }

    //

    function getClosestStopName() {
        var stop = _storage.getStop(0);
        return stop == null ? "No stops nearby" : stop.name;
    }

}
