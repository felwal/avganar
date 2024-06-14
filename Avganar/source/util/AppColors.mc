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

    const BACKGROUND = Graphene.COLOR_BLACK;
    const BACKGROUND_INVERTED = Graphene.COLOR_WHITE;

    const TEXT_PRIMARY = Graphene.COLOR_WHITE;
    const TEXT_SECONDARY = Graphene.COLOR_LT_GRAY;
    const TEXT_TERTIARY = Graphene.COLOR_DK_GRAY;
    const TEXT_INVERTED = Graphene.COLOR_BLACK;

    const PRIMARY = Graphene.COLOR_DK_GREEN;
    const PRIMARY_DK = Graphene.COLOR_DR_GREEN;
    const PRIMARY_LT = Graphene.COLOR_LT_GREEN;

    const ON_PRIMARY = Graphene.COLOR_WHITE;
    const ON_PRIMARY_SECONDARY = Graphene.COLOR_LR_GREEN;
    const ON_PRIMARY_TERTIARY = Graphene.COLOR_LT_GREEN;

    const WARNING = Graphene.COLOR_VERMILION;
    const ERROR = Graphene.COLOR_RED;

    const DEPARTURE_REALTIME = Graphene.COLOR_GREEN;

    // mode

    const MODE_BUS_LOCAL = Graphene.COLOR_RED;
    const MODE_BUS_EXPRESS = Graphene.COLOR_LT_RED;
    const MODE_METRO = Graphene.COLOR_BLUE;
    const MODE_TRAIN_LOCAL = Graphene.COLOR_CERISE;
    const MODE_TRAIN_REGIONAL = Graphene.COLOR_GREEN;
    const MODE_TRAIN_EXPRESS = Graphene.COLOR_YELLOW;
    const MODE_TRAM = Graphene.COLOR_DK_ORANGE;
    const MODE_SHIP = Graphene.COLOR_CAPRI;
    const MODE_OTHER = Graphene.COLOR_LT_GRAY;

}
