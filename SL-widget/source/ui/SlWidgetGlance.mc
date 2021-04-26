using Toybox.WatchUi;
using Toybox.Graphics;
using Carbon.Footprint as Footprint;

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
        // set location event listener
        Position.enableLocationEvents(Position.LOCATION_ONE_SHOT, method(:onPosition));
        // get last location while waiting for location event
        Footprint.getLastKnownLocation(Activity.getActivityInfo());
        
        // add placeholder stops
        for (var i = 0; i < SlApi.stopCount; i++) {
            SlApi.stops[i] = new Stop(-1, "searching...");
        }
        
        makeRequests();
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
        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
    }
    
    // draw
    
    function draw(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        var string = "";
        for (var i = 0; i < 1 && i < SlApi.stopCount; i++) {
            string += SlApi.stops[i].name + "\n";
        }
        dc.drawText(0, 0, Graphics.FONT_GLANCE, string, Graphics.TEXT_JUSTIFY_LEFT);
    }
    
    // requests
    
    //! Make requests to SlApi neccessary for glance display
    function makeRequests() {
        SlApi.requestNearbyStops(***REMOVED***, ***REMOVED***);
    }
    
    // listeners

    //! Location event listener
    function onPosition(info) {
        Footprint.onPosition(info);
        
        // update
        WatchUi.requestUpdate();
        makeRequests();
    }
    

}
