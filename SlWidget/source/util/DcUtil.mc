using Toybox.WatchUi;
using Toybox.Math;
using Toybox.Graphics;
using Carbon.Graphene;
using Carbon.Chem;

module DcUtil {

    // directions
    const _DIR_LEFT = 0;
    const _DIR_RIGHT = 1;
    const _DIR_UP = 2;
    const _DIR_DOWN = 3;

    // button angles
    const _BTN_START_DEG = 30;
    const _BTN_LIGHT_DEG = 150;
    const _BTN_UP_DEG = 180;
    const _BTN_DOWN_DEG = 210;
    const _BTN_BACK_DEG = 330;

    // tool

    function getCenterX(dc) {
        return dc.getWidth() / 2;
    }

    function getCenterY(dc) {
        return dc.getHeight() / 2;
    }

    function getRadius(dc) {
        return (dc.getWidth() + dc.getHeight()) / 4;
    }

    function pxToRad(px, r) {
        return px.toFloat() / r;
    }

    function pxToDeg(px, r) {
        return Chem.deg(pxToRad(px, r));
    }

    // color

    function setColor(dc, foreground) {
        dc.setColor(foreground, Graphene.COLOR_BLACK);
    }

    function resetColor(dc) {
        setColor(dc, Graphene.COLOR_WHITE);
    }

    function resetFgColor(dc, background) {
        dc.setColor(Graphene.COLOR_WHITE, background);
    }

    function resetPenWidth(dc) {
        dc.setPenWidth(1);
    }

    // draw shape

    function drawArcCentered(dc, edgeOffset, degreeStart, degreeEnd) {
        dc.drawArc(getCenterX(dc), getCenterY(dc), getRadius(dc) - edgeOffset, Graphics.ARC_COUNTER_CLOCKWISE, degreeStart, degreeEnd);
    }

    // fill shape

    function fillBackground(dc, color) {
        setColor(dc, color);
        fillRectangleCentered(dc, getCenterX(dc), getCenterY(dc), dc.getWidth(), dc.getHeight());
    }

    //! Fill a rectangle around a point
    function fillRectangleCentered(dc, xCenter, yCenter, width, height) {
        dc.fillRectangle(xCenter - width / 2, yCenter - height / 2, width, height);
    }

    // stroke shape

    function strokeArcCentered(dc, edgeOffset, width, strokeWidth, degreeStart, degreeEnd, color, strokeColor) {
        var x = getCenterX(dc);
        var y = getCenterY(dc);
        var r = getRadius(dc) - edgeOffset;

        degreeStart = Math.floor(degreeStart);
        degreeEnd = Math.ceil(degreeEnd);

        var strokeDegreeOffset = Math.ceil(pxToDeg(strokeWidth, getRadius(dc)));
        var strokeDegreeStart = degreeStart - strokeDegreeOffset;
        var strokeDegreeEnd = degreeEnd + strokeDegreeOffset;
        var attr = Graphics.ARC_COUNTER_CLOCKWISE;

        // stroke
        setColor(dc, strokeColor);
        dc.setPenWidth(width + 2 * strokeWidth);
        dc.drawArc(x, y, r, attr, strokeDegreeStart, strokeDegreeEnd);

        // draw
        setColor(dc, color);
        dc.setPenWidth(width);
        dc.drawArc(x, y, r, attr, degreeStart, degreeEnd);

        resetPenWidth(dc);
    }

    //! Fill a circle with an outside stroke
    function strokeCircle(dc, x, y, r, strokeWidth, fillColor, strokeColor) {
        // stroke
        setColor(dc, strokeColor);
        dc.fillCircle(x, y, r + strokeWidth);

        // fill
        setColor(dc, fillColor);
        dc.fillCircle(x, y, r);
    }

    //! Fill a rectangle with an outside stroke
    function strokeRectangle(dc, x, y, width, height, strokeWidth, fillColor, strokeColor) {
        // stroke
        setColor(dc, strokeColor);
        dc.fillRectangle(x - strokeWidth, y - strokeWidth, width + 2 * strokeWidth, height + 2 * strokeWidth);

        // fill
        setColor(dc, fillColor);
        dc.fillRectangle(x, y, width, height);
    }

    //! Fill a rectangle with an outside stroke around a point
    function strokeRectangleCentered(dc, xCenter, yCenter, width, height, strokeWidth, fillColor, strokeColor) {
        // stroke
        setColor(dc, strokeColor);
        fillRectangleCentered(dc, xCenter, yCenter, width + 2 * strokeWidth, height);

        // fill
        setColor(dc, fillColor);
        fillRectangleCentered(dc, xCenter, yCenter, width, height);
    }

