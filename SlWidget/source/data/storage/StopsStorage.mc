class StopsStorage {

    protected function buildStops(ids, names) {
        var stops = [];

        for (var i = 0; i < ids.size() && i < names.size(); i++) {
            var stop = new Stop(ids[i], names[i], null);
            stops.add(stop);
        }

        return stops;
    }

}
