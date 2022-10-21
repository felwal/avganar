class StopFactory {

    private var _favStorage;

    function initialize(favStorage) {
        _favStorage = favStorage;
    }

    function createStop(id, name, distance, existingNearbyStop) {
        var fav = _favStorage.getFavorite(id);
        var stop;

        // if both are non-null they refer to the same object
        if (fav != null) {
            stop = fav;
        }
        else if (existingNearbyStop != null) {
            stop = existingNearbyStop;
        }
        else {
            return new Stop(id, name, distance);
        }

        stop.name = name;
        stop.distance = distance;

        return stop;
    }

}
