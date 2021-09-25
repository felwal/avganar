using Toybox.WatchUi;
using Toybox.Graphics;
using Carbon.Graphite as Graphite;
using Carbon.Graphene as Graphene;

(:glance)
class StopGlanceView extends WatchUi.GlanceView {

    private var _model;

    //

    function initialize(container) {
        GlanceView.initialize();
        _model = container.stopGlanceViewModel;
    }

    // override GlanceView

    //! Load resources
    function onLayout(dc) {
        setLayout(Rez.Layouts.glance_layout(dc));
    }

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    function onShow() {
        _model.enableRequests();
    }

    //! Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        GlanceView.onUpdate(dc);

        // draw
        dc.setAntiAlias(true);
        draw(dc);
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
        _model.disableRequests();
    }

    // draw

    function draw(dc) {
        Graphite.resetColor(dc);
        var string = _model.getStopString();
        dc.drawText(0, 0, Graphene.FONT_XTINY, string, Graphics.TEXT_JUSTIFY_LEFT);
    }

}
