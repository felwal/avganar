using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Timer;
using Carbon.Footprint as Footprint;
using Carbon.Graphite as Graphite;
using Carbon.Graphene as Graphene;

(:glance)
class SlWidgetGlance extends WatchUi.GlanceView {

    private var _api = new SlApi();
    private var _timer = new Timer.Timer();

    private static const REQUEST_TIME = 30000;

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
        // set location event listener and get last location while waiting
        Position.enableLocationEvents(Position.LOCATION_ONE_SHOT, method(:onPosition));
        Footprint.getLastKnownLocation(Activity.getActivityInfo());

        // add placeholder stops
        for (var i = 0; i < SlApi.stops.size(); i++) {
            SlApi.stops[i] = new Stop(-1, "searching...");
        }
        SlApi.shownStopNr = 0;

        // make initial request (crashes if done too early)
        new Timer.Timer().start(method(:makeRequests), 500, false);
        // start continious request timer
        _timer.start(method(:makeRequests), REQUEST_TIME, true);
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
        // stop callbacks
        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
        _timer.stop();
    }

    // draw

    function draw(dc) {
        Graphite.resetColor(dc);
        var string = SlApi.stops[0].printForGlance();
        dc.drawText(0, 0, Graphene.FONT_XTINY, string, Graphics.TEXT_JUSTIFY_LEFT);
    }

    // request

    //! Make requests to SlApi neccessary for glance display
    function makeRequests() {
        _api.requestNearbyStops(Footprint.latDeg(), Footprint.lonDeg());
    }

    // listener

    //! Location event listener
    function onPosition(info) {
        Footprint.onPosition(info);
    }

}
