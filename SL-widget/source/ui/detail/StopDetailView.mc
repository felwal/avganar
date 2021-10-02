using Toybox.WatchUi;
using Toybox.Graphics;
using Carbon.Graphene as Graphene;
using Carbon.Chem as Chem;

class StopDetailView extends WatchUi.View {

    private var _viewModel;

    // init

    function initialize(container) {
        View.initialize();
        _viewModel = container.stopDetailViewModel;
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
        _viewModel.enableRequests();
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
        _viewModel.disableRequests();
    }

    // draw

    private function _draw(dcc) {
        var stop = _viewModel.getSelectedStop();

        // text
        dcc.drawViewTitle(stop.name);
        _drawDepartures(dcc);

        // widget
        dcc.drawHorizontalPageIndicator(_viewModel.getModeCount(), _viewModel.modeCursor);
        dcc.drawVerticalPageIndicator(_viewModel.getStopCount(), _viewModel.stopCursor);
    }

    private function _drawDepartures(dcc) {
        var font = Graphene.FONT_XTINY;
        var fh = dcc.dc.getFontHeight(font);
        var lineHeight = 1.5;
        var offsetX = 10;
        var offsetY = 64;
        var rCircle = 4;

        var departures = _viewModel.getSelectedDepartures();

        for (var j = 0; j < 10 && j < _viewModel.getSelectedDepartureCount(); j++) {
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