    // text

    function drawTextArea(dc, x, y, w, h, fonts, text, justification, color) {
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

    function drawViewTitle(dc, text) {
        resetColor(dc);
        dc.drawText(getCenterX(dc), 23, Graphene.FONT_SMALL, text, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawDialog(dc, title, msg) {
        resetColor(dc);

        var titleFont = Graphene.FONT_SMALL;
        var msgFont = Graphene.FONT_XTINY;

        if (msg == null || msg.equals("")) {
            resetColor(dc);
            dc.drawText(getCenterX(dc), getCenterY(dc), titleFont, title, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        }
        else if (title == null || title.equals("")) {
            setColor(dc, AppColors.TEXT_SECONDARY);
            dc.drawText(getCenterX(dc), getCenterY(dc), msgFont, msg, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        }
        else {
            var titleFontHeight = dc.getFontHeight(titleFont);
            var msgFontHeight = dc.getFontHeight(msgFont);
            var lineHeight = 1.15;

            var titleY = getCenterX(dc) - lineHeight * titleFontHeight / 2;
            var msgY = getCenterX(dc) + lineHeight * msgFontHeight / 2;

            resetColor(dc);
            dc.drawText(getCenterX(dc), titleY, titleFont, title, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
            setColor(dc, AppColors.TEXT_SECONDARY);
            dc.drawText(getCenterX(dc), msgY, msgFont, msg, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    // banner

    function drawExclamationBanner(dc) {
        // bg stroke
        setColor(dc, Graphene.COLOR_BLACK);
        dc.fillRectangle(0, 30, dc.getWidth(), 2);

        // banner
        setColor(dc, Graphene.COLOR_RED);
        dc.fillRectangle(0, 0, dc.getWidth(), 30);

        // text
        resetFgColor(dc, Graphene.COLOR_RED);
        dc.drawText(getCenterX(dc), -1, Graphene.FONT_SMALL, "!", Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawHeader(dc, color, strokeColor) {
        var height = 42;

        setColor(dc, color);
        dc.fillRectangle(0, 0, dc.getWidth(), height);

        if (strokeColor != null) {
            setColor(dc, strokeColor);
            dc.drawLine(0, height, dc.getWidth(), height);
        }
    }

    function drawHeaderLarge(dc, color, strokeColor, text, textColor) {
        var height = 84;

        setColor(dc, color);
        dc.fillRectangle(0, 0, dc.getWidth(), height);

        if (strokeColor != null) {
            setColor(dc, strokeColor);
            dc.drawLine(0, height, dc.getWidth(), height);
        }

        dc.setColor(textColor, color);
        dc.drawText(dc.getWidth() / 2, height / 2, Graphene.FONT_TINY, text, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawFooter(dc, color, strokeColor) {
        var height = 42;

        setColor(dc, color);
        dc.fillRectangle(0, dc.getHeight() - height, dc.getWidth(), height);

        if (strokeColor != null) {
            setColor(dc, strokeColor);
            dc.drawLine(0, dc.getHeight() - height, dc.getWidth(), dc.getHeight() - height);
        }
    }

    function drawFooterLarge(dc, color, strokeColor, text, textColor) {
        var height = 84;

        setColor(dc, color);
        dc.fillRectangle(0, dc.getHeight() - height, dc.getWidth(), height);

        if (strokeColor != null) {
            setColor(dc, strokeColor);
            dc.drawLine(0, dc.getHeight() - height, dc.getWidth(), dc.getHeight() - height);
        }

        dc.setColor(textColor, color);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() - height / 2, Graphene.FONT_TINY, text, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // bar

    function drawStartIndicator(dc) {
        strokeArcCentered(dc, 5, 4, 1, 20, 40, Graphene.COLOR_WHITE, Graphene.COLOR_BLACK);
    }

    function drawStartIndicatorWithBitmap(dc, rezId) {
        var pos = Chem.polarPos(getRadius(dc) - 23, Chem.rad(30), getCenterX(dc), getCenterY(dc));

        drawBitmap(dc, pos[0], pos[1], rezId);
        drawStartIndicator(dc);
    }

    function drawBitmap(dc, x, y, rezId) {
        var drawable = new WatchUi.Bitmap({ :rezId => rezId });

        drawable.setLocation(x - drawable.width / 2, y - drawable.height / 2);
        drawable.draw(dc);
    }

    // scrollbar

    function drawVerticalScrollbarSmall(dc, pageCount, index) {
        _drawVerticalScrollbar(dc, 50, pageCount, index, index + 1);
    }

    function drawVerticalScrollbarCSmall(dc, itemCount, startIndex, endIndex) {
        _drawVerticalScrollbar(dc, 50, itemCount, startIndex, endIndex);
    }

    function drawVerticalScrollbarMedium(dc, pageCount, index) {
        _drawVerticalScrollbar(dc, 70, pageCount, index, index + 1);
    }

    function drawVerticalScrollbarCMedium(dc, itemCount, startIndex, endIndex) {
        _drawVerticalScrollbar(dc, 70, itemCount, startIndex, endIndex);
    }

    function drawVerticalScrollbarLarge(dc, pageCount, index) {
        _drawVerticalScrollbar(dc, 100, pageCount, index, index + 1);
    }

    function drawVerticalScrollbarCLarge(dc, itemCount, startIndex, endIndex) {
        _drawVerticalScrollbar(dc, 100, itemCount, startIndex, endIndex);
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
        strokeArcCentered(dc, edgeOffset, strokeWidth, outlineWidth, startDeg, endDeg, Graphene.COLOR_DK_GRAY, Graphene.COLOR_BLACK);

        var itemDeltaDeg = (endDeg - startDeg) * (endIndex - startIndex) / itemCount.toFloat();
        var itemStartDeg = startDeg + (endDeg - startDeg) * startIndex / itemCount.toFloat();
        var itemEndDeg = itemStartDeg + itemDeltaDeg;

        // bar
        resetColor(dc);
        dc.setPenWidth(3);
        drawArcCentered(dc, edgeOffset, itemStartDeg, itemEndDeg);

        resetPenWidth(dc);
    }

    // page indicator

    function drawHorizontalPageIndicator(dc, pageCount, index) {
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
        var outlineWidthDeg = Math.ceil(pxToDeg(outlineWidth, getRadius(dc) - edgeOffset));
        var bgStroke = stroke + 2 * outlineWidth;
        var bgMinDeg = minDeg + deltaDeg - outlineWidthDeg;
        var bgMaxDeg = maxDeg + lengthDeg + outlineWidthDeg;

        // bg outline
        setColor(dc, Graphene.COLOR_BLACK);
        dc.setPenWidth(bgStroke);
        drawArcCentered(dc, edgeOffset, bgMinDeg, bgMaxDeg);

        // indicator
        dc.setPenWidth(stroke);
        for (var i = 0; i < pageCount; i++) {
            var startDeg = maxDeg - i * deltaDeg;
            var endDeg = startDeg + lengthDeg;

            if (i == index) {
                resetColor(dc);
            }
            else {
                setColor(dc, Graphene.COLOR_DK_GRAY);
            }
            drawArcCentered(dc, edgeOffset, startDeg, endDeg);
        }

        resetPenWidth(dc);
    }

    function drawVerticalPageIndicator(dc, pageCount, index) {
        if (pageCount <= 1) {
            return;
        }

        var deltaDeg = 7;
        var centerDeg = 180;
        var minDeg = centerDeg - deltaDeg * (pageCount - 1) / 2f;
        var edgeOffset = 8;
        var amp = getRadius(dc) - edgeOffset;
        var radius = 2;
        var stroke = 2;
        var bgStroke = 2;

        dc.setPenWidth(stroke);

        for (var i = 0; i < pageCount; i++) {
            var deg = minDeg + i * deltaDeg;
            var pos = Chem.polarPos(amp, Chem.rad(deg), getCenterX(dc), getCenterY(dc));
            var x = pos[0];
            var y = pos[1];

            // bg outline
            setColor(dc, Graphene.COLOR_BLACK);
            dc.fillCircle(x, y, radius + stroke + bgStroke);

            // indicator
            if (i == index) {
                resetColor(dc);
                dc.fillCircle(x, y, radius + stroke);
            }
            else {
                strokeCircle(dc, x, y, radius, stroke, Graphene.COLOR_BLACK, Graphene.COLOR_LT_GRAY);
                //setColor(dc, Graphene.COLOR_LT_GRAY);
                //dc.drawCircle(x, y, radius + stroke / 2f);
            }
        }

        resetPenWidth(dc);
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

        dc.drawText(getCenterX(dc), y, font, text, Graphics.TEXT_JUSTIFY_CENTER);
        //dc.drawText(10, getCenterY(dc) - fh / 2, font, (index + 1).toString(), Graphics.TEXT_JUSTIFY_CENTER);
    }

    // page arrow

    function drawHorizontalPageArrows(dc, pageCount, index, leftColor, rightColor) {
        if (pageCount <= 1) {
            return;
        }

        if (index != 0) {
            setColor(dc, leftColor);
            drawLeftPageArrow(dc);
        }
        if (index != pageCount - 1) {
            setColor(dc, rightColor);
            drawRightPageArrow(dc);
        }

        resetColor(dc);
    }

    function drawVerticalPageArrows(dc, pageCount, index, topColor, bottomColor) {
        if (pageCount <= 1) {
            return;
        }

        if (index != 0) {
            setColor(dc, topColor);
            drawTopPageArrow(dc);
        }
        if (index != pageCount - 1) {
            setColor(dc, bottomColor);
            drawBottomPageArrow(dc);
        }

        resetColor(dc);
    }

    function drawLeftPageArrow(dc) {
        _drawPageArrow(dc, [ 4, getCenterY(dc) ], _DIR_LEFT);
    }

    function drawRightPageArrow(dc) {
        _drawPageArrow(dc, [ dc.getWidth() - 4, getCenterY(dc) ], _DIR_RIGHT);
    }

    function drawTopPageArrow(dc) {
        _drawPageArrow(dc, [ getCenterX(dc), 4 ], _DIR_UP);
    }

    function drawBottomPageArrow(dc) {
        _drawPageArrow(dc, [ getCenterX(dc), dc.getHeight() - 4 ], _DIR_DOWN);
    }

    function drawUpArrow(dc, bottomTo) {
        _drawPageArrow(dc, [ getCenterX(dc), bottomTo - 4 - 8 ], _DIR_UP);
    }

    function drawDownArrow(dc, bottomTo) {
        _drawPageArrow(dc, [ getCenterX(dc), bottomTo - 4 ], _DIR_DOWN);
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
            fillBackground(dc, cc.background);

            // top header
            if (cursor == 0) {
                drawHeaderLarge(dc, AppColors.BACKGROUND, paneStrokeColor, rez(Rez.Strings.app_name), AppColors.TEXT_TERTIARY);
            }
            else if (cursor == 1) {
                drawHeader(dc, AppColors.BACKGROUND, paneStrokeColor);
                setColor(dc, AppColors.CONTROL_NORMAL);
                drawUpArrow(dc, 42);
            }
            else {
                setColor(dc, cc.textTertiary);
                drawTopPageArrow(dc);
            }

            // bottom header
            if (cursor == paneSize - 2) {
                drawFooter(dc, AppColors.BACKGROUND, paneStrokeColor);
                setColor(dc, cc.textTertiary);
                drawDownArrow(dc, dc.getHeight() - 42);
            }
            else if (cursor == paneSize - 1) {
                drawFooterLarge(dc, AppColors.BACKGROUND, paneStrokeColor, mainHint, AppColors.TEXT_TERTIARY);
                setColor(dc, cc.textTertiary);
                drawDownArrow(dc, dc.getHeight() - 84);
            }
            else {
                setColor(dc, cc.textTertiary);
                drawBottomPageArrow(dc);
            }
        }

        // outside pane
        else {
            // top header
            if (cursor == paneSize) {
                drawHeaderLarge(dc, cc.background, paneStrokeColor, paneHint, cc.textTertiary);
                setColor(dc, cc.textTertiary);
                if (hasPane) {
                    drawUpArrow(dc, 84);
                }
            }
            else if (cursor == paneSize + 1) {
                drawHeader(dc, cc.background, paneStrokeColor);
                setColor(dc, cc.textTertiary);
                drawUpArrow(dc, 42);
            }
            else {
                setColor(dc, AppColors.CONTROL_NORMAL);
                drawTopPageArrow(dc);
            }

            // bottom header
            if (hasMain && cursor != items.size() - 1) {
                setColor(dc, AppColors.CONTROL_NORMAL);
                drawBottomPageArrow(dc);
            }
        }

        // draw items

        var fontsSelected = [ Graphene.FONT_LARGE, Graphene.FONT_MEDIUM, Graphene.FONT_SMALL ];
        var font = Graphene.FONT_TINY;
        var fontHeight = dc.getFontHeight(font);
        var lineHeight = 1.6;
        var lineHeightPx = fontHeight * lineHeight;

        var bgColor = cursor >= paneSize ? AppColors.BACKGROUND : cc.background;
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

                drawTextArea(dc, getCenterX(dc), getCenterY(dc), width, height, fontsSelected, item, justification, selectedColor);
            }
            else {
                var yText = getCenterY(dc) + (i - cursor) * lineHeightPx;

                dc.setColor(unselectedColor, bgColor);
                dc.drawText(getCenterX(dc), yText, font, item, justification);
            }
        }
    }

}
