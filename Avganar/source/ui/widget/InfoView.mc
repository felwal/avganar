using Toybox.Graphics;
using Toybox.Math;
using Toybox.WatchUi;
using Carbon.Graphite;
using Carbon.Graphene;

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
        enableAntiAlias(dc);
        _draw(dc);
    }

    // draw

    function _draw(dc) {
        // invert colors
        Graphite.fillBackground(dc, Graphene.COLOR_WHITE);

        // inscribe a square on the circular screen
        var margin = px(5);
        var size = Math.sqrt(2) * (Graphite.getRadius(dc) - margin);
        var fonts = [ Graphics.FONT_TINY, Graphics.FONT_XTINY ];
        var justification = Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER;

        Graphite.drawTextArea(dc, Graphite.getCenterX(dc), Graphite.getCenterY(dc), size, size, fonts, _text, justification, Graphene.COLOR_BLACK);
    }

}
