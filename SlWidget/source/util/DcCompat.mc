using Toybox.WatchUi;
using Toybox.Math;
using Toybox.Graphics;
using Carbon.Graphene;
using Carbon.Chem;

class DcCompat {

    // directions
    private static const _DIR_LEFT = 0;
    private static const _DIR_RIGHT = 1;
    private static const _DIR_UP = 2;
    private static const _DIR_DOWN = 3;

    // button angles
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
    var r;

    // init

    function initialize(dc) {
        self.dc = dc;
        w = dc.getWidth();
        h = dc.getHeight();
        cx = w / 2;
        cy = h / 2;
        r = (w + h) / 4;
    }

    // tool

    function pxToRad(px, r) {
        return px.toFloat() / r;
    }

    function pxToDeg(px, r) {
        return Chem.deg(pxToRad(px, r));
    }

    // color

    function setColor(foreground) {
        dc.setColor(foreground, Graphene.COLOR_BLACK);
    }

    function resetColor() {
        setColor(Graphene.COLOR_WHITE);
    }

    function resetFgColor(background) {
        dc.setColor(Graphene.COLOR_WHITE, background);
    }

    function resetPenWidth() {
        dc.setPenWidth(1);
    }

    // draw shape

    function drawArcCompat(edgeOffset, degreeStart, degreeEnd) {
        dc.drawArc(cx, cy, r - edgeOffset, Graphics.ARC_COUNTER_CLOCKWISE, degreeStart, degreeEnd);
    }

    // fill shape

    function fillBackground(color) {
        setColor(color);
        fillRectangleCentered(cx, cy, w, h);
    }

    //! Fill a rectangle around a point
    function fillRectangleCentered(xCenter, yCenter, width, height) {
        dc.fillRectangle(xCenter - width / 2, yCenter - height / 2, width, height);
    }

    // stroke shape

    function strokeArcCompat(edgeOffset, width, strokeWidth, degreeStart, degreeEnd, color, strokeColor) {
        strokeArc(cx, cy, r - edgeOffset, width, strokeWidth, degreeStart, degreeEnd, color, strokeColor);
    }

    function strokeArc(x, y, r, width, strokeWidth, degreeStart, degreeEnd, color, strokeColor) {
        degreeStart = Math.floor(degreeStart);
        degreeEnd = Math.ceil(degreeEnd);

        var strokeDegreeOffset = Math.ceil(pxToDeg(strokeWidth, self.r));
        var strokeDegreeStart = degreeStart - strokeDegreeOffset;
        var strokeDegreeEnd = degreeEnd + strokeDegreeOffset;
        var attr = Graphics.ARC_COUNTER_CLOCKWISE;

        // stroke
        setColor(strokeColor);
        dc.setPenWidth(width + 2 * strokeWidth);
        dc.drawArc(x, y, r, attr, strokeDegreeStart, strokeDegreeEnd);

        // draw
        setColor(color);
        dc.setPenWidth(width);
        dc.drawArc(x, y, r, attr, degreeStart, degreeEnd);

        resetPenWidth();
    }

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

    // text

    function drawTextArea(x, y, w, h, fonts, text, justification, color) {
        // compute location depending on justification, to match how `Dc#drawText` behaves
        var locX = justification&Graphics.TEXT_JUSTIFY_CENTER
            ? x - w / 2
            : (justification&Graphics.TEXT_JUSTIFY_RIGHT ? x - w : x);
        var locY = justification&Graphics.TEXT_JUSTIFY_VCENTER ? y - h / 2 : y;

        var textArea = new WatchUi.TextArea({
            :text => text,
            :color => color,
            :font => fonts,
            :locX => locX,
            :locY => locY,
            :width => w,
            :height => h,
            :justification => justification
        });

        textArea.draw(dc);
    }

