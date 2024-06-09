// This file is part of Avgånär.
//
// Avgånär is free software: you can redistribute it and/or modify it under the terms of
// the GNU General Public License as published by the Free Software Foundation,
// either version 3 of the License, or (at your option) any later version.
//
// Avgånär is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
// without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with Avgånär.
// If not, see <https://www.gnu.org/licenses/>.

import Toybox.Lang;

using Toybox.Activity;
using Toybox.Math;
using Toybox.Position;
using Toybox.WatchUi;

//! The Footprint module provides extended position functionality
(:glance)
module Footprint {

    var onRegisterPosition as Method? = null;
    var isPositionRegistered = false;

    // position, in radians
    var _latLon as LatLon = [ 0.0d, 0.0d ];

    // set

    function setPosLoc(positionLocation as Position.Location?) as Void {
        if (positionLocation != null) {
            _latLon = positionLocation.toRadians();
        }
    }

    // get

    function isPositioned() as Boolean {
        return _latLon != [ 0.0d, 0.0d ];
    }

    function getLatLonRad() as LatLon {
        return _latLon;
    }

    function getLatLonDeg() as LatLon {
        return [ MathUtil.deg(_latLon[0]), MathUtil.deg(_latLon[1]) ];
    }

    function distanceTo(latLon as LatLon) as Float {
        return distanceBetween(latLon, _latLon);
    }

    // static

    //! Radians to meters
    function distanceBetween(pos1 as LatLon, pos2 as LatLon) as Float {
        var R = 6371000;

        var phi1 = pos1[0] - Math.PI / 2;
        var phi2 = pos2[0] - Math.PI / 2;

        var x1 = R * Math.sin(phi1) * Math.cos(pos1[1]);
        var y1 = R * Math.sin(phi1) * Math.sin(pos1[1]);
        var z1 = R * Math.cos(phi1);

        var x2 = R * Math.sin(phi2) * Math.cos(pos2[1]);
        var y2 = R * Math.sin(phi2) * Math.sin(pos2[1]);
        var z2 = R * Math.cos(phi2);

        var dx = x2 - x1;
        var dy = y2 - y1;
        var dz = z2 - z1;

        var distance = Math.sqrt(dx * dx + dy * dy + dz * dz).toFloat();

        return distance;
    }

    // registration

    function enableLocationEvents(continuous as Boolean) as Void {
        Position.enableLocationEvents(continuous ? Position.LOCATION_CONTINUOUS : Position.LOCATION_ONE_SHOT,
            new Lang.Method(Footprint, :registerPosition));
    }

    function disableLocationEvents() as Void {
        onRegisterPosition = null;
        Position.enableLocationEvents(Position.LOCATION_DISABLE, null);
    }

    //! Get last location while waiting for location event
    //! @param info Activity info
    function registerLastKnownPosition() as Void {
        var activityInfo = Activity.getActivityInfo();
        setPosLoc(activityInfo.currentLocation);

        if (onRegisterPosition != null) {
            onRegisterPosition.invoke();
        }
    }

    //! Location event listener delegation
    function registerPosition(positionInfo as Position.Info) as Void {
        setPosLoc(positionInfo.position);
        isPositionRegistered = true;

        if (onRegisterPosition != null) {
            onRegisterPosition.invoke();
        }
    }

}
