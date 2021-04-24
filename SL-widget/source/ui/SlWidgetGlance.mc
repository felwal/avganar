using Toybox.WatchUi;
using Toybox.Graphics;

(:glance)
class SlWidgetGlance extends WatchUi.GlanceView {

    function initialize() {
        GlanceView.initialize();
    }

    // Load resources
    function onLayout(dc) {
        setLayout(Rez.Layouts.glance_layout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        GlanceView.onUpdate(dc);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(0, 0, Graphics.FONT_GLANCE, "Next departure in...", Graphics.TEXT_JUSTIFY_LEFT);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

}
