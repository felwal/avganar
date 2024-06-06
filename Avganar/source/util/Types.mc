import Toybox.Lang;

typedef StopType as Stop or StopDouble or StopDummy; // TODO: should probably not include dummy
typedef ResponseWithDepartures as Array<Departure> or ResponseError or Null;
typedef ResponseWithStops as Array<StopType> or ResponseError or String or Null;

typedef JsonValue as String or Number or Float or Boolean or JsonArray or JsonDict or Null;
typedef JsonDict as Dictionary<String, JsonValue>;
typedef JsonArray as Array<JsonDict>;

typedef LatLon as [Double, Double];
