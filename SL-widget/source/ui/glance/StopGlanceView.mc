using Toybox.WatchUi;
using Toybox.Graphics;
using Carbon.Graphene as Graphene;

(:glance)
class StopGlanceView extends WatchUi.GlanceView {

    private var _viewModel;

    // init

    function initialize(container) {
        GlanceView.initialize();
        _viewModel = container.stopGlanceViewModel;
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
        _draw(new DcCompat(dc));
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
        _viewModel.disableRequests();
    }

    // draw

    private function _draw(dcc) {
        dcc.drawGlanceTitle(_viewModel.getStopString());
    }

}
