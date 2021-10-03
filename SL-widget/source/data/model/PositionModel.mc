using Toybox.WatchUi;
using Carbon.Chem as Chem;

(:glance)
class PositionModel {

    var onRegisterPosition = null;
    var isPositionRegistered = false;

    // position, in radians
    private var _lat = 0.0;
    private var _lon = 0.0;

    // set

    function setLatRad(lat) {
        _lat = lat;
    }

    function setLonRad(lon) {
        _lon = lon;
    }

    function setPosRad(lat, lon) {
        _lat = lat;
        _lon = lon;
    }

    function setLatDeg(lat) {
        _lat = Chem.rad(lat);
    }

    function setLonDeg(lon) {
        _lon = Chem.rad(lon);
    }

    function setPosDeg(lat, lon) {
        _lat = Chem.rad(lat);
        _lon = Chem.rad(lon);
    }

    // get

    function isPositioned() {
        return _lat != 0.0 || _lon != 0.0;
    }

    //! Get latitude in radians
    function getLatRad() {
        return _lat;
    }

    //! Get longitude in radians
    function getLonRad() {
        return _lon;
    }

    //! Get latitude in degrees
    function getLatDeg() {
        return Chem.deg(_lat);
    }

    //! Get longitude in degrees
    function getLonDeg() {
        return Chem.deg(_lon);
    }

    //

    function enableLocationEvents(acquisitionType) {
        Position.enableLocationEvents(acquisitionType, method(:registerPosition));
    }

    //! Get last location while waiting for location event
    //! @param info Activity info
    function registerLastKnownPosition(activityInfo) {
        var loc = activityInfo.currentLocation;
        if (loc != null) {
            _lat = loc.toRadians()[0].toDouble();
            _lon = loc.toRadians()[1].toDouble();
        }

        if (onRegisterPosition != null) {
            onRegisterPosition.invoke();
        }
    }

    //! Location event listener delegation
    function registerPosition(positionInfo) {
        _lat = positionInfo.position.toRadians()[0].toDouble();
        _lon = positionInfo.position.toRadians()[1].toDouble();

        if (onRegisterPosition != null) {
            onRegisterPosition.invoke();
        }
        isPositionRegistered = true;

        WatchUi.requestUpdate();
    }

}
