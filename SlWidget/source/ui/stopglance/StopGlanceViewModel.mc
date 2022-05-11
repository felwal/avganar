
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
        return stop == null ? rez(Rez.Strings.lbl_glance_title_no_stops) : stop.name;
    }

}
