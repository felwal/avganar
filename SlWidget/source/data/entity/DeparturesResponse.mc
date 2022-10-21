using Carbon.C14;

class DeparturesResponse {

    private var _departures;
    private var _timeStamp;

    function initialize(departures) {
        _departures = departures;
        _timeStamp = C14.now();
    }

    //

    function getDepartures(mode) {
        _removeDepartedDepartures(mode);
        return ArrUtil.coerceGet(_departures, mode);
    }

    function getDataAgeMillis() {
        return C14.now().subtract(_timeStamp).value() * 1000;
    }

     function getModeCount() {
        return _departures.size();
    }

    //

    private function _removeDepartedDepartures(mode) {
        var firstIndex = -1;

        if (!_departures[mode][0].hasDeparted()) {
            return;
        }

        for (var i = 1; i < _departures[mode].size(); i++) {
            // once we get the first departure that has not departed,
            // add it and everything after
            if (!_departures[mode][i].hasDeparted()) {
                firstIndex = i;
                break;
            }
        }

        if (firstIndex != -1) {
            _departures[mode] = _departures[mode].slice(firstIndex, null);
        }
        else {
            _departures[mode] = [];
        }
    }

}
