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

        var titleFont = Graphene.FONT_SMALL;
        var msgFont = Graphene.FONT_XTINY;

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
        dc.setPenWidth(2);
        drawHeader(dc, 30, Graphene.COLOR_RED, Graphene.COLOR_BLACK, "!", Graphene.COLOR_WHITE);
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
            dc.drawText(dc.getWidth() / 2, height / 2, Graphene.FONT_TINY, text,
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
            var font = Graphene.FONT_TINY;
            // balance optically with 1/4 of font height
            var y = dc.getHeight() - height / 2 - dc.getFontHeight(font) / 4;

            dc.setColor(textColor, color);
            dc.drawText(dc.getWidth() / 2, y, font, text,
                Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    // start indicator

    function drawStartIndicatorWithBitmap(dc, rezId) {
        var pos = Chem.polarPos(Graphite.getRadius(dc) - 23, Chem.rad(30), Graphite.getCenterX(dc), Graphite.getCenterY(dc));

        RezUtil.drawBitmap(dc, pos[0], pos[1], rezId);
        drawStartIndicator(dc);
    }

    function drawStartIndicator(dc) {
        Graphite.strokeArcCentered(dc, 5, 4, 1, 20, 40, Graphene.COLOR_WHITE, Graphene.COLOR_BLACK);
    }

    // scrollbar

    function drawVerticalScrollbarSmall(dc, pageCount, index) {
        _drawVerticalScrollbar(dc, 50, pageCount, index, index + 1);
    }

    function _drawVerticalScrollbar(dc, sizeDeg, itemCount, startIndex, endIndex) {
        if (itemCount <= 1) {
            return;
        }

        var edgeOffset = 2;
        var startDeg = 180 - sizeDeg / 2;
        var endDeg = 180 + sizeDeg / 2;

        var strokeWidth = 1;
        var outlineWidth = 3;

        // rail
        Graphite.strokeArcCentered(dc, edgeOffset, strokeWidth, outlineWidth, startDeg, endDeg, Graphene.COLOR_DK_GRAY, Graphene.COLOR_BLACK);

        var itemDeltaDeg = (endDeg - startDeg) * (endIndex - startIndex) / itemCount.toFloat();
        var itemStartDeg = startDeg + (endDeg - startDeg) * startIndex / itemCount.toFloat();
        var itemEndDeg = itemStartDeg + itemDeltaDeg;

        // bar
        Graphite.resetColor(dc);
        dc.setPenWidth(3);
        Graphite.drawArcCentered(dc, edgeOffset, itemStartDeg, itemEndDeg);

        Graphite.resetPenWidth(dc);
    }

    // page indicator

    function drawHorizontalPageIndicator(dc, pageCount, index) {
        if (pageCount <= 1) {
            return;
        }

        var lengthDeg = 3; // length in degrees of one indicator
        var deltaDeg = lengthDeg + 2;
        var centerDeg = 30; // _BTN_START_DEG
        var maxDeg = centerDeg + deltaDeg * (pageCount - 1) / 2f;
        var minDeg = maxDeg - pageCount * deltaDeg;
        var edgeOffset = 5;
        var stroke = 4;

        var outlineWidth = 3;
        var outlineWidthDeg = Math.ceil(Graphite.pxToDeg(outlineWidth, Graphite.getRadius(dc) - edgeOffset));
        var bgStroke = stroke + 2 * outlineWidth;
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

    function drawVerticalPageNumber(dc, pageCount, index) {
        if (pageCount <= 1) {
            return;
        }

        var font = Graphene.FONT_XTINY;
        var fh = dc.getFontHeight(font);
        var text = (index + 1).toString() + "/" + pageCount.toString();

        var arrowEdgeOffset = 4;
        var arrowHeight = 8;
        var arrowNumberOffset = 8;
        var y = dc.getHeight() - arrowEdgeOffset - arrowHeight - fh - arrowNumberOffset;

        dc.drawText(Graphite.getCenterX(dc), y, font, text, Graphics.TEXT_JUSTIFY_CENTER);
        //dc.drawText(10, Graphite.getCenterY(dc) - fh / 2, font, (index + 1).toString(), Graphics.TEXT_JUSTIFY_CENTER);
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
        _drawPageArrow(dc, [ Graphite.getCenterX(dc), 4 ], _DIR_UP);
    }

    function drawBottomPageArrow(dc) {
        _drawPageArrow(dc, [ Graphite.getCenterX(dc), dc.getHeight() - 4 ], _DIR_DOWN);
    }

    function drawUpArrow(dc, bottomTo) {
        _drawPageArrow(dc, [ Graphite.getCenterX(dc), bottomTo - 4 - 8 ], _DIR_UP);
    }

    function drawDownArrow(dc, bottomTo) {
        _drawPageArrow(dc, [ Graphite.getCenterX(dc), bottomTo - 4 ], _DIR_DOWN);
    }

    function _drawPageArrow(dc, point1, direction) {
        var width = 8;
        var height = 8;

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
                drawHeader(dc, 84, Graphene.COLOR_BLACK, paneStrokeColor, rez(Rez.Strings.app_name), AppColors.TEXT_TERTIARY);
            }
            else if (cursor == 1) {
                drawHeader(dc, 42, Graphene.COLOR_BLACK, paneStrokeColor, null, null);
                Graphite.setColor(dc, AppColors.CONTROL_NORMAL);
                drawUpArrow(dc, 42);
            }
            else {
                Graphite.setColor(dc, cc[3]);
                drawTopPageArrow(dc);
            }

            // bottom header
            if (cursor == paneSize - 2) {
                drawFooter(dc, 42, Graphene.COLOR_BLACK, paneStrokeColor, null, null);
                Graphite.setColor(dc, cc[3]);
                drawDownArrow(dc, dc.getHeight() - 42);
            }
            else if (cursor == paneSize - 1) {
                drawFooter(dc, 84, Graphene.COLOR_BLACK, paneStrokeColor, mainHint, AppColors.TEXT_TERTIARY);
                Graphite.setColor(dc, cc[3]);
                drawDownArrow(dc, dc.getHeight() - 84);
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
                drawHeader(dc, 84, cc[0], paneStrokeColor, paneHint, cc[3]);
                Graphite.setColor(dc, cc[3]);
                if (hasPane) {
                    drawUpArrow(dc, 84);
                }
            }
            else if (cursor == paneSize + 1) {
                drawHeader(dc, 42, cc[0], paneStrokeColor, null, null);
                Graphite.setColor(dc, cc[3]);
                drawUpArrow(dc, 42);
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

        var fontsSelected = [ Graphene.FONT_LARGE, Graphene.FONT_MEDIUM, Graphene.FONT_SMALL ];
        var font = Graphene.FONT_TINY;
        var fontHeight = dc.getFontHeight(font);
        var lineHeight = 1.6;
        var lineHeightPx = fontHeight * lineHeight;

        var bgColor = cursor >= paneSize ? Graphene.COLOR_BLACK : cc[0];
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
                var margin = 5;
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
