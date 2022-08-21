(:glance)
class StopGlanceViewModel {

    private var _nearestStopName;

    // init

    function initialize() {
        _nearestStopName = NearbyStopsStorage.getNearestStopName();
    }

    // read

    function getTitle() {
        return _nearestStopName != null ? rez(Rez.Strings.lbl_glance_title) : rez(Rez.Strings.app_name);
    }

    function getCaption() {
        return _nearestStopName != null ? _nearestStopName : rez(Rez.Strings.lbl_glance_caption_no_stops);
    }

}
