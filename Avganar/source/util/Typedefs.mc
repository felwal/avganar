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

import Toybox.Graphics;
import Toybox.Lang;

typedef StopType as Stop or StopDouble;
typedef StopsResponse as Array<StopType> or ResponseError or Null;
typedef DeparturesResponse as Array<Departure> or ResponseError or Null;

typedef JsonValue as String or Number or Float or Boolean or JsonArray or JsonDict or Null;
typedef JsonDict as Dictionary<String, JsonValue>;
typedef JsonArray as Array<JsonValue>;

typedef LatLon as [Double, Double];
typedef ColorTheme as [ColorType, ColorType, ColorType, ColorType];
