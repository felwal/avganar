(:glance)
class StopGlanceViewModel {

    private var _storage;

    // init

    function initialize(storage) {
        _storage = storage;
    }

    // read

    function getTitle() {
        return _storage.hasStops() ? rez(Rez.Strings.lbl_glance_title) : rez(Rez.Strings.app_name);
    }

    function getCaption() {
        var stop = _storage.getStop(0);
        return stop != null ? stop.name : rez(Rez.Strings.lbl_glance_caption_no_stops);
    }

}
