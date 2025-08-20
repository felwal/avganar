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

    const PRIMARY = Color64.DK_GREEN;
    const PRIMARY_DK = Color64.DR_GREEN;
    const PRIMARY_LT = Color64.LT_GREEN;

    const ON_PRIMARY = Color64.WHITE;
    const ON_PRIMARY_SECONDARY = Color64.LR_GREEN;
    const ON_PRIMARY_TERTIARY = Color64.LT_GREEN;

    const WARNING = Color64.VERMILION;
    const ERROR = Color64.RED;

    const DEPARTURE_REALTIME = Color64.GREEN;

    // mode/group

    const GROUP_BUS_EXPRESS_EXPRESS = Color64.CRIMSON;
    const GROUP_BUS_EXPRESS_AIRPORT = Color64.LT_YELLOW;

    const GROUP_TRAIN_LOCAL_LOCAL = Color64.CERISE;
    const GROUP_TRAIN_LOCAL_PAGA = Color64.PURPLE;

    const GROUP_TRAIN_REGIONAL_REGIONAL = Color64.GREEN;
    const GROUP_TRAIN_REGIONAL_INTERCITY = Color64.AQUAMARINE;
    const GROUP_TRAIN_REGIONAL_NATTAG = Color64.DK_SPRING;

    const GROUP_TRAIN_EXPRESS_EXPRESS = Color64.AMBER;
    const GROUP_TRAIN_EXPRESS_SNABBTAG = Color64.VERMILION;
    const GROUP_TRAIN_EXPRESS_AIRPORT = Color64.YELLOW;

    const GROUP_SHIP_LOCAL = Color64.CAPRI;
    const GROUP_SHIP_INTERNATIONAL = Color64.DK_AZURE;

    const MODE_BUS_LOCAL = Color64.RED;
    const MODE_METRO = Color64.DK_BLUE;
    const MODE_TRAM = Color64.DK_ORANGE;
    const MODE_OTHER = BACKGROUND;

}
