using Toybox.WatchUi;
using Toybox.Math;
using Carbon.Graphene;

class InfoView extends WatchUi.View {

    private var _text;

    // init

    function initialize(text) {
        View.initialize();
        _text = text;
    }

    // override View

    //! Load resources
    function onLayout(dc) {
    }

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    function onShow() {
    }

    //! Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        // draw
        dc.setAntiAlias(true);
        _draw(dc);
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
    }

    // draw

    function _draw(dc) {
        // invert colors
        Graphite.fillBackground(Graphene.COLOR_WHITE);

        // inscribe a square on the circular screen
        var margin = 5;
        var size = Math.sqrt(2) * (Graphite.getRadius(dc) - margin);
        var fonts = [ Graphene.FONT_TINY, Graphene.FONT_XTINY ];
        var justification = Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER;

        Graphite.drawTextArea(Graphite.getCenterX(dc), Graphite.getCenterY(dc), size, size, fonts, _text, justification, Graphene.COLOR_BLACK);
    }

}