using Toybox.Graphics;
using Toybox.Math;

module WidgetUtil {

    // directions
    const _DIR_LEFT = 0;
    const _DIR_RIGHT = 1;
    const _DIR_UP = 2;
    const _DIR_DOWN = 3;

    // button positions
    const _BTN_START_DEG = 30;
    const _BTN_LIGHT_DEG = 150;
    const _BTN_UP_DEG = 180;
    const _BTN_DOWN_DEG = 210;
    const _BTN_BACK_DEG = 330;

    // text

    function drawDialog(dc, text) {
        var fonts = [ Graphics.FONT_SMALL ];
        var fh = Graphics.getFontHeight(fonts[0]);
        var w = dc.getWidth() - px(12);
        var h = dc.getHeight() / 2;

        Graphite.resetColor(dc);
        Graphite.drawTextArea(dc, Graphite.getCenterX(dc), Graphite.getCenterY(dc) - fh / 2,
            w, h, fonts, text, Graphics.TEXT_JUSTIFY_CENTER, Graphene.COLOR_WHITE);
    }

    function drawPreviewTitle(dc, text, rezId) {
        var yText = px(45);

        if (rezId != null) {
            RezUtil.drawBitmap(dc, Graphite.getCenterX(dc), px(30), rezId);
            yText = px(68);
        }

        dc.drawText(Graphite.getCenterX(dc), yText, Graphics.FONT_SMALL, text,
            Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // header/footer

    function drawExclamationBanner(dc) {
        drawHeader(dc, px(30), Graphene.COLOR_RED, Graphene.COLOR_BLACK, "!", Graphene.COLOR_WHITE);
        Graphite.resetPenWidth(dc);
    }

    function drawActionFooter(dc, message) {
        drawFooter(dc, px(45), Graphene.COLOR_WHITE, Graphene.COLOR_BLACK, message, Graphene.COLOR_BLACK);

        Graphite.setColor(dc, Graphene.COLOR_BLACK);
        drawBottomPageArrow(dc);
        Graphite.resetColor(dc);
    }

    function drawHeader(dc, height, color, strokeColor, text, textColor) {
        Graphite.setColor(dc, color);
        dc.fillRectangle(0, 0, dc.getWidth(), height);

        if (strokeColor != null) {
            dc.setPenWidth(px(2));
            Graphite.setColor(dc, strokeColor);
            dc.drawLine(0, height, dc.getWidth(), height);
            Graphite.resetPenWidth(dc);
        }

        if (text != null && !text.equals("")) {
            dc.setColor(textColor, color);
            dc.drawText(dc.getWidth() / 2, height / 2, Graphics.FONT_TINY, text,
                Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    function drawFooter(dc, height, color, strokeColor, text, textColor) {
        Graphite.setColor(dc, color);
        dc.fillRectangle(0, dc.getHeight() - height, dc.getWidth(), height);

        if (strokeColor != null) {
            Graphite.setColor(dc, strokeColor);
            dc.drawLine(0, dc.getHeight() - height, dc.getWidth(), dc.getHeight() - height);
        }

        if (text != null && !text.equals("")) {
            var font = Graphics.FONT_TINY;
            // balance optically with 1/4 of font height
            var y = dc.getHeight() - height / 2 - dc.getFontHeight(font) / 4;

            dc.setColor(textColor, color);
            dc.drawText(dc.getWidth() / 2, y, font, text,
                Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    function drawProgressBar(dc, y, h, progress, activeColor, inactiveColor) {
        var r = Graphite.getRadius(dc);
        var start = MathUtil.minX(y, r);
        var end = MathUtil.maxX(y, r);
        var w = end - start;
        var middle = w * progress;

        Graphite.setColor(dc, activeColor);
        dc.fillRectangle(start, y, start + middle, h);

        Graphite.setColor(dc, inactiveColor);
        dc.fillRectangle(start + middle, y, end, h);

        Graphite.resetColor(dc);
    }

    // start indicator

    (:round)
    function drawStartIndicatorWithBitmap(dc, rezId) {
        var r = Graphite.getRadius(dc) - px(23);
        var pos = MathUtil.polarPos(r, MathUtil.rad(30), Graphite.getCenterX(dc), Graphite.getCenterY(dc));

        RezUtil.drawBitmap(dc, pos[0], pos[1], rezId);
        drawStartIndicator(dc);
    }

    (:rectangle)
    function drawStartIndicatorWithBitmap(dc, rezId) {
        var x = dc.getWidth() - px(23);
        var y = 0.5 * dc.getHeight(); // sin(30) = 0.5

        RezUtil.drawBitmap(dc, x, y, rezId);
        drawStartIndicator(dc);
    }

    (:round)
    function drawStartIndicator(dc) {
        var offset = px(5);
        var width = px(4);
        var strokeWidth = px(1);

        Graphite.strokeArcCentered(dc, offset, width, strokeWidth, 20, 40, Graphene.COLOR_WHITE, Graphene.COLOR_BLACK);
    }

    (:rectangle)
    function drawStartIndicator(dc) {
        var offset = px(5);
        var width = px(4);
        var strokeWidth = px(1);

        var x = dc.getWidth() - offset;
        var y = 0.34 * dc.getHeight(); // sin(20) = 0.34
        var yBottom = 0.64 * dc.getHeight(); // sin(40) = 0.64
        var height = yBottom - y;

        Graphite.strokeRectangle(dc, x, y, width, height, strokeWidth, Graphene.COLOR_WHITE, Graphene.COLOR_BLACK);
    }

    // scrollbar

    function drawVerticalScrollbarSmall(dc, pageCount, index) {
        _drawVerticalScrollbar(dc, 50, pageCount, index, index + 1);
    }

    (:round)
    function _drawVerticalScrollbar(dc, sizeDeg, itemCount, startIndex, endIndex) {
        if (itemCount <= 1) {
            return;
        }

        var edgeOffset = px(2);
        var startDeg = 180 - sizeDeg / 2;
        var endDeg = 180 + sizeDeg / 2;

        var railWidth = px(1);
        var outlineWidth = px(3);

        // rail
        Graphite.strokeArcCentered(dc, edgeOffset, railWidth, outlineWidth, startDeg, endDeg, Graphene.COLOR_DK_GRAY, Graphene.COLOR_BLACK);

        var barDeltaDeg = (endDeg - startDeg) * (endIndex - startIndex) / itemCount.toFloat();
        var barStartDeg = startDeg + (endDeg - startDeg) * startIndex / itemCount.toFloat();
        var barEndDeg = barStartDeg + barDeltaDeg;

        // bar
        Graphite.resetColor(dc);
        dc.setPenWidth(px(3));
        Graphite.drawArcCentered(dc, edgeOffset, barStartDeg, barEndDeg);

        Graphite.resetPenWidth(dc);
    }

    (:rectangle)
    function _drawVerticalScrollbar(dc, sizeDeg, itemCount, startIndex, endIndex) {
        if (itemCount <= 1) {
            return;
        }

        var x = px(3);
        var startDeg = 180 - sizeDeg / 2;
        var endDeg = 180 + sizeDeg / 2;
        var yStart = Graphite.degToY(dc, startDeg);
        var yEnd = Graphite.degToY(dc, endDeg);
        var height = MathUtil.abs(yEnd - yStart);

        var railWidth = px(1);
        var outlineWidth = px(3);

        // rail
        Graphite.strokeRectangleCentered(dc, x, Graphite.getCenterY(dc), railWidth, height, outlineWidth, Graphene.COLOR_DK_GRAY, Graphene.COLOR_BLACK);

        var barHeight = height * (endIndex - startIndex) / itemCount.toFloat();
        var barStartY = yStart + height * startIndex / itemCount.toFloat();

        // bar
        Graphite.resetColor(dc);
        dc.setPenWidth(px(3));
        Graphite.fillRectangleCentered(dc, x, barStartY + barHeight / 2, px(3), barHeight);

        Graphite.resetPenWidth(dc);
    }

    // page indicator

    (:round)
    function drawHorizontalPageIndicator(dc, pageCount, index) {
        if (pageCount <= 1) {
            return;
        }

        var lengthDeg = 3; // length in degrees of one indicator
        var deltaDeg = lengthDeg + 2;
        var centerDeg = _BTN_START_DEG;
        var maxDeg = centerDeg + deltaDeg * (pageCount - 1) / 2f;
        var minDeg = maxDeg - pageCount * deltaDeg;
        var edgeOffset = px(5);
        var stroke = px(4);

        var outlineWidth = px(3);
        var outlineWidthDeg = Math.ceil(Graphite.pxToDeg(outlineWidth, Graphite.getRadius(dc) - edgeOffset));
        var bgStroke = stroke + px(2) * outlineWidth;
        var bgMinDeg = minDeg + deltaDeg - outlineWidthDeg;
        var bgMaxDeg = maxDeg + lengthDeg + outlineWidthDeg;

        // bg outline
        Graphite.setColor(dc, Graphene.COLOR_BLACK);
        dc.setPenWidth(bgStroke);
        Graphite.drawArcCentered(dc, edgeOffset, bgMinDeg, bgMaxDeg);

        // indicator

        dc.setPenWidth(stroke);

        for (var i = 0; i < pageCount; i++) {
            var startDeg = maxDeg - i * deltaDeg;
            var endDeg = startDeg + lengthDeg;

            if (i == index) {
                Graphite.resetColor(dc);
            }
            else {
                Graphite.setColor(dc, Graphene.COLOR_DK_GRAY);
            }

            Graphite.drawArcCentered(dc, edgeOffset, startDeg, endDeg);
        }

        Graphite.resetPenWidth(dc);
    }

    (:rectangle)
    function drawHorizontalPageIndicator(dc, pageCount, index) {
        if (pageCount <= 1) {
            return;
        }

        var length = px(6); // length of one indicator
        var delta = length + px(3);
        var center = Graphite.degToY(dc, _BTN_START_DEG);
        var max = center + delta * (pageCount - 1) / 2f;
        var min = max - pageCount * delta;
        var edgeOffset = px(5);
        var stroke = px(4);

        var outlineWidth = px(3);
        var bgStroke = stroke + px(2) * outlineWidth;

        // bg outline
        Graphite.setColor(dc, Graphene.COLOR_BLACK);
        dc.setPenWidth(bgStroke);
        Graphite.fillRectangleCentered(dc, dc.getWidth() - edgeOffset, center - 2 * outlineWidth, stroke + 2 * outlineWidth, max - min + 2 * outlineWidth);

        // indicator
        for (var i = 0; i < pageCount; i++) {
            var start = min + i * delta;
            var end = start + length;

            var y = (end + start) / 2;
            var height = MathUtil.abs(end - start);

            if (i == index) {
                Graphite.resetColor(dc);
            }
            else {
                Graphite.setColor(dc, Graphene.COLOR_DK_GRAY);
            }

            Graphite.fillRectangleCentered(dc, dc.getWidth() - edgeOffset, y, stroke, height);
        }
    }

    // page arrow

    function drawVerticalPageArrows(dc, pageCount, index, topColor, bottomColor) {
        if (pageCount <= 1) {
            return;
        }

        if (index != 0) {
            Graphite.setColor(dc, topColor);
            drawTopPageArrow(dc);
        }
        if (index != pageCount - 1) {
            Graphite.setColor(dc, bottomColor);
            drawBottomPageArrow(dc);
        }

        Graphite.resetColor(dc);
    }

    function drawTopPageArrow(dc) {
        _drawPageArrow(dc, [ Graphite.getCenterX(dc), px(4) ], _DIR_UP);
    }

    function drawBottomPageArrow(dc) {
        _drawPageArrow(dc, [ Graphite.getCenterX(dc), dc.getHeight() - px(4) ], _DIR_DOWN);
    }

    function drawUpArrow(dc, bottomTo) {
        _drawPageArrow(dc, [ Graphite.getCenterX(dc), bottomTo - px(4 + 8) ], _DIR_UP);
    }

    function drawDownArrow(dc, bottomTo) {
        _drawPageArrow(dc, [ Graphite.getCenterX(dc), bottomTo - px(4) ], _DIR_DOWN);
    }

    function _drawPageArrow(dc, point1, direction) {
        var width = px(8);
        var height = px(8);

        var point2;
        var point3;

        if (direction ==_DIR_LEFT) {
            point2 = ArrUtil.add(point1, [ width, height ]);
            point3 = ArrUtil.add(point1, [ width, -height ]);
        }
        else if (direction ==_DIR_RIGHT) {
            point2 = ArrUtil.add(point1, [ -width, height ]);
            point3 = ArrUtil.add(point1, [ -width, -height ]);
        }
        else if (direction ==_DIR_UP) {
            point2 = ArrUtil.add(point1, [ -width, height ]);
            point3 = ArrUtil.add(point1, [ width, height ]);
        }
        else if (direction ==_DIR_DOWN) {
            point2 = ArrUtil.add(point1, [ -width, -height ]);
            point3 = ArrUtil.add(point1, [ width, -height ]);
        }
        else {
            point2 = [ 0, 0 ];
            point3 = [ 0, 0 ];
        }

        dc.fillPolygon([ point1, point2, point3 ]);
    }

    // list

    function drawPanedList(dc, items, paneSize, cursor, paneHints, mainHints, paneColors, mainColors) {
        var paneHint = paneHints[0];
        var mainHint = mainHints[0];

        var hasPane = paneSize != 0;
        var hasMain = paneSize != items.size();

        var paneStrokeColor = null;

        // pane is empty
        if (!hasPane) {
            paneHint = paneHints[1];
            paneColors = mainColors;
            paneStrokeColor = mainColors[3];
        }

        // main is empty
        if (!hasMain) {
            mainHint = mainHints[1];
        }

        // draw panes + page arrows

        // inside pane
        if (cursor < paneSize) {
            Graphite.fillBackground(dc, paneColors[0]);

            // top header
            if (cursor == 0) {
                drawHeader(dc, px(84), mainColors[0], paneStrokeColor, rez(Rez.Strings.app_name), mainColors[1]);
            }
            else if (cursor == 1) {
                drawHeader(dc, px(42), mainColors[0], paneStrokeColor, null, null);
                Graphite.setColor(dc, mainColors[3]);
                drawUpArrow(dc, px(42));
            }
            else {
                Graphite.setColor(dc, paneColors[3]);
                drawTopPageArrow(dc);
            }

            // bottom header
            if (cursor == paneSize - 2) {
                drawFooter(dc, px(42), mainColors[0], paneStrokeColor, null, null);
                Graphite.setColor(dc, paneColors[3]);
                drawDownArrow(dc, dc.getHeight() - px(42));
            }
            else if (cursor == paneSize - 1) {
                drawFooter(dc, px(84), mainColors[0], paneStrokeColor, mainHint, mainColors[3]);
                Graphite.setColor(dc, paneColors[3]);
                drawDownArrow(dc, dc.getHeight() - px(84));
            }
            else {
                Graphite.setColor(dc, paneColors[3]);
                drawBottomPageArrow(dc);
            }
        }

        // outside pane
        else {
            // top header
            if (cursor == paneSize) {
                drawHeader(dc, px(84), paneColors[0], paneStrokeColor, paneHint, paneColors[3]);
                Graphite.setColor(dc, paneColors[3]);
                if (hasPane) {
                    drawUpArrow(dc, px(84));
                }
            }
            else if (cursor == paneSize + 1) {
                drawHeader(dc, px(42), paneColors[0], paneStrokeColor, null, null);
                Graphite.setColor(dc, paneColors[3]);
                drawUpArrow(dc, px(42));
            }
            else {
                Graphite.setColor(dc, mainColors[3]);
                drawTopPageArrow(dc);
            }

            // bottom header
            if (hasMain && cursor != items.size() - 1) {
                Graphite.setColor(dc, mainColors[3]);
                drawBottomPageArrow(dc);
            }
        }

        // draw items

        var fontsSelected = [ Graphics.FONT_LARGE, Graphics.FONT_MEDIUM, Graphics.FONT_SMALL, Graphics.FONT_TINY, Graphics.FONT_XTINY ];
        var font = Graphics.FONT_TINY;
        var h = dc.getHeight() - 2 * px(36);
        var lineHeightPx = h / 4;

        var bgColor = cursor >= paneSize ? Graphics.COLOR_BLACK : paneColors[0];
        var selectedColor;
        var unselectedColor;

        // only draw 2 items above and 2 below cursor
        var itemOffset = 2;
        var firstItemIndex = MathUtil.max(0, cursor - itemOffset);
        var lastItemIndex = MathUtil.min(items.size(), cursor + itemOffset + 1);

        // only draw one list at a time
        if (cursor < paneSize) {
            lastItemIndex = MathUtil.min(lastItemIndex, paneSize);
            selectedColor = paneColors[1];
            unselectedColor = paneColors[2];
        }
        else {
            firstItemIndex = MathUtil.max(firstItemIndex, paneSize);
            selectedColor = mainColors[1];
            unselectedColor = mainColors[2];
        }

        // draw the items
        for (var i = firstItemIndex; i < lastItemIndex; i++) {
            var item = items[i];

            var justification = Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER;

            if (i == cursor) {
                var margin = px(2);
                var width = dc.getWidth() - 2 * margin;
                var height = dc.getFontHeight(fontsSelected[0]);

                Graphite.drawTextArea(dc, Graphite.getCenterX(dc), Graphite.getCenterY(dc), width, height,
                    fontsSelected, item, justification, selectedColor);
            }
            else {
                var yText = Graphite.getCenterY(dc) + (i - cursor) * lineHeightPx;

                dc.setColor(unselectedColor, bgColor);
                dc.drawText(Graphite.getCenterX(dc), yText, font, item, justification);
            }
        }
    }

}
