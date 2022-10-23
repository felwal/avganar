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
    }

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    function onShow() {
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
    }

    // draw

    private function _draw(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

        _drawGlanceTitle(dc, _viewModel.getTitle());
        _drawGlanceCaption(dc, _viewModel.getCaption());
    }

    private function _drawGlanceTitle(dc, text) {
        dc.drawText(0, 8, Graphene.FONT_XTINY, text.toUpper(), Graphics.TEXT_JUSTIFY_LEFT);
    }

    private function _drawGlanceCaption(dc, text) {
        var font = Graphics.FONT_TINY;
        var fontHeight = dc.getFontHeight(font);

        dc.drawText(0, dc.getHeight() - fontHeight - 4, font, text, Graphics.TEXT_JUSTIFY_LEFT);
    }

}
