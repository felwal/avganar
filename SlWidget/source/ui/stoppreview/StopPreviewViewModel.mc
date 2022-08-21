class StopPreviewViewModel {

    private var _nearestStopsCount = 3;

    // read

    function getStopNames() {
        return NearbyStopsStorage.getNearestStopsNames(_nearestStopsCount);
    }

}
