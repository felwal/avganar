// This file is part of Avgånär.
//
// Avgånär is free software: you can redistribute it and/or modify it under the terms of
// the GNU General Public License as published by the Free Software Foundation,
// either version 3 of the License, or (at your option) any later version.
//
// Avgånär is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
// without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with Avgånär.
// If not, see <https://www.gnu.org/licenses/>.

import Toybox.Graphics;
import Toybox.Lang;

using Toybox.Math;

//! Draw more complex but common widgets.
module WidgetUtil {

    const ARROW_SIZE = px(8);
    const ARROW_EDGE_OFFSET = px(4);

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

    function drawDialog(dc as Dc, text as String) as Void {
        var fonts = [ Graphics.FONT_SMALL, Graphics.FONT_TINY ];
        var fh = Graphics.getFontHeight(fonts[0]);
        var w = dc.getWidth() - px(12);
        var h = dc.getHeight() / 2;

        Graphite.resetColor(dc);
        Graphite.drawTextArea(dc, Graphite.getCenterX(dc), Graphite.getCenterY(dc) - fh / 2,
            w, h, fonts, text, Graphics.TEXT_JUSTIFY_CENTER, AppColors.TEXT_PRIMARY);
    }

    function drawPreviewTitle(dc as Dc, text as String?,
        rezId as ResourceId?, smallIcon as Boolean) as Void {

        var yText = px(45);

        if (rezId != null) {
            var yIcon;

            if (smallIcon) {
                yIcon = px(25);
                yText = px(63);
            }
            else {
                yIcon = px(30);
                yText = px(68);
            }

            RezUtil.drawBitmap(dc, Graphite.getCenterX(dc), yIcon, rezId);
        }

        if (!StringUtil.isEmpty(text)) {
            dc.drawText(Graphite.getCenterX(dc), yText, Graphics.FONT_SMALL, text,
                Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    // header/footer

    function drawErrorBanner(dc as Dc) as Void {
        drawHeader(dc, px(30), AppColors.ERROR, AppColors.BACKGROUND, "!", AppColors.TEXT_PRIMARY);
    }

    function drawActionFooter(dc as Dc, message as String) as Void {
        drawFooter(dc, MenuUtil.HEIGHT_FOOTER_SMALL, AppColors.BACKGROUND_INVERTED,
            AppColors.BACKGROUND, message, AppColors.TEXT_INVERTED);

        Graphite.setColor(dc, AppColors.TEXT_INVERTED);
        drawBottomPageArrow(dc);
        Graphite.resetColor(dc);
    }

    function drawHeader(dc as Dc, height as Numeric, color as ColorType, strokeColor as ColorType?,
        text as String?, textColor as ColorType?) as Void {

        Graphite.setColor(dc, color);
        dc.fillRectangle(0, 0, dc.getWidth(), height);

        if (strokeColor != null) {
            var strokeWidth = px(1);
            var y = height - strokeWidth;

            dc.setPenWidth(strokeWidth);
            Graphite.setColor(dc, strokeColor);
            dc.drawLine(0, y, dc.getWidth(), y);
            Graphite.resetPenWidth(dc);
        }

        if (!StringUtil.isEmpty(text)) {
            dc.setColor(textColor, color);
            dc.drawText(dc.getWidth() / 2, height / 2, Graphics.FONT_TINY, text,
                Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    function drawFooter(dc as Dc, height as Numeric, color as ColorType, strokeColor as ColorType?,
        text as String?, textColor as ColorType?) as Void {

        Graphite.setColor(dc, color);
        dc.fillRectangle(0, dc.getHeight() - height, dc.getWidth(), height);

        if (strokeColor != null) {
            var strokeWidth = px(1);
            var y = dc.getHeight() - height - strokeWidth;

            dc.setPenWidth(strokeWidth);
            Graphite.setColor(dc, strokeColor);
            dc.drawLine(0, y, dc.getWidth(), y);
            Graphite.resetPenWidth(dc);
        }

        if (!StringUtil.isEmpty(text)) {
            var font = Graphics.FONT_TINY;
            // balance optically with 1/4 of font height
            var y = dc.getHeight() - height / 2 - dc.getFontHeight(font) / 4;

            dc.setColor(textColor, color);
            dc.drawText(dc.getWidth() / 2, y, font, text,
                Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    (:round)
    function drawProgressBar(dc as Dc, y as Numeric, h as Numeric, progress as Float,
        activeColor as ColorType, inactiveColor as ColorType?) as Void {

        var r = Graphite.getRadius(dc);
        var start = MathUtil.minX(y, r) - h;
        var end = MathUtil.maxX(y, r) + h;
        var w = end - start;
        var middle = Math.round(w * progress);

        Graphite.setColor(dc, activeColor);
        dc.fillRectangle(start, y, middle, h);

        if (inactiveColor != null) {
            Graphite.setColor(dc, inactiveColor);
            dc.fillRectangle(start + middle, y, w - middle, h);
        }

        Graphite.resetColor(dc);
    }

    (:rectangle)
    function drawProgressBar(dc as Dc, y as Numeric, h as Numeric, progress as Float,
        activeColor as ColorType, inactiveColor as ColorType?) as Void {

        var start = 0;
        var end = dc.getWidth();
        var w = end - start;
        var middle = w * progress;

        Graphite.setColor(dc, activeColor);
        dc.fillRectangle(start, y, start + middle, h);

        if (inactiveColor != null) {
            Graphite.setColor(dc, inactiveColor);
            dc.fillRectangle(start + middle, y, end, h);
        }

        Graphite.resetColor(dc);
    }

    // start indicator

    (:round)
    function drawStartIndicator(dc as Dc) as Void {
        var offset = px(5);
        var width = px(4);
        var strokeWidth = px(2);
        var degStart = _BTN_START_DEG - 10; // 20
        var degEnd = _BTN_START_DEG + 10; // 40

        Graphite.strokeArcCentered(dc, offset, width, strokeWidth, degStart, degEnd,
            AppColors.TEXT_PRIMARY, AppColors.BACKGROUND);
    }

    (:rectangle)
    function drawStartIndicator(dc as Dc) as Void {
        var offset = px(5);
        var width = px(4);
        var strokeWidth = px(2);

        var x = dc.getWidth() - offset;
        var yBottom = 0.66 * dc.getHeight() / 2; // sin(20) = 0.34
        var yTop = 0.36 * dc.getHeight() / 2; // sin(40) = 0.64
        var height = yBottom - yTop;

        Graphite.strokeRectangle(dc, x, yTop, width, height, strokeWidth, AppColors.TEXT_PRIMARY, AppColors.BACKGROUND);
    }

    // scrollbar

    function drawVerticalScrollbarSmall(dc as Dc, pageCount as Number, index as Number) as Void {
        _drawVerticalScrollbar(dc, 50, pageCount, index, index + 1);
    }

    (:round)
    function _drawVerticalScrollbar(dc as Dc, sizeDeg as Numeric,
        itemCount as Number, startIndex as Number, endIndex as Number) as Void {

        if (itemCount <= 1) {
            return;
        }

        var edgeOffset = px(2);
        var startDeg = 180 - sizeDeg / 2;
        var endDeg = 180 + sizeDeg / 2;

        var railWidth = px(1);
        var outlineWidth = px(3);

        // rail
        Graphite.strokeArcCentered(dc, edgeOffset, railWidth, outlineWidth, startDeg, endDeg,
            AppColors.TEXT_TERTIARY, AppColors.BACKGROUND);

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
    function _drawVerticalScrollbar(dc as Dc, sizeDeg as Numeric,
        itemCount as Number, startIndex as Number, endIndex as Number) as Void {

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
        Graphite.strokeRectangleCentered(dc, x, Graphite.getCenterY(dc), railWidth, height, outlineWidth,
            AppColors.TEXT_TERTIARY, AppColors.BACKGROUND);

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
    function drawHorizontalPageIndicator(dc as Dc, pageCount as Number, index as Number) as Void {
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
        var bgStroke = stroke + 2 * outlineWidth;
        var bgMinDeg = minDeg + deltaDeg - outlineWidthDeg;
        var bgMaxDeg = maxDeg + lengthDeg + outlineWidthDeg;

        // bg outline
        Graphite.setColor(dc, AppColors.BACKGROUND);
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
                Graphite.setColor(dc, AppColors.TEXT_TERTIARY);
            }

            Graphite.drawArcCentered(dc, edgeOffset, startDeg, endDeg);
        }

        Graphite.resetPenWidth(dc);
    }

    (:rectangle)
    function drawHorizontalPageIndicator(dc as Dc, pageCount as Number, index as Number) {
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
        Graphite.setColor(dc, AppColors.BACKGROUND);
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
                Graphite.setColor(dc, AppColors.TEXT_TERTIARY);
            }

            Graphite.fillRectangleCentered(dc, dc.getWidth() - edgeOffset, y, stroke, height);
        }
    }

    // page arrow

    function drawVerticalPageArrows(dc as Dc, pageCount as Number, index as Number,
        topColor as ColorType, bottomColor as ColorType) as Void {

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

    function drawTopPageArrow(dc as Dc) as Void {
        _drawPageArrow(dc, [ Graphite.getCenterX(dc), ARROW_EDGE_OFFSET ], _DIR_UP);
    }

    function drawBottomPageArrow(dc as Dc) as Void {
        _drawPageArrow(dc, [ Graphite.getCenterX(dc), dc.getHeight() - ARROW_EDGE_OFFSET ], _DIR_DOWN);
    }

    function drawUpArrow(dc as Dc, bottomTo as Numeric) as Void {
        _drawPageArrow(dc, [ Graphite.getCenterX(dc), bottomTo - ARROW_EDGE_OFFSET - ARROW_SIZE ], _DIR_UP);
    }

    function drawDownArrow(dc as Dc, bottomTo as Numeric) as Void {
        _drawPageArrow(dc, [ Graphite.getCenterX(dc), bottomTo - ARROW_EDGE_OFFSET ], _DIR_DOWN);
    }

    function _drawPageArrow(dc as Dc, point1 as Point2D, direction as Number) as Void {
        var width = ARROW_SIZE;
        var height = ARROW_SIZE;

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

}
