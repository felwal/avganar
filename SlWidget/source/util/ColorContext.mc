using Carbon.Graphene;

class ColorContext {

    var background;
    var textPrimary;
    var textSecondary;
    var textTertiary;

    //

    function initialize(background, textPrimary, textSecondary, textTertiary) {
        self.background = background;
        self.textPrimary = textPrimary;
        self.textSecondary = textSecondary;
        self.textTertiary = textTertiary;
    }

    static function black() {
        return new ColorContext(Graphene.COLOR_BLACK, Graphene.COLOR_WHITE, Graphene.COLOR_LT_GRAY, Graphene.COLOR_DK_GRAY);
    }

    static function white() {
        return new ColorContext(Graphene.COLOR_WHITE, Graphene.COLOR_BLACK, Graphene.COLOR_DK_GRAY, Graphene.COLOR_LT_GRAY);
    }

}
