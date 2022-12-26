using Toybox.Graphics;
using Toybox.Math;
using Toybox.WatchUi;
using Carbon.Chem;
using Carbon.Graphene;
using Carbon.Graphite;

module WidgetUtil {

    // directions
    const _DIR_LEFT = 0;
    const _DIR_RIGHT = 1;
    const _DIR_UP = 2;
    const _DIR_DOWN = 3;

    // text

    function drawDialog(dc, title, msg) {
        Graphite.resetColor(dc);

        var titleFont = Graphics.FONT_SMALL;
        var msgFont = Graphics.FONT_XTINY;

        if (msg == null || msg.equals("")) {
            Graphite.resetColor(dc);
            dc.drawText(Graphite.getCenterX(dc), Graphite.getCenterY(dc), titleFont, title, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        }
        else if (title == null || title.equals("")) {
            Graphite.setColor(dc, AppColors.TEXT_SECONDARY);
            dc.drawText(Graphite.getCenterX(dc), Graphite.getCenterY(dc), msgFont, msg, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        }
        else {
            var titleFontHeight = dc.getFontHeight(titleFont);
            var msgFontHeight = dc.getFontHeight(msgFont);
            var lineHeight = 1.15;

            var titleY = Graphite.getCenterX(dc) - lineHeight * titleFontHeight / 2;
            var msgY = Graphite.getCenterX(dc) + lineHeight * msgFontHeight / 2;

            Graphite.resetColor(dc);
            dc.drawText(Graphite.getCenterX(dc), titleY, titleFont, title, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
            Graphite.setColor(dc, AppColors.TEXT_SECONDARY);
            dc.drawText(Graphite.getCenterX(dc), msgY, msgFont, msg, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    // header/footer

    function drawExclamationBanner(dc) {
        dc.setPenWidth(px(dc, 2));
        drawHeader(dc, pxY(dc, 30), Graphene.COLOR_RED, Graphene.COLOR_BLACK, "!", Graphene.COLOR_WHITE);
        Graphite.resetPenWidth(dc);
    }

    function drawHeader(dc, height, color, strokeColor, text, textColor) {
        Graphite.setColor(dc, color);
        dc.fillRectangle(0, 0, dc.getWidth(), height);

        if (strokeColor != null) {
            Graphite.setColor(dc, strokeColor);
            dc.drawLine(0, height, dc.getWidth(), height);
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

    // start indicator

    (:round)
    function drawStartIndicatorWithBitmap(dc, rezId) {
        var r = Graphite.getRadius(dc) - px(dc, 23);
        var pos = Chem.polarPos(r, Chem.rad(30), Graphite.getCenterX(dc), Graphite.getCenterY(dc));

        RezUtil.drawBitmap(dc, pos[0], pos[1], rezId);
        drawStartIndicator(dc);
    }

    (:rectangle)
    function drawStartIndicatorWithBitmap(dc, rezId) {
        var x = dc.getWidth() - px(dc, 23);
        var y = 0.5 * dc.getHeight(); // sin(30) = 0.5

        RezUtil.drawBitmap(dc, x, y, rezId);
        drawStartIndicator(dc);
    }

    (:round)
    function drawStartIndicator(dc) {
        var offset = px(dc, 5);
        var width = px(dc, 4);
        var strokeWidth = px(dc, 1);

        Graphite.strokeArcCentered(dc, offset, width, strokeWidth, 20, 40, Graphene.COLOR_WHITE, Graphene.COLOR_BLACK);
    }

    (:rectangle)
    function drawStartIndicator(dc) {
        var offset = pxX(dc, 5);
        var width = pxX(dc, 4);
        var strokeWidth = px(dc, 1);

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

        var edgeOffset = pxX(dc, 2);
        var startDeg = 180 - sizeDeg / 2;
        var endDeg = 180 + sizeDeg / 2;

        var railWidth = px(dc, 1);
        var outlineWidth = px(dc, 3);

        // rail
        Graphite.strokeArcCentered(dc, edgeOffset, railWidth, outlineWidth, startDeg, endDeg, Graphene.COLOR_DK_GRAY, Graphene.COLOR_BLACK);

        var barDeltaDeg = (endDeg - startDeg) * (endIndex - startIndex) / itemCount.toFloat();
        var barStartDeg = startDeg + (endDeg - startDeg) * startIndex / itemCount.toFloat();
        var barEndDeg = barStartDeg + barDeltaDeg;

        // bar
        Graphite.resetColor(dc);
        dc.setPenWidth(px(dc, 3));
        Graphite.drawArcCentered(dc, edgeOffset, barStartDeg, barEndDeg);

        Graphite.resetPenWidth(dc);
    }

    (:rectangle)
    function _drawVerticalScrollbar(dc, sizeDeg, itemCount, startIndex, endIndex) {
        if (itemCount <= 1) {
            return;
        }

        var x = pxX(dc, 3);
        var startDeg = 180 - sizeDeg / 2;
        var endDeg = 180 + sizeDeg / 2;
        var yStart = degToY(dc, startDeg);
        var yEnd = degToY(dc, endDeg);
        var height = Chem.abs(yEnd - yStart);

        var railWidth = pxX(dc, 1);
        var outlineWidth = pxX(dc, 3);

        // rail
        Graphite.strokeRectangleCentered(dc, x, Graphite.getCenterY(dc), railWidth, height, outlineWidth, Graphene.COLOR_DK_GRAY, Graphene.COLOR_BLACK);

        var barHeight = height * (endIndex - startIndex) / itemCount.toFloat();
        var barStartY = yStart + height * startIndex / itemCount.toFloat();

        // bar
        Graphite.resetColor(dc);
        dc.setPenWidth(pxX(dc, 3));
        Graphite.fillRectangleCentered(dc, x, barStartY + barHeight / 2, px(dc, 3), barHeight);

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
        var centerDeg = 30; // _BTN_START_DEG
        var maxDeg = centerDeg + deltaDeg * (pageCount - 1) / 2f;
        var minDeg = maxDeg - pageCount * deltaDeg;
        var edgeOffset = px(dc, 5);
        var stroke = px(dc, 4);

        var outlineWidth = px(dc, 3);
        var outlineWidthDeg = Math.ceil(Graphite.pxToDeg(outlineWidth, Graphite.getRadius(dc) - edgeOffset));
        var bgStroke = stroke + px(dc, 2) * outlineWidth;
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

        var length = pxY(dc, 6); // length of one indicator
        var delta = length + pxY(dc, 3);
        var center = degToY(dc, 30); // _BTN_START_DEG
        var max = center + delta * (pageCount - 1) / 2f;
        var min = max - pageCount * delta;
        var edgeOffset = pxX(dc, 5);
        var stroke = pxX(dc, 4);

        var outlineWidth = pxX(dc, 3);
        var bgStroke = stroke + px(dc, 2) * outlineWidth;

        // bg outline
        Graphite.setColor(dc, Graphene.COLOR_BLACK);
        dc.setPenWidth(bgStroke);
        Graphite.fillRectangleCentered(dc, dc.getWidth() - edgeOffset, center - 2 * outlineWidth, stroke + 2 * outlineWidth, max - min + 2 * outlineWidth);

        // indicator
        for (var i = 0; i < pageCount; i++) {
            var start = min + i * delta;
            var end = start + length;

            var y = (end + start) / 2;
            var height = Chem.abs(end - start);
            Log.d("y " + y);
            Log.d("h " + height);

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
        _drawPageArrow(dc, [ Graphite.getCenterX(dc), pxY(dc, 4) ], _DIR_UP);
    }

    function drawBottomPageArrow(dc) {
        _drawPageArrow(dc, [ Graphite.getCenterX(dc), dc.getHeight() - pxY(dc, 4) ], _DIR_DOWN);
    }

    function drawUpArrow(dc, bottomTo) {
        _drawPageArrow(dc, [ Graphite.getCenterX(dc), bottomTo - pxY(dc, 4 + 8) ], _DIR_UP);
    }

    function drawDownArrow(dc, bottomTo) {
        _drawPageArrow(dc, [ Graphite.getCenterX(dc), bottomTo - pxY(dc, 4) ], _DIR_DOWN);
    }

    function _drawPageArrow(dc, point1, direction) {
        var width = pxX(dc, 8);
        var height = pxY(dc, 8);

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

    function drawPanedList(dc, items, paneSize, cursor, paneHints, mainHints, cc) {
        var paneHint = paneHints[0];
        var mainHint = mainHints[0];

        var hasPane = paneSize != 0;
        var hasMain = paneSize != items.size();

        var paneStrokeColor = null;

        // pane is empty
        if (!hasPane) {
            paneHint = paneHints[1];
            cc = [ Graphene.COLOR_BLACK, Graphene.COLOR_WHITE, Graphene.COLOR_LT_GRAY, Graphene.COLOR_DK_GRAY ];
            paneStrokeColor = Graphene.COLOR_DK_GRAY;
        }

        // main is empty
        if (!hasMain) {
            mainHint = mainHints[1];
        }

        // draw panes + page arrows

        // inside pane
        if (cursor < paneSize) {
            Graphite.fillBackground(dc, cc[0]);

            // top header
            if (cursor == 0) {
                drawHeader(dc, pxY(dc, 84), Graphene.COLOR_BLACK, paneStrokeColor, rez(Rez.Strings.app_name), AppColors.TEXT_TERTIARY);
            }
            else if (cursor == 1) {
                drawHeader(dc, pxY(dc, 42), Graphene.COLOR_BLACK, paneStrokeColor, null, null);
                Graphite.setColor(dc, AppColors.CONTROL_NORMAL);
                drawUpArrow(dc, pxY(dc, 42));
            }
            else {
                Graphite.setColor(dc, cc[3]);
                drawTopPageArrow(dc);
            }

            // bottom header
            if (cursor == paneSize - 2) {
                drawFooter(dc, pxY(dc, 42), Graphene.COLOR_BLACK, paneStrokeColor, null, null);
                Graphite.setColor(dc, cc[3]);
                drawDownArrow(dc, dc.getHeight() - pxY(dc, 42));
            }
            else if (cursor == paneSize - 1) {
                drawFooter(dc, pxY(dc, 84), Graphene.COLOR_BLACK, paneStrokeColor, mainHint, AppColors.TEXT_TERTIARY);
                Graphite.setColor(dc, cc[3]);
                drawDownArrow(dc, dc.getHeight() - pxY(dc, 84));
            }
            else {
                Graphite.setColor(dc, cc[3]);
                drawBottomPageArrow(dc);
            }
        }

        // outside pane
        else {
            // top header
            if (cursor == paneSize) {
                drawHeader(dc, pxY(dc, 84), cc[0], paneStrokeColor, paneHint, cc[3]);
                Graphite.setColor(dc, cc[3]);
                if (hasPane) {
                    drawUpArrow(dc, pxY(dc, 84));
                }
            }
            else if (cursor == paneSize + 1) {
                drawHeader(dc, pxY(dc, 42), cc[0], paneStrokeColor, null, null);
                Graphite.setColor(dc, cc[3]);
                drawUpArrow(dc, pxY(dc, 42));
            }
            else {
                Graphite.setColor(dc, AppColors.CONTROL_NORMAL);
                drawTopPageArrow(dc);
            }

            // bottom header
            if (hasMain && cursor != items.size() - 1) {
                Graphite.setColor(dc, AppColors.CONTROL_NORMAL);
                drawBottomPageArrow(dc);
            }
        }

        // draw items

        var fontsSelected = [ Graphics.FONT_LARGE, Graphics.FONT_MEDIUM, Graphics.FONT_SMALL ];
        var font = Graphics.FONT_TINY;
        var h = dc.getHeight() - 2 * pxY(dc, 36);
        var lineHeightPx = h / 4;

        var bgColor = cursor >= paneSize ? Graphics.COLOR_BLACK : cc[0];
        var selectedColor;
        var unselectedColor;

        // only draw 2 items above and 2 below cursor
        var itemOffset = 2;
        var firstItemIndex = Chem.max(0, cursor - itemOffset);
        var lastItemIndex = Chem.min(items.size(), cursor + itemOffset + 1);

        // only draw one list at a time
        if (cursor < paneSize) {
            lastItemIndex = Chem.min(lastItemIndex, paneSize);
            selectedColor = cc[1];
            unselectedColor = cc[2];
        }
        else {
            firstItemIndex = Chem.max(firstItemIndex, paneSize);
            selectedColor = AppColors.TEXT_PRIMARY;
            unselectedColor = AppColors.TEXT_SECONDARY;
        }

        // draw the items
        for (var i = firstItemIndex; i < lastItemIndex; i++) {
            var item = items[i];

            var justification = Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER;

            if (i == cursor) {
                var margin = pxX(dc, 5);
                var width = dc.getWidth() - 2 * margin;
                var height = dc.getFontHeight(fontsSelected[0]);

                Graphite.drawTextArea(dc, Graphite.getCenterX(dc), Graphite.getCenterY(dc), width, height, fontsSelected, item, justification, selectedColor);
            }
            else {
                var yText = Graphite.getCenterY(dc) + (i - cursor) * lineHeightPx;

                dc.setColor(unselectedColor, bgColor);
                dc.drawText(Graphite.getCenterX(dc), yText, font, item, justification);
            }
        }
    }

}
