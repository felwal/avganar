using Toybox.Graphics;
using Toybox.Math;
using Toybox.WatchUi;

class InfoView extends WatchUi.View {

    hidden var _text;

    // init

    function initialize(text) {
        View.initialize();
        _text = text;
    }

    // override View

    function onUpdate(dc) {
        View.onUpdate(dc);

        // draw
        Graphite.enableAntiAlias(dc);
        _draw(dc);
    }

    // draw

    function _draw(dc) {
        Graphite.fillBackground(dc, Graphene.COLOR_WHITE);
        Graphite.fillTextArea(dc, _text, Graphene.COLOR_BLACK);
    }

}
