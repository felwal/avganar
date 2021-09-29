using Toybox.WatchUi;
using Toybox.Graphics;
using Carbon.Graphene as Graphene;
using Carbon.Chem as Chem;

class StopDetailView extends WatchUi.View {

    private var _model;

    //

    function initialize(container) {
        View.initialize();
        _model = container.stopDetailViewModel;
    }

    // override View

    //! Load resources
    function onLayout(dc) {
        setLayout(Rez.Layouts.main_layout(dc));
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
        View.onUpdate(dc);

        // draw
        dc.setAntiAlias(true);
        _draw(new DcCompat(dc));
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
        _model.disableRequests();
    }

    // draw

    private function _draw(dcc) {
        var stop = _model.getSelectedStop();

        // text
        dcc.drawViewTitle(stop.name);
        _drawDepartures(dcc);

        // widget
        dcc.drawHorizontalPageIndicator(_model.getModeCount(), _model.modeCursor);
        dcc.drawVerticalPageIndicator(_model.getStopCount(), _model.stopCursor);
    }

    private function _drawDepartures(dcc) {
        var font = Graphene.FONT_XTINY;
        var fh = dcc.dc.getFontHeight(font);
        var lineHeight = 1.5;
        var offsetX = 10;
        var offsetY = 64;
        var rCircle = 4;

        var departures = _model.getSelectedDepartures();

        for (var j = 0; j < 10 && j < _model.getSelectedDepartureCount(); j++) {
            var departure = departures[j];

            var yText = offsetY + j * fh * lineHeight;
            var yCircle = yText + fh / 2;
            /*if (yCircle > h - offsetY) {
                break;
            }*/

            var xCircle = Chem.minX(offsetY + fh / 2, dcc.r) + offsetX + rCircle;
            var xText = xCircle + rCircle + offsetX;

            dcc.setColor(departure.getColor());
            dcc.dc.fillCircle(xCircle, yCircle, rCircle);
            dcc.resetColor();
            dcc.dc.drawText(xText, yText, font, departure.toString(), Graphics.TEXT_JUSTIFY_LEFT);
        }
    }

}
