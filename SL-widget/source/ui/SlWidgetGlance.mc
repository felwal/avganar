using Toybox.WatchUi;
using Toybox.Graphics;

(:glance)
class SlWidgetGlance extends WatchUi.GlanceView {

    function initialize() {
        GlanceView.initialize();
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
        // make request
        SlApi.requestNearbyStops(59.626429, 17.793671);
    }

    //! Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        GlanceView.onUpdate(dc);

        draw(dc);
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
    }
    
    // draw
    
    function draw(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        var string = "";
        for (var i = 0; i < 2 && i < SlApi.stopCount; i++) {
            string += SlApi.stops[i].name + "\n";
        }
        dc.drawText(0, 0, Graphics.FONT_GLANCE, string, Graphics.TEXT_JUSTIFY_LEFT);
    }

}
