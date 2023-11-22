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

//! Use the StopDummy to compare / search for stops
//! by only name and id.
class StopDummy {

    var name;

    hidden var _id;

    // init

    function initialize(id, name) {
        _id = id;
        me.name = name;
    }

    function equals(other) {
        return (other instanceof Stop || other instanceof StopDouble || other instanceof StopDummy)
            && other.getId() == _id && other.name.equals(name);
    }

    //

    function getId() {
        return _id;
    }

}
