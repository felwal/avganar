class StopFactory {

    private var _favStorage;

    function initialize(favStorage) {
        _favStorage = favStorage;
    }

    function createStop(id, name, distance) {
        var fav = _favStorage.getFavorite(id);

        if (fav != null) {
            fav.name = name;
            fav.distance = distance;
            return fav;
        }

        return new Stop(id, name, distance);
    }

}
