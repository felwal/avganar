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

//! The Graphene module contains extended (quaternary) color constants
(:glance)
module Graphene {

    // abbreviations:
    // - DR: darker (value)
    // - DK: dark (value)
    // - LT: light (value)
    // - LR: lighter (value)
    // - WK: weak (chroma)

    // RGB mono
    const COLOR_BLACK = 0x000000; // Graphics.COLOR_BLACK
    const COLOR_DK_GRAY = 0x555555; // Graphics.COLOR_DK_GRAY
    const COLOR_LT_GRAY = 0xAAAAAA; // Graphics.COLOR_LT_GRAY
    const COLOR_WHITE = 0xFFFFFF; // Graphics.COLOR_WHITE

    // structure:
    // * primary
    // **** quaternary
    // *** tertiary
    // **** quaternary
    // ** secondary
    // **** quaternary
    // *** tertiary
    // **** quaternary
    // * primary

    // R red
    const COLOR_DR_RED = 0x550000;
    const COLOR_DK_RED = 0xAA0000; // Graphics.COLOR_DK_RED
    const COLOR_RED = 0xFF0000; // Graphics.COLOR_RED
    const COLOR_LT_RED = 0xFF5555;
    const COLOR_LR_RED = 0xFFAAAA;
    const COLOR_WK_RED = 0xAA5555;

    // RGRR vermilion
    const COLOR_VERMILION = 0xFF5500; // Graphics.COLOR_ORANGE

    // RGR orange
    const COLOR_DK_ORANGE = 0xAA5500;
    const COLOR_LT_ORANGE = 0xFFAA55;

    // RGRG amber
    const COLOR_AMBER = 0xFFAA00; // Graphics.COLOR_YELLOW

    // RG yellow
    const COLOR_DR_YELLOW = 0x555500;
    const COLOR_DK_YELLOW = 0xAAAA00;
    const COLOR_YELLOW = 0xFFFF00;
    const COLOR_LT_YELLOW = 0xFFFF55;
    const COLOR_LR_YELLOW = 0xFFFFAA;
    const COLOR_WK_YELLOW = 0xAAAA55;

    // RGGR lime
    const COLOR_LIME = 0xAAFF00;

    // RGG chartreuse
    const COLOR_DK_CHARTREUSE = 0x55AA00;
    const COLOR_LT_CHARTREUSE = 0xAAFF55;

    // RGGG harlequin
    const COLOR_HARLEQUIN = 0x55FF00;

    // G green
    const COLOR_DR_GREEN = 0x005500;
    const COLOR_DK_GREEN = 0x00AA00; // Graphics.COLOR_DK_GREEN
    const COLOR_GREEN = 0x00FF00; // Graphics.COLOR_GREEN
    const COLOR_LT_GREEN = 0x55FF55;
    const COLOR_LR_GREEN = 0xAAFFAA;
    const COLOR_WK_GREEN = 0x55AA55;

    // GBGG erin
    const COLOR_ERIN = 0x00FF55;

    // GBG spring green
    const COLOR_DK_SPRING = 0x00AA55;
    const COLOR_LT_SPRING = 0x55FFAA;

    // GBGG aquamarine
    const COLOR_AQUAMARINE = 0x00FFAA;

    // GB cyan
    const COLOR_DR_CYAN = 0x005555;
    const COLOR_DK_CYAN = 0x00AAAA;
    const COLOR_CYAN = 0x00FFFF;
    const COLOR_LT_CYAN = 0x55FFFF;
    const COLOR_LR_CYAN = 0xAAFFFF;
    const COLOR_WK_CYAN = 0x55AAAA;

    // GBBG capri
    const COLOR_CAPRI = 0x00AAFF; // Graphics.COLOR_BLUE

    // GBB azure
    const COLOR_DK_AZURE = 0x0055AA;
    const COLOR_LT_AZURE = 0x55AAFF;

    // GBBB cerulian
    const COLOR_CERULIAN = 0x0055FF;

    // B blue
    const COLOR_DR_BLUE = 0x000055;
    const COLOR_DK_BLUE = 0x0000AA;
    const COLOR_BLUE = 0x0000FF; // Graphics.COLOR_DK_BLUE
    const COLOR_LT_BLUE = 0x5555FF;
    const COLOR_LR_BLUE = 0xAAAAFF;
    const COLOR_WK_BLUE = 0x5555AA;

    // RBBB indigo
    const COLOR_INDIGO = 0x5500FF;

    // RBB violet
    const COLOR_DK_VIOLET = 0x5500AA;
    const COLOR_LT_VIOLET = 0xAA55FF;

    // RBBR purple
    const COLOR_PURPLE = 0xAA00FF; // Graphics.COLOR_PURPLE

    // RB magenta
    const COLOR_DR_MAGENTA = 0x550055;
    const COLOR_DK_MAGENTA = 0xAA00AA;
    const COLOR_MAGENTA = 0xFF00FF; // Graphics.COLOR_PINK
    const COLOR_LT_MAGENTA = 0xFF55FF;
    const COLOR_LR_MAGENTA = 0xFFAAFF;
    const COLOR_WK_MAGENTA = 0xAA55AA;

    // RBRB cerise
    const COLOR_CERISE = 0xFF00AA;

    // RBR rose
    const COLOR_DK_ROSE = 0xAA0055;
    const COLOR_LT_ROSE = 0xFF55AA;

    // RBRR crimson
    const COLOR_CRIMSON = 0xFF0055;

}
