class StopDouble {

    var name;

    hidden var _stop;

    // init

    function initialize(stop, name) {
        _stop = stop;
        me.name = name;
    }

    function equals(other) {
        return (other instanceof Stop || other instanceof StopDouble || other instanceof StopDummy)
            && other.getId() == getId() && other.name.equals(name);
    }

    // set

    function setResponse(response) {
        _stop.setResponse(response);
    }

    function resetResponse() {
        _stop.resetResponse();
    }

    function resetResponseError() {
        _stop.resetResponseError();
    }

    function setDeviationLevel(level) {
        _stop.setDeviationLevel(level);
    }

    // get

    function getId() {
        return _stop.getId();
    }

    function getResponse() {
        return _stop.getResponse();
    }

    function getTimeWindow() {
        return _stop.getTimeWindow();
    }

    function getDataAgeMillis() {
        return _stop.getDataAgeMillis();
    }

    function getModeCount() {
        return _stop.getModeCount();
    }

    function getModeResponse(mode) {
        return _stop.getModeResponse(mode);
    }

    function getTitleColor() {
        return _stop.getTitleColor();
    }

}