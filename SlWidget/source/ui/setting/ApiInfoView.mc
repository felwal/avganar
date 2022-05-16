using Toybox.WatchUi;
using Toybox.Math;
using Carbon.Graphene;

class ApiInfoView extends WatchUi.View {

    private var textArea;

    // init

    function initialize() {
        View.initialize();
    }

    // override View

    //! Load resources
    function onLayout(dc) {
        setLayout(Rez.Layouts.apiinfo_layout(dc));
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
        _draw(new DcCompat(dc));
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
    }

    // draw

    function _draw(dcc) {
        // invert colors
        dcc.fillBackground(Graphene.COLOR_WHITE);

        // inscribe a square on the circular screen
        var margin = 5;
        var y = (dcc.r - margin) / Math.sqrt(2);
        var x = -y;
        var size = 2 * y;

        textArea = new WatchUi.TextArea({
            :text => rez(Rez.Strings.lbl_apiinfo_info),
            :color => Graphene.COLOR_BLACK,
            :font => [ Graphene.FONT_TINY, Graphene.FONT_XTINY ],
            :locX => dcc.cx + x,
            :locY => dcc.cy - y,
            :width => size,
            :height => size
        });

        textArea.setJustification(Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        textArea.draw(dcc.dc);
    }

}
