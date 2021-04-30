using Toybox.WatchUi;
using Toybox.Graphics;
using Carbon.Footprint as Footprint;
using Carbon.Graphite as Graphite;
using Carbon.Graphene as Graphene;
using Carbon.Chem as Chem;

class SlWidgetView extends WatchUi.View {

    private var _api = new SlApi();

    //

    function initialize() {
        View.initialize();
    }

    // override View

    //! Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.main_layout(dc));
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
        View.onUpdate(dc);
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
        var stop = SlApi.stops[SlApi.shownStopNr];
        var w = dc.getWidth();
        var h = dc.getHeight();
        var r = w / 2;

        Graphite.resetColor(dc);
        dc.drawText(w / 2, 25, Graphene.FONT_TINY, stop.name.toUpper(), Graphics.TEXT_JUSTIFY_CENTER);
        
        var font = Graphene.FONT_TINY;
        var fh = dc.getFontHeight(font);
        var offsetX = 10;
        var offsetY = 60;
        var rCircle = 4;
        
        for (var j = 0; j < 10 && j < stop.journeys.size(); j++) {
            var journey = stop.journeys[j];

            var yText = offsetY + j * fh;
            var yCircle = yText + fh / 2;
            if (yCircle > h - offsetY) {
                break;
            }

            var xCircle = Chem.minX(yCircle, r) + offsetX + rCircle;
            var xText = xCircle + rCircle + offsetX;

            Graphite.setColor(dc, journey.getColor());
            dc.fillCircle(xCircle, yCircle, rCircle);
            Graphite.resetColor(dc);
            dc.drawText(xText, yText, font, journey.print(), Graphics.TEXT_JUSTIFY_LEFT);
        }
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
