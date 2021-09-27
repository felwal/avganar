import Toybox.Lang;

using Toybox.Activity;
using Toybox.Position;
using Carbon.Chem as Chem;

(:glance)
class PositionModel {

    var onRegisterPosition as Method = null;

    // position, in radians
    private var _lat as Double = 0.0;
    private var _lon as Double = 0.0;

    // set

    function setLatRad(lat as Double) as Void {
        _lat = lat;
    }

    function setLonRad(lon as Double) as Void {
        _lon = lon;
    }

    function setPosRad(lat as Double, lon as Double) as Void {
        _lat = lat;
        _lon = lon;
    }

    function setLatDeg(lat as Double) as Void {
        _lat = Chem.rad(lat);
    }

    function setLonDeg(lon as Double) as Void {
        _lon = Chem.rad(lon);
    }

    function setPosDeg(lat as Double, lon as Double) as Void {
        _lat = Chem.rad(lat);
        _lon = Chem.rad(lon);
    }

    // get

    function isPositioned() as Boolean {
        return _lat != 0.0 || _lon != 0.0;
    }

    //! Get latitude in radians
    function getLatRad() as Double {
        return _lat;
    }

    //! Get longitude in radians
    function getLonRad() as Double {
        return _lon;
    }

    //! Get latitude in degrees
    function getLatDeg() as Double {
        return Chem.deg(_lat);
    }

    //! Get longitude in degrees
    function getLonDeg() as Double {
        return Chem.deg(_lon);
    }

    //

    function enableLocationEvents(acquisitionType as Number) as Void {
        Position.enableLocationEvents(acquisitionType, method(:registerPosition));
    }

    //! Get last location while waiting for location event
    //! @param info Activity info
    function registerLastKnownPosition(info as Activity.Info) as Void {
        var loc = info.currentLocation;
        if (loc != null) {
            _lat = loc.toRadians()[0].toDouble();
            _lon = loc.toRadians()[1].toDouble();
        }

        if (onRegisterPosition != null) {
            onRegisterPosition.invoke();
        }
    }

    //! Location event listener delegation
    function registerPosition(info as Position.Info) as Void {
        _lat = info.position.toRadians()[0].toDouble();
        _lon = info.position.toRadians()[1].toDouble();

        if (onRegisterPosition != null) {
            onRegisterPosition.invoke();
        }
    }

}
