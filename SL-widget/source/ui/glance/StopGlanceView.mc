using Toybox.WatchUi;
using Toybox.Graphics;
using Carbon.Graphene;

(:glance)
class StopGlanceView extends WatchUi.GlanceView {

    private var _viewModel;

    // init

    function initialize(viewModel) {
        GlanceView.initialize();
        _viewModel = viewModel;
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
        _viewModel.enableRequests();
    }

    //! Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        GlanceView.onUpdate(dc);

        // draw
        dc.setAntiAlias(true);
        _draw(dc);
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
        //_viewModel.disableRequests();
    }

    // draw

    private function _draw(dc) {
        _drawGlanceTitle(dc, _viewModel.getStopString());
    }

    private function _drawGlanceTitle(dc, text) {
        dc.drawText(0, 0, Graphene.FONT_XTINY, text, Graphics.TEXT_JUSTIFY_LEFT);
    }

}
