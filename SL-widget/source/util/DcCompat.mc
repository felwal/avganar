using Toybox.Math;
using Carbon.Graphene;
using Carbon.Chem;

(:glance)
class DcCompat {

    enum {
        DIR_LEFT,
        DIR_RIGHT,
        DIR_TOP,
        DIR_BOTTOM
    }

    private static const _DIR_LEFT = 0;
    private static const _DIR_RIGHT = 1;
    private static const _DIR_UP = 2;
    private static const _DIR_DOWN = 3;

    private static const _BTN_START_DEG = 30;
    private static const _BTN_LIGHT_DEG = 150;
    private static const _BTN_UP_DEG = 180;
    private static const _BTN_DOWN_DEG = 210;
    private static const _BTN_BACK_DEG = 330;

    var dc;

    var w;
    var h;
    var cx;
    var cy;
    var r = null;

    // init

    function initialize(dc) {
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

    function setColor(foreground) {
        dc.setColor(foreground, Graphene.COLOR_BLACK);
    }

    function resetColor() {
        setColor(Graphene.COLOR_WHITE);
    }

    // fill shape

    //! Fill a rectangle around a point
    function fillRectangleCentered(xCenter, yCenter, width, height) {
        dc.fillRectangle(xCenter - width / 2, yCenter - height / 2, width, height);
    }

    // stroke shape

    //! Fill a circle with an outside stroke
    function strokeCircle(x, y, r, strokeWidth, fillColor, strokeColor) {
        // stroke
        setColor(strokeColor);
        dc.fillCircle(x, y, r + strokeWidth);

        // fill
        setColor(fillColor);
        dc.fillCircle(x, y, r);
    }

    //! Fill a rectangle with an outside stroke
    function strokeRectangle(x, y, width, height, strokeWidth, fillColor, strokeColor) {
        // stroke
        setColor(strokeColor);
        dc.fillRectangle(x - strokeWidth, y - strokeWidth, width + 2 * strokeWidth, height + 2 * strokeWidth);

        // fill
        setColor(fillColor);
        dc.fillRectangle(x, y, width, height);
    }

    //! Fill a rectangle with an outside stroke around a point
    function strokeRectangleCentered(xCenter, yCenter, width, height, strokeWidth, fillColor, strokeColor) {
        // stroke
        setColor(strokeColor);
        fillRectangleCentered(xCenter, yCenter, width + 2 * strokeWidth, height);

        // fill
        setColor(dc, fillColor);
        fillRectangleCentered(xCenter, yCenter, width, height);
    }

    // draw text

    function drawGlanceTitle(text) {
        resetColor();
        dc.drawText(0, 0, Graphene.FONT_XTINY, text, Graphics.TEXT_JUSTIFY_LEFT);
    }

    function drawViewTitle(text) {
        resetColor();
        dc.drawText(cx, 23, Graphene.FONT_TINY, text.toUpper(), Graphics.TEXT_JUSTIFY_CENTER);
    }

    // page indicator

    function drawHorizontalPageIndicator(pageCount, index) {
        if (pageCount <= 1) {
            return;
        }

        var lengthDeg = 3;
        var deltaDeg = lengthDeg + 2;
        var centerDeg = _BTN_START_DEG;
        var maxDeg = centerDeg + deltaDeg * (pageCount - 1) / 2f;
        var minDeg = maxDeg - pageCount * deltaDeg;
        var edgeOffset = 5;
        var amp = r - edgeOffset;
        var stroke = 4;
        var bgStroke = stroke + 6;
        var bgMinDeg = minDeg + lengthDeg + 1.5;
        var bgMaxDeg = maxDeg + lengthDeg + 1.5;

        // bg outline
        setColor(Graphene.COLOR_BLACK);
        dc.setPenWidth(bgStroke);
        dc.drawArc(cx, cy, amp, Graphics.ARC_COUNTER_CLOCKWISE, bgMinDeg, bgMaxDeg);

        // indicator
        dc.setPenWidth(stroke);
        for (var i = 0; i < pageCount; i++) {
            var startDeg = maxDeg - i * deltaDeg;
            var endDeg = startDeg + lengthDeg;

            if (i == index) {
                resetColor();
            }
            else {
                setColor(Graphene.COLOR_DK_GRAY);
            }
            dc.drawArc(cx, cy, amp, Graphics.ARC_COUNTER_CLOCKWISE, startDeg, endDeg);
        }
    }

    function drawVerticalPageIndicator(pageCount, index) {
        if (pageCount <= 1) {
            return;
        }

        var deltaDeg = 7;
        var centerDeg = 180;
        var minDeg = centerDeg - deltaDeg * (pageCount - 1) / 2f;
        var edgeOffset = 8;
        var amp = r - edgeOffset;
        var radius = 2;
        var stroke = 2;
        var bgStroke = 2;

        dc.setPenWidth(stroke);

        for (var i = 0; i < pageCount; i++) {
            var deg = minDeg + i * deltaDeg;
            var pos = Chem.polarPos(amp, Chem.rad(deg), cx, cy);
            var x = pos[0];
            var y = pos[1];

            // bg outline
            setColor(Graphene.COLOR_BLACK);
            dc.fillCircle(x, y, radius + stroke + bgStroke);

            // indicator
            if (i == index) {
                resetColor();
                dc.fillCircle(x, y, radius + stroke);
            }
            else {
                strokeCircle(x, y, radius, stroke, Graphene.COLOR_BLACK, Graphene.COLOR_LT_GRAY);
                //setColor(Graphene.COLOR_LT_GRAY);
                //dc.drawCircle(x, y, radius + stroke / 2f);
            }
        }
    }

    // page arrow

    function drawHorizontalPageArrows(pageCount, index) {
        if (pageCount <= 1) {
            return;
        }

        if (index != 0) {
            drawLeftPageArrow();
        }
        if (index != pageCount - 1) {
            drawRightPageArrow();
        }
    }

    function drawVerticalPageArrows(pageCount, index) {
        if (pageCount <= 1) {
            return;
        }

        if (index != 0) {
            drawTopPageArrow();
        }
        if (index != pageCount - 1) {
            drawBottomPageArrow();
        }
    }

    function drawLeftPageArrow() {
        _drawPageArrow([ 4, cy ], DIR_LEFT);
    }

    function drawRightPageArrow() {
        _drawPageArrow([ w - 4, cy ], DIR_RIGHT);
    }

    function drawTopPageArrow() {
        _drawPageArrow([ cx, 4 ], DIR_TOP);
    }

    function drawBottomPageArrow() {
        _drawPageArrow([ cx, h - 4 ], DIR_BOTTOM);
    }

    private function _drawPageArrow(point1, direction) {
        var deltaHori = 8;
        var deltaVert = 8;

        var point2;
        var point3;

        switch (direction) {
            case DIR_LEFT:
                point2 = addArrays(point1, [ deltaHori, deltaVert ]);
                point3 = addArrays(point1, [ deltaHori, -deltaVert ]);
                break;

            case DIR_RIGHT:
                point2 = addArrays(point1, [ -deltaHori, deltaVert ]);
                point3 = addArrays(point1, [ -deltaHori, -deltaVert ]);
                break;

            case DIR_TOP:
                point2 = addArrays(point1, [ -deltaHori, deltaVert ]);
                point3 = addArrays(point1, [ deltaHori, deltaVert ]);
                break;

            case DIR_BOTTOM:
                point2 = addArrays(point1, [ -deltaHori, -deltaVert ]);
                point3 = addArrays(point1, [ deltaHori, -deltaVert ]);
                break;
        }

        setColor(Graphene.COLOR_DK_GRAY);
        dc.fillPolygon([ point1, point2, point3 ]);
    }

}
