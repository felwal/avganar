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

using Toybox.Graphics;
using Toybox.Math;
using Toybox.WatchUi;

(:glance)
function px(dp) {
    return Math.round(dp * rez(Rez.JsonData.pxPerDp));
}

//! The Graphite module provides extended drawing functionality
(:glance)
module Graphite {

    // tool

    function enableAntiAlias(dc) {
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }
    }

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
        return MathUtil.deg(pxToRad(px, r));
    }

    function degToY(dc, deg) {
        return (-Math.sin(MathUtil.rad(deg)) / 2 + 0.5) * dc.getHeight();
    }

    // color

    //! Set the current foreground color
    function setColor(dc, foreground) {
        dc.setColor(foreground, AppColors.BACKGROUND);
    }

    //! Set the current fg and bg colors to white and black
    function resetColor(dc) {
        dc.setColor(Graphene.COLOR_WHITE, AppColors.BACKGROUND);
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
        dc.fillRectangle(xCenter - Math.round(width / 2f), yCenter - Math.round(height / 2f), width, height);
    }

    // stroke shape

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

    // text

    function drawTextArea(dc, x, y, w, h, fonts, text, justification, color) {
        // compute location depending on justification, to match how `Dc#drawText` behaves
        var locX = justification&Graphics.TEXT_JUSTIFY_CENTER
            ? x - Math.round(w / 2f)
            : (justification&Graphics.TEXT_JUSTIFY_RIGHT ? x - w : x);
        var locY = justification&Graphics.TEXT_JUSTIFY_VCENTER ? y - Math.round(h / 2f) : y;

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

    function fillTextArea(dc, text, color) {
        // inscribe a square on the circular screen
        var margin = px(4);
        var size = Math.sqrt(2) * (Graphite.getRadius(dc) - margin);
        var fonts = [ Graphics.FONT_TINY, Graphics.FONT_XTINY ];
        var justification = Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER;

        drawTextArea(dc, getCenterX(dc), getCenterY(dc),
            size, size, fonts, text, justification, color);
    }

}
