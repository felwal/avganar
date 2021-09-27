import Toybox.Lang;
import Toybox.Graphics;

using Carbon.Graphene;

(:glance)
class Journey {

    private static const _MODE_METRO = "METRO";
    private static const _MODE_BUS = "BUS";
    private static const _MODE_TRAIN = "TRAIN";
    private static const _MODE_TRAM = "TRAM";
    private static const _MODE_SHIP = "SHIP";
    private static const _MODE_NONE = "NONE";

    private var _mode as String;
    private var _line as String;
    private var _destination as String;
    private var _direction as Number;
    private var _displayTime as String;

    //

    function initialize(mode as String, line as String, destination as String, direction as Number,
            displayTime as String) as Void {
        _mode = mode;
        _line = line;
        _destination = destination;
        _direction = direction;
        _displayTime = displayTime;

    }

    static function placeholder(msg as String) as Journey {
        return new Journey(_MODE_NONE, "", "", "", msg);
    }

    //

    function toString() as String {
        return _displayTime + " " + _line + " " + _destination;
    }

    function getColor() as ColorType {
        switch (_mode) {
            case _MODE_METRO: return Graphene.COLOR_DK_GREEN;
            case _MODE_BUS: return Graphene.COLOR_RED;
            case _MODE_TRAIN: return Graphene.COLOR_MAGENTA;
            case _MODE_TRAM: return Graphene.COLOR_AMBER;
            case _MODE_SHIP: return Graphene.COLOR_CAPRI;
            case _MODE_NONE: return Graphene.COLOR_BLACK;
            default: return Graphene.COLOR_LT_GRAY;
        }
    }

}
