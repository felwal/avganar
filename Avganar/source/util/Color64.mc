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

//! The Color64 module contains constants for the quaternary color palette
(:glance)
module Color64 {

    // abbreviations:
    // - DR: darker (value)
    // - DK: dark (value)
    // - LT: light (value)
    // - LR: lighter (value)
    // - WK: weak (chroma)

    // RGB mono
    const BLACK = 0x000000; // Graphics.COLOR_BLACK
    const DK_GRAY = 0x555555; // Graphics.COLOR_DK_GRAY
    const LT_GRAY = 0xAAAAAA; // Graphics.COLOR_LT_GRAY
    const WHITE = 0xFFFFFF; // Graphics.COLOR_WHITE

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
    const DR_RED = 0x550000;
    const DK_RED = 0xAA0000; // Graphics.COLOR_DK_RED
    const RED = 0xFF0000; // Graphics.COLOR_RED
    const LT_RED = 0xFF5555;
    const LR_RED = 0xFFAAAA;
    const WK_RED = 0xAA5555;

    // RGRR vermilion
    const VERMILION = 0xFF5500; // Graphics.COLOR_ORANGE

    // RGR orange
    const DK_ORANGE = 0xAA5500;
    const LT_ORANGE = 0xFFAA55;

    // RGRG amber
    const AMBER = 0xFFAA00; // Graphics.COLOR_YELLOW

    // RG yellow
    const DR_YELLOW = 0x555500;
    const DK_YELLOW = 0xAAAA00;
    const YELLOW = 0xFFFF00;
    const LT_YELLOW = 0xFFFF55;
    const LR_YELLOW = 0xFFFFAA;
    const WK_YELLOW = 0xAAAA55;

    // RGGR lime
    const LIME = 0xAAFF00;

    // RGG chartreuse
    const DK_CHARTREUSE = 0x55AA00;
    const LT_CHARTREUSE = 0xAAFF55;

    // RGGG harlequin
    const HARLEQUIN = 0x55FF00;

    // G green
    const DR_GREEN = 0x005500;
    const DK_GREEN = 0x00AA00; // Graphics.COLOR_DK_GREEN
    const GREEN = 0x00FF00; // Graphics.COLOR_GREEN
    const LT_GREEN = 0x55FF55;
    const LR_GREEN = 0xAAFFAA;
    const WK_GREEN = 0x55AA55;

    // GBGG erin
    const ERIN = 0x00FF55;

    // GBG spring green
    const DK_SPRING = 0x00AA55;
    const LT_SPRING = 0x55FFAA;

    // GBGG aquamarine
    const AQUAMARINE = 0x00FFAA;

    // GB cyan
    const DR_CYAN = 0x005555;
    const DK_CYAN = 0x00AAAA;
    const CYAN = 0x00FFFF;
    const LT_CYAN = 0x55FFFF;
    const LR_CYAN = 0xAAFFFF;
    const WK_CYAN = 0x55AAAA;

    // GBBG capri
    const CAPRI = 0x00AAFF; // Graphics.COLOR_BLUE

    // GBB azure
    const DK_AZURE = 0x0055AA;
    const LT_AZURE = 0x55AAFF;

    // GBBB cerulian
    const CERULIAN = 0x0055FF;

    // B blue
    const DR_BLUE = 0x000055;
    const DK_BLUE = 0x0000AA;
    const BLUE = 0x0000FF; // Graphics.COLOR_DK_BLUE
    const LT_BLUE = 0x5555FF;
    const LR_BLUE = 0xAAAAFF;
    const WK_BLUE = 0x5555AA;

    // RBBB indigo
    const INDIGO = 0x5500FF;

    // RBB violet
    const DK_VIOLET = 0x5500AA;
    const LT_VIOLET = 0xAA55FF;

    // RBBR purple
    const PURPLE = 0xAA00FF; // Graphics.COLOR_PURPLE

    // RB magenta
    const DR_MAGENTA = 0x550055;
    const DK_MAGENTA = 0xAA00AA;
    const MAGENTA = 0xFF00FF; // Graphics.COLOR_PINK
    const LT_MAGENTA = 0xFF55FF;
    const LR_MAGENTA = 0xFFAAFF;
    const WK_MAGENTA = 0xAA55AA;

    // RBRB cerise
    const CERISE = 0xFF00AA;

    // RBR rose
    const DK_ROSE = 0xAA0055;
    const LT_ROSE = 0xFF55AA;

    // RBRR crimson
    const CRIMSON = 0xFF0055;

}
