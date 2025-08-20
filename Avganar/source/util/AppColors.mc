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

//! The colors used in the app.
module AppColors {

    const BACKGROUND = Color64.BLACK;
    const BACKGROUND_INVERTED = Color64.WHITE;

    const TEXT_PRIMARY = Color64.WHITE;
    const TEXT_SECONDARY = Color64.LT_GRAY;
    const TEXT_TERTIARY = Color64.DK_GRAY;
    const TEXT_INVERTED = Color64.BLACK;

    const PRIMARY = Color64.CERULIAN;
    const PRIMARY_DK = Color64.DR_BLUE;
    const PRIMARY_LT = Color64.LT_AZURE;

    const ON_PRIMARY = Color64.BLACK;
    const ON_PRIMARY_SECONDARY = Color64.DR_BLUE;
    const ON_PRIMARY_TERTIARY = Color64.DK_BLUE;

    const WARNING = Color64.VERMILION;
    const ERROR = Color64.RED;

    // departure

    const DEPARTURE_REALTIME = Color64.GREEN;
    const DEPARTURE_SELECTED = Color64.GREEN;

    // mode/group

    const GROUP_BUS_RED = Color64.RED;
    const GROUP_BUS_BLUE = Color64.BLUE;
    const GROUP_BUS_REPLACEMENT = WARNING;

    const GROUP_METRO_RED = Color64.DR_RED;
    const GROUP_METRO_BLUE = Color64.DR_BLUE;
    const GROUP_METRO_GREEN = Color64.DR_GREEN;

    const GROUP_TRAM_SPARVAGCITY = Color64.DK_GRAY;
    const GROUP_TRAM_NOCKEBYBANAN = Color64.LT_GRAY;
    const GROUP_TRAM_LIDINGOBANAN = Color64.AMBER;
    const GROUP_TRAM_TVARBANAN = Color64.DK_ORANGE;
    const GROUP_TRAM_SALTSJOBANAN = Color64.DK_CYAN;
    const GROUP_TRAM_ROSLAGSBANAN = Color64.DK_VIOLET;

    const MODE_TRAIN = Color64.CERISE;
    const MODE_SHIP = Color64.CAPRI;
    const MODE_OTHER = BACKGROUND;

}
