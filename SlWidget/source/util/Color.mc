using Carbon.Graphene;

class Color {

    static const BACKGROUND = Graphene.COLOR_BLACK;
    static const BACKGROUND_INVERTED = Graphene.COLOR_WHITE;

    static const TEXT_PRIMARY = Graphene.COLOR_WHITE;
    static const TEXT_SECONDARY = Graphene.COLOR_LT_GRAY;
    static const TEXT_TERTIARY = Graphene.COLOR_DK_GRAY;

    static const TEXT_PRIMARY_INVERTED = Graphene.COLOR_BLACK;
    static const TEXT_SECONDARY_INVERTED = Graphene.COLOR_DK_GRAY;
    static const TEXT_TERTIARY_INVERTED = Graphene.COLOR_LT_GRAY;

    static const CONTROL_NORMAL = TEXT_TERTIARY;
    static const CONTROL_NORMAL_INVERTED = TEXT_TERTIARY_INVERTED;

    static const PRIMARY = Graphene.COLOR_CERULIAN;
    static const ON_PRIMARY = TEXT_PRIMARY_INVERTED;
    static const ON_PRIMARY_SECONDARY = Graphene.COLOR_DR_BLUE;
    static const ON_PRIMARY_TERTIARY = Graphene.COLOR_DK_BLUE;

    // departure

    static const DEPARTURE_METRO_RED = Graphene.COLOR_DR_RED;
    static const DEPARTURE_METRO_BLUE = Graphene.COLOR_DR_BLUE;
    static const DEPARTURE_METRO_GREEN = Graphene.COLOR_DR_GREEN;

    static const DEPARTURE_BUS_RED = Graphene.COLOR_RED;
    static const DEPARTURE_BUS_BLUE = Graphene.COLOR_BLUE;
    static const DEPARTURE_BUS_REPLACEMENT = Graphene.COLOR_VERMILION;

    static const DEPARTURE_TRAIN = Graphene.COLOR_MAGENTA;
    static const DEPARTURE_TRAM = Graphene.COLOR_AMBER;
    static const DEPARTURE_SHIP = Graphene.COLOR_CAPRI;

    static const DEPARTURE_NONE = Graphene.COLOR_BLACK;
    static const DEPARTURE_UNKNOWN = Graphene.COLOR_DK_GRAY;

    //

    static const DEVIATION = Graphene.COLOR_AMBER;

}
