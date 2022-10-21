using Carbon.Graphene;

module AppColors {

    const BACKGROUND = Graphene.COLOR_BLACK;
    const BACKGROUND_INVERTED = Graphene.COLOR_WHITE;

    const TEXT_PRIMARY = Graphene.COLOR_WHITE;
    const TEXT_SECONDARY = Graphene.COLOR_LT_GRAY;
    const TEXT_TERTIARY = Graphene.COLOR_DK_GRAY;

    const TEXT_PRIMARY_INVERTED = Graphene.COLOR_BLACK;
    const TEXT_SECONDARY_INVERTED = Graphene.COLOR_DK_GRAY;
    const TEXT_TERTIARY_INVERTED = Graphene.COLOR_LT_GRAY;

    const CONTROL_NORMAL = TEXT_TERTIARY;
    const CONTROL_NORMAL_INVERTED = TEXT_TERTIARY_INVERTED;

    const PRIMARY = Graphene.COLOR_CERULIAN;
    const ON_PRIMARY = TEXT_PRIMARY_INVERTED;
    const ON_PRIMARY_SECONDARY = Graphene.COLOR_DR_BLUE;
    const ON_PRIMARY_TERTIARY = Graphene.COLOR_DK_BLUE;

    // departure

    const DEPARTURE_METRO_RED = Graphene.COLOR_DR_RED;
    const DEPARTURE_METRO_BLUE = Graphene.COLOR_DR_BLUE;
    const DEPARTURE_METRO_GREEN = Graphene.COLOR_DR_GREEN;

    const DEPARTURE_BUS_RED = Graphene.COLOR_RED;
    const DEPARTURE_BUS_BLUE = Graphene.COLOR_BLUE;
    const DEPARTURE_BUS_REPLACEMENT = Graphene.COLOR_VERMILION;

    const DEPARTURE_TRAIN = Graphene.COLOR_MAGENTA;
    const DEPARTURE_TRAM = Graphene.COLOR_AMBER;
    const DEPARTURE_SHIP = Graphene.COLOR_CAPRI;

    const DEPARTURE_NONE = Graphene.COLOR_BLACK;
    const DEPARTURE_UNKNOWN = Graphene.COLOR_DK_GRAY;

    //

    const DEVIATION = Graphene.COLOR_AMBER;

}
