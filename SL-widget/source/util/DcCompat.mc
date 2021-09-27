import Toybox.Lang;
import Toybox.Graphics;

using Toybox.Math;
using Carbon.Graphite;
using Carbon.Graphene;
using Carbon.Chem;

(:glance)
class DcCompat {

    var dc as Dc;

    var w as Number;
    var h as Number;
    var cx as Number;
    var cy as Number;
    var r as Number or Null = null;

    //

    function initialize(dc as Dc) {
        self.dc = dc;
        w = dc.getWidth();
        h = dc.getHeight();
        cx = w / 2;
        cy = h / 2;

        if (cx == cy) {
            r = cx;
        }
    }

    // color

    function setColor(foreground as Number) {
        dc.setColor(foreground, Graphene.COLOR_BLACK);
    }

    function resetColor() {
        setColor(Graphene.COLOR_WHITE);
    }

    // draw text

    function drawGlanceTitle(text as String) as Void {
        Graphite.resetColor(dc);
        dc.drawText(0, 0, Graphene.FONT_XTINY, text, Graphics.TEXT_JUSTIFY_LEFT);
    }

    function drawViewTitle(text as String) as Void {
        Graphite.resetColor(dc);
        dc.drawText(w / 2, 27, Graphene.FONT_TINY, text.toUpper(), Graphics.TEXT_JUSTIFY_CENTER);
    }

    // fill shape

    //! Fill a rectangle around a point
    public function fillRectangleCentered(xCenter as Numeric, yCenter as Numeric, width as Numeric,
            height as Numeric) as Void {
        dc.fillRectangle(xCenter - width / 2, yCenter - height / 2, width, height);
    }

    // stroke shape

    //! Fill a circle with an outside stroke
    function strokeCircle(x as Numeric, y as Numeric, r as Numeric, strokeWidth as Numeric, fillColor as ColorType,
            strokeColor as ColorType) as Void {
        // stroke
        setColor(strokeColor);
        dc.fillCircle(x, y, r + strokeWidth);

        // fill
        setColor(fillColor);
        dc.fillCircle(x, y, r);
    }

    //! Fill a rectangle with an outside stroke
    function strokeRectangle(x as Numeric, y as Numeric, width as Numeric, height as Numeric, strokeWidth as Numeric,
            fillColor as ColorType, strokeColor as ColorType) as Void {
        // stroke
        setColor(strokeColor);
        dc.fillRectangle(x - strokeWidth, y - strokeWidth, width + 2 * strokeWidth, height + 2 * strokeWidth);

        // fill
        setColor(fillColor);
        dc.fillRectangle(x, y, width, height);
    }

    //! Fill a rectangle with an outside stroke around a point
    function strokeRectangleCentered(xCenter as Numeric, yCenter as Numeric, width as Numeric, height as Numeric,
            strokeWidth as Numeric, fillColor as ColorType, strokeColor as ColorType) as Void {
        // stroke
        setColor(strokeColor);
        fillRectangleCentered(xCenter, yCenter, width + 2 * strokeWidth, height);

        // fill
        setColor(dc, fillColor);
        fillRectangleCentered(xCenter, yCenter, width, height);
    }

    // widget

    function drawVerticalPageIndicator(length as Number, index as Number) as Void {
        if (length <= 1) {
            return;
        }

        var deltaDeg = 7;
        var minDeg = 180 - deltaDeg * (length - 1) / 2f;
        var maxDeg = 180 + deltaDeg * (length - 1) / 2f;
        var amp = r - 8;
        var radius = 2;
        var stroke = 2;
        var bgStroke = 2;

        for (var i = 0; i < length; i++) {
            var deg = minDeg + i * deltaDeg;
            var rad = Chem.rad(deg);
            var pos = Chem.polarPos(amp, rad, cx, cy);

            // bg
            setColor(Graphene.COLOR_BLACK);
            dc.fillCircle(pos[0], pos[1], radius + stroke + bgStroke);

            // circle
            if (i == index) {
                resetColor();
                dc.fillCircle(pos[0], pos[1], radius + stroke);
            }
            else {
                strokeCircle(pos[0], pos[1], radius, stroke, Graphene.COLOR_BLACK, Graphene.COLOR_LT_GRAY);
            }

        }
    }

}

