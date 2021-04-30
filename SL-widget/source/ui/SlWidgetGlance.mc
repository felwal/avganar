using Toybox.WatchUi;
using Toybox.Graphics;
using Carbon.Footprint as Footprint;
using Carbon.Graphite as Graphite;
using Carbon.Graphene as Graphene;

(:glance)
class SlWidgetGlance extends WatchUi.GlanceView {

    private var _api = new SlApi();

    //

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
        for (var i = 0; i < SlApi.stops.size(); i++) {
            SlApi.stops[i] = new Stop(-1, "searching...");
        }

        SlApi.shownStopNr = 0;
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
        Graphite.resetColor(dc);
        var string = SlApi.stops[0].printForGlance();
        dc.drawText(0, 0, Graphene.FONT_XTINY, string, Graphics.TEXT_JUSTIFY_LEFT);
    }
    
    // requests

    //! Make requests to SlApi neccessary for glance display
    function makeRequests() {
        _api.requestNearbyStops(Footprint.latDeg(), Footprint.lonDeg());
    }

    // listeners

    //! Location event listener
    function onPosition(info) {
        Footprint.onPosition(info);

        // TODO: update with interval instead of here
        makeRequests();
    }

}