    function drawViewTitle(text) {
        resetColor();
        dc.drawText(cx, 23, Graphene.FONT_SMALL, text, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawDialog(title, msg) {
        resetColor();

        var titleFont = Graphene.FONT_SMALL;
        var msgFont = Graphene.FONT_XTINY;

        if (msg == null || msg.equals("")) {
            resetColor();
            dc.drawText(cx, cy, titleFont, title, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        }
        else if (title == null || title.equals("")) {
            setColor(Color.TEXT_SECONDARY);
            dc.drawText(cx, cy, msgFont, msg, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        }
        else {
            var titleFontHeight = dc.getFontHeight(titleFont);
            var msgFontHeight = dc.getFontHeight(msgFont);
            var lineHeight = 1.15;

            var titleY = cx - lineHeight * titleFontHeight / 2;
            var msgY = cx + lineHeight * msgFontHeight / 2;

            resetColor();
            dc.drawText(cx, titleY, titleFont, title, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
            setColor(Color.TEXT_SECONDARY);
            dc.drawText(cx, msgY, msgFont, msg, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    // banner

    function drawExclamationBanner() {
        // bg stroke
        setColor(Graphene.COLOR_BLACK);
        dc.fillRectangle(0, 30, w, 2);

        // banner
        setColor(Graphene.COLOR_RED);
        dc.fillRectangle(0, 0, w, 30);

        // text
        resetFgColor(Graphene.COLOR_RED);
        dc.drawText(cx, -1, Graphene.FONT_SMALL, "!", Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawHeader(color, strokeColor) {
        var height = 42;

        setColor(color);
        dc.fillRectangle(0, 0, w, height);

        if (strokeColor != null) {
            setColor(strokeColor);
            dc.drawLine(0, height, w, height);
        }
    }

    function drawHeaderLarge(color, strokeColor, text, textColor) {
        var height = 84;

        setColor(color);
        dc.fillRectangle(0, 0, w, height);

        if (strokeColor != null) {
            setColor(strokeColor);
            dc.drawLine(0, height, w, height);
        }

        dc.setColor(textColor, color);
        dc.drawText(w / 2, height / 2, Graphene.FONT_TINY, text, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawFooter(color, strokeColor) {
        var height = 42;

        setColor(color);
        dc.fillRectangle(0, h - height, w, height);

        if (strokeColor != null) {
            setColor(strokeColor);
            dc.drawLine(0, h - height, w, h - height);
        }
    }

    function drawFooterLarge(color, strokeColor, text, textColor) {
        var height = 84;

        setColor(color);
        dc.fillRectangle(0, h - height, w, height);

        if (strokeColor != null) {
            setColor(strokeColor);
            dc.drawLine(0, h - height, w, h - height);
        }

        dc.setColor(textColor, color);
        dc.drawText(w / 2, h - height / 2, Graphene.FONT_TINY, text, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // bar

    function drawStartIndicator() {
        strokeArcCompat(5, 4, 1, 20, 40, Graphene.COLOR_WHITE, Graphene.COLOR_BLACK);
    }

    function drawStartIndicatorWithBitmap(rezId) {
        var pos = Chem.polarPos(r - 23, Chem.rad(30), cx, cy);

        drawBitmap(pos[0], pos[1], rezId);
        drawStartIndicator();
    }

    function drawBitmap(x, y, rezId) {
        var drawable = new WatchUi.Bitmap({ :rezId => rezId });

        drawable.setLocation(x - drawable.width / 2, y - drawable.height / 2);
        drawable.draw(dc);
    }

    // scrollbar

    function drawVerticalScrollbarSmall(pageCount, index) {
        _drawVerticalScrollbar(50, pageCount, index, index + 1);
    }

    function drawVerticalScrollbarCSmall(itemCount, startIndex, endIndex) {
        _drawVerticalScrollbar(50, itemCount, startIndex, endIndex);
    }

    function drawVerticalScrollbarMedium(pageCount, index) {
        _drawVerticalScrollbar(70, pageCount, index, index + 1);
    }

    function drawVerticalScrollbarCMedium(itemCount, startIndex, endIndex) {
        _drawVerticalScrollbar(70, itemCount, startIndex, endIndex);
    }

    function drawVerticalScrollbarLarge(pageCount, index) {
        _drawVerticalScrollbar(100, pageCount, index, index + 1);
    }

    function drawVerticalScrollbarCLarge(itemCount, startIndex, endIndex) {
        _drawVerticalScrollbar(100, itemCount, startIndex, endIndex);
    }

    private function _drawVerticalScrollbar(sizeDeg, itemCount, startIndex, endIndex) {
        if (itemCount <= 1) {
            return;
        }

        var edgeOffset = 2;
        var startDeg = 180 - sizeDeg / 2;
        var endDeg = 180 + sizeDeg / 2;

        var strokeWidth = 1;
        var outlineWidth = 3;

        // rail
        strokeArcCompat(edgeOffset, strokeWidth, outlineWidth, startDeg, endDeg, Graphene.COLOR_DK_GRAY, Graphene.COLOR_BLACK);

        var itemDeltaDeg = (endDeg - startDeg) * (endIndex - startIndex) / itemCount.toFloat();
        var itemStartDeg = startDeg + (endDeg - startDeg) * startIndex / itemCount.toFloat();
        var itemEndDeg = itemStartDeg + itemDeltaDeg;

        // bar
        resetColor();
        dc.setPenWidth(3);
        drawArcCompat(edgeOffset, itemStartDeg, itemEndDeg);

        resetPenWidth();
    }

    // page indicator

    function drawHorizontalPageIndicator(pageCount, index) {
        if (pageCount <= 1) {
            return;
        }

        var lengthDeg = 3; // length in degrees of one indicator
        var deltaDeg = lengthDeg + 2;
        var centerDeg = _BTN_START_DEG;
        var maxDeg = centerDeg + deltaDeg * (pageCount - 1) / 2f;
        var minDeg = maxDeg - pageCount * deltaDeg;
        var edgeOffset = 5;
        var stroke = 4;

        var outlineWidth = 3;
        var outlineWidthDeg = Math.ceil(pxToDeg(outlineWidth, self.r - edgeOffset));
        var bgStroke = stroke + 2 * outlineWidth;
        var bgMinDeg = minDeg + deltaDeg - outlineWidthDeg;
        var bgMaxDeg = maxDeg + lengthDeg + outlineWidthDeg;

        // bg outline
        setColor(Graphene.COLOR_BLACK);
        dc.setPenWidth(bgStroke);
        drawArcCompat(edgeOffset, bgMinDeg, bgMaxDeg);

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
            drawArcCompat(edgeOffset, startDeg, endDeg);
        }

        resetPenWidth();
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

        resetPenWidth();
    }

    function drawVerticalPageNumber(pageCount, index) {
        if (pageCount <= 1) {
            return;
        }

        var font = Graphene.FONT_XTINY;
        var fh = dc.getFontHeight(font);
        var text = (index + 1).toString() + "/" + pageCount.toString();

        var arrowEdgeOffset = 4;
        var arrowHeight = 8;
        var arrowNumberOffset = 8;
        var y = h - arrowEdgeOffset - arrowHeight - fh - arrowNumberOffset;

        dc.drawText(cx, y, font, text, Graphics.TEXT_JUSTIFY_CENTER);
        //dc.drawText(10, cy - fh / 2, font, (index + 1).toString(), Graphics.TEXT_JUSTIFY_CENTER);
    }

    // page arrow

    function drawHorizontalPageArrows(pageCount, index, leftColor, rightColor) {
        if (pageCount <= 1) {
            return;
        }

        if (index != 0) {
            setColor(leftColor);
            drawLeftPageArrow();
        }
        if (index != pageCount - 1) {
            setColor(rightColor);
            drawRightPageArrow();
        }

        resetColor();
    }

    function drawVerticalPageArrows(pageCount, index, topColor, bottomColor) {
        if (pageCount <= 1) {
            return;
        }

        if (index != 0) {
            setColor(topColor);
            drawTopPageArrow();
        }
        if (index != pageCount - 1) {
            setColor(bottomColor);
            drawBottomPageArrow();
        }

        resetColor();
    }

    function drawLeftPageArrow() {
        _drawPageArrow([ 4, cy ], _DIR_LEFT);
    }

    function drawRightPageArrow() {
        _drawPageArrow([ w - 4, cy ], _DIR_RIGHT);
    }

    function drawTopPageArrow() {
        _drawPageArrow([ cx, 4 ], _DIR_UP);
    }

    function drawBottomPageArrow() {
        _drawPageArrow([ cx, h - 4 ], _DIR_DOWN);
    }

    function drawUpArrow(bottomTo) {
        _drawPageArrow([ cx, bottomTo - 4 - 8 ], _DIR_UP);
    }

    function drawDownArrow(bottomTo) {
        _drawPageArrow([ cx, bottomTo - 4 ], _DIR_DOWN);
    }

    private function _drawPageArrow(point1, direction) {
        var width = 8;
        var height = 8;

        var point2;
        var point3;

        switch (direction) {
            case _DIR_LEFT:
                point2 = ArrCompat.add(point1, [ width, height ]);
                point3 = ArrCompat.add(point1, [ width, -height ]);
                break;

            case _DIR_RIGHT:
                point2 = ArrCompat.add(point1, [ -width, height ]);
                point3 = ArrCompat.add(point1, [ -width, -height ]);
                break;

            case _DIR_UP:
                point2 = ArrCompat.add(point1, [ -width, height ]);
                point3 = ArrCompat.add(point1, [ width, height ]);
                break;

            case _DIR_DOWN:
                point2 = ArrCompat.add(point1, [ -width, -height ]);
                point3 = ArrCompat.add(point1, [ width, -height ]);
                break;
        }

        dc.fillPolygon([ point1, point2, point3 ]);
    }

    // list

    function drawPanedList(items, paneSize, cursor, paneHints, mainHints, cc) {
        var paneHint = paneHints[0];
        var mainHint = mainHints[0];

        var hasPane = paneSize != 0;
        var hasMain = paneSize != items.size();

        var paneStrokeColor = null;

        // pane is empty
        if (!hasPane) {
            paneHint = paneHints[1];
            cc = ColorContext.black();
            paneStrokeColor = Graphene.COLOR_DK_GRAY;
        }

        // main is empty
        if (!hasMain) {
            mainHint = mainHints[1];
        }

        // draw panes + page arrows

        // inside pane
        if (cursor < paneSize) {
            fillBackground(cc.background);

            // top header
            if (cursor == 0) {
                drawHeaderLarge(Color.BACKGROUND, paneStrokeColor, rez(Rez.Strings.app_name), Color.TEXT_TERTIARY);
            }
            else if (cursor == 1) {
                drawHeader(Color.BACKGROUND, paneStrokeColor);
                setColor(Color.CONTROL_NORMAL);
                drawUpArrow(42);
            }
            else {
                setColor(cc.textTertiary);
                drawTopPageArrow();
            }

            // bottom header
            if (cursor == paneSize - 2) {
                drawFooter(Color.BACKGROUND, paneStrokeColor);
                setColor(cc.textTertiary);
                drawDownArrow(h - 42);
            }
            else if (cursor == paneSize - 1) {
                drawFooterLarge(Color.BACKGROUND, paneStrokeColor, mainHint, Color.TEXT_TERTIARY);
                setColor(cc.textTertiary);
                drawDownArrow(h - 84);
            }
            else {
                setColor(cc.textTertiary);
                drawBottomPageArrow();
            }
        }

        // outside pane
        else {
            // top header
            if (cursor == paneSize) {
                drawHeaderLarge(cc.background, paneStrokeColor, paneHint, cc.textTertiary);
                setColor(cc.textTertiary);
                if (hasPane) {
                    drawUpArrow(84);
                }
            }
            else if (cursor == paneSize + 1) {
                drawHeader(cc.background, paneStrokeColor);
                setColor(cc.textTertiary);
                drawUpArrow(42);
            }
            else {
                setColor(Color.CONTROL_NORMAL);
                drawTopPageArrow();
            }

            // bottom header
            if (hasMain && cursor != items.size() - 1) {
                setColor(Color.CONTROL_NORMAL);
                drawBottomPageArrow();
            }
        }

        // draw items

        var fontsSelected = [ Graphene.FONT_LARGE, Graphene.FONT_MEDIUM, Graphene.FONT_SMALL ];
        var font = Graphene.FONT_TINY;
        var fontHeight = dc.getFontHeight(font);
        var lineHeight = 1.6;
        var lineHeightPx = fontHeight * lineHeight;

        var bgColor = cursor >= paneSize ? Color.BACKGROUND : cc.background;
        var selectedColor;
        var unselectedColor;

        // only draw 2 items above and 2 below cursor
        var itemOffset = 2;
        var firstItemIndex = Chem.max(0, cursor - itemOffset);
        var lastItemIndex = Chem.min(items.size(), cursor + itemOffset + 1);

        // only draw one list at a time
        if (cursor < paneSize) {
            lastItemIndex = Chem.min(lastItemIndex, paneSize);
            selectedColor = cc.textPrimary;
            unselectedColor = cc.textSecondary;
        }
        else {
            firstItemIndex = Chem.max(firstItemIndex, paneSize);
            selectedColor = Color.TEXT_PRIMARY;
            unselectedColor = Color.TEXT_SECONDARY;
        }

        // draw the items
        for (var i = firstItemIndex; i < lastItemIndex; i++) {
            var item = items[i];

            var justification = Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER;

            if (i == cursor) {
                var margin = 5;
                var width = w - 2 * margin;
                var height = dc.getFontHeight(fontsSelected[0]);

                drawTextArea(cx, cy, width, height, fontsSelected, item, justification, selectedColor);
            }
            else {
                var yText = cy + (i - cursor) * lineHeightPx;

                dc.setColor(unselectedColor, bgColor);
                dc.drawText(cx, yText, font, item, justification);
            }
        }
    }

}
