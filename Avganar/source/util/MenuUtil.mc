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

module MenuUtil {

    const HEIGHT_FOOTER_SMALL = px(42);
    const HEIGHT_FOOTER_LARGE = px(84);

    function drawPanedList(dc as Dc, items as Array<String>, paneSize as Number, cursor as Number,
        paneHints as [String, String], mainHints as [String, String], topHint as String,
        paneColors as ColorTheme, mainColors as ColorTheme) as Void {

        _drawPanedListPanes(dc, paneSize, items.size(), cursor, paneHints, mainHints, topHint,
            paneColors, mainColors);

        _drawPanedListItems(dc, items, paneSize, cursor, paneColors, mainColors);
    }

    function _drawPanedListPanes(dc as Dc, paneSize as Number, fullSize as Number, cursor as Number,
        paneHints as [String, String], mainHints as [String, String], topHint as String,
        paneColors as ColorTheme, mainColors as ColorTheme) as Void {

        var paneHint = paneHints[0];
        var mainHint = mainHints[0];

        var hasPane = paneSize != 0;
        var hasMain = paneSize != fullSize;

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
            DrawUtil.fillBackground(dc, paneColors[0]);

            // top header
            if (cursor == 0) {
                WidgetUtil.drawHeader(dc, HEIGHT_FOOTER_LARGE, AppColors.BACKGROUND, paneStrokeColor, topHint, AppColors.TEXT_PRIMARY);
            }
            else if (cursor == 1) {
                WidgetUtil.drawHeader(dc, HEIGHT_FOOTER_SMALL, mainColors[0], paneStrokeColor, null, null);
                DrawUtil.setColor(dc, mainColors[3]);
                WidgetUtil.drawUpArrow(dc, HEIGHT_FOOTER_SMALL);
            }
            else {
                DrawUtil.setColor(dc, paneColors[3]);
                WidgetUtil.drawTopPageArrow(dc);
            }

            // bottom header
            if (cursor == paneSize - 2) {
                WidgetUtil.drawFooter(dc, HEIGHT_FOOTER_SMALL, mainColors[0], paneStrokeColor, null, null);
                DrawUtil.setColor(dc, paneColors[3]);
                WidgetUtil.drawDownArrow(dc, dc.getHeight() - HEIGHT_FOOTER_SMALL);
            }
            else if (cursor == paneSize - 1) {
                WidgetUtil.drawFooter(dc, HEIGHT_FOOTER_LARGE, mainColors[0], paneStrokeColor, mainHint, mainColors[3]);
                DrawUtil.setColor(dc, paneColors[3]);
                WidgetUtil.drawDownArrow(dc, dc.getHeight() - HEIGHT_FOOTER_LARGE);
            }
            else {
                DrawUtil.setColor(dc, paneColors[3]);
                WidgetUtil.drawBottomPageArrow(dc);
            }
        }

        // outside pane
        else {
            DrawUtil.fillBackground(dc, mainColors[0]);

            // top header
            if (cursor == paneSize) {
                WidgetUtil.drawHeader(dc, HEIGHT_FOOTER_LARGE, paneColors[0], paneStrokeColor, paneHint, paneColors[3]);
                DrawUtil.setColor(dc, paneColors[3]);
                // (app specific) show up arrow even if pane is empty,
                // to indicate navigation to empty page dialog
                WidgetUtil.drawUpArrow(dc, HEIGHT_FOOTER_LARGE);
            }
            else if (cursor == paneSize + 1) {
                WidgetUtil.drawHeader(dc, HEIGHT_FOOTER_SMALL, paneColors[0], paneStrokeColor, null, null);
                DrawUtil.setColor(dc, paneColors[3]);
                WidgetUtil.drawUpArrow(dc, HEIGHT_FOOTER_SMALL);
            }
            else {
                DrawUtil.setColor(dc, mainColors[3]);
                WidgetUtil.drawTopPageArrow(dc);
            }

            // bottom header
            if (hasMain && cursor != fullSize - 1) {
                DrawUtil.setColor(dc, mainColors[3]);
                WidgetUtil.drawBottomPageArrow(dc);
            }
        }
    }

    function _drawPanedListItems(dc as Dc, items as Array<String>, paneSize as Number, cursor as Number,
        paneColors as ColorTheme, mainColors as ColorTheme) as Void {

        var fontsSelected = [ Graphics.FONT_LARGE, Graphics.FONT_MEDIUM, Graphics.FONT_SMALL,
            Graphics.FONT_TINY, Graphics.FONT_XTINY ];

        var font = Graphics.FONT_TINY;
        var h = dc.getHeight() - 2 * px(36);
        var lineHeightPx = h / 4f;

        var bgColor = cursor >= paneSize ? mainColors[0] : paneColors[0];
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
                var margin = px(4);
                var width = dc.getWidth() - 2 * margin;
                var height = dc.getFontHeight(fontsSelected[0]);

                DrawUtil.drawTextArea(dc, DrawUtil.getCenterX(dc), DrawUtil.getCenterY(dc), width, height,
                    fontsSelected, item, justification, selectedColor);
            }
            else {
                var yText = DrawUtil.getCenterY(dc) + (i - cursor) * lineHeightPx;

                dc.setColor(unselectedColor, bgColor);
                dc.drawText(DrawUtil.getCenterX(dc), yText, font, item, justification);
            }
        }
    }

    function drawSideMenu(dc as Dc, items as Array<String>, cursor as Number,
        blackBg as Boolean) as Void {

        var colorBg = blackBg ? AppColors.BACKGROUND : AppColors.BACKGROUND_INVERTED;
        var colorSelected = blackBg ? AppColors.TEXT_PRIMARY : AppColors.TEXT_INVERTED;
        var colorUnselected = blackBg ? AppColors.TEXT_SECONDARY: AppColors.TEXT_TERTIARY;

        var h = dc.getHeight();
        var w = dc.getWidth();
        var xBg = px(62);
        var wBorder = px(2);
        var wIndicator = px(4);
        var hIndicator = HEIGHT_FOOTER_SMALL;

        // bg
        DrawUtil.setColor(dc, colorBg);
        dc.fillRectangle(xBg, 0, w - xBg, h);

        // border
        DrawUtil.setColor(dc, colorSelected);
        dc.fillRectangle(xBg - wBorder, 0, wBorder, dc.getHeight());

        // indicator
        dc.fillRectangle(xBg + px(3), h / 2 - hIndicator / 2, wIndicator, hIndicator);

        // draw items

        var fontSelected =  Graphics.FONT_MEDIUM;
        var font = Graphics.FONT_SMALL;
        var lineHeight = (h - 2 * px(20)) / 5;
        var xText = xBg + px(10);

        // only draw 2 items above and 2 below cursor
        var itemOffset = 2;
        var firstItemIndex = MathUtil.max(0, cursor - itemOffset);
        var lastItemIndex = MathUtil.min(items.size(), cursor + itemOffset + 1);

        // draw the items
        for (var i = firstItemIndex; i < lastItemIndex; i++) {
            var item = items[i];

            var justification = Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER;
            var yText = DrawUtil.getCenterY(dc) + (i - cursor) * lineHeight;
            var margin = px(4);

            if (i == cursor) {
                dc.setColor(colorSelected, colorBg);
                dc.drawText(xText, yText, fontSelected, item, justification);
            }
            else {
                dc.setColor(colorUnselected, colorBg);
                dc.drawText(xText, yText, font, item, justification);
            }
        }
    }

}
