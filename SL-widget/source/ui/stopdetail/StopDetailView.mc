using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Carbon.Graphene;
using Carbon.Chem;

class StopDetailView extends WatchUi.View {

    private var _viewModel;

    // init

    function initialize(viewModel) {
        View.initialize();
        _viewModel = viewModel;
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
        _draw(new Dk(dc));
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
        _viewModel.disableRequests();
    }

    // draw

    private function _draw(dk) {
        var stop = _viewModel.getSelectedStop();

        // text
        dk.drawViewTitle(stop.name);
        _drawDepartures(dk);
        _drawGpsStatus(dk);
        _drawClockTime(dk);

        // hori indicator
        dk.drawHorizontalPageIndicator(_viewModel.getModeCount(), _viewModel.modeCursor);

        // vert indicator
        dk.drawVerticalPageNumber(_viewModel.getStopCount(), _viewModel.stopCursor);
        dk.drawVerticalPageArrows(_viewModel.getStopCount(), _viewModel.stopCursor);
        dk.drawVerticalScrollbarMedium(_viewModel.getStopCount(), _viewModel.stopCursor);

        // banner
        if (!stop.hasConnection()) {
            dk.drawExclamationBanner();
        }

        // start indicator
        if (stop.areStopsRerequestable() || stop.areDeparturesRerequestable()) {
            dk.drawStartIndicatorWithBitmap(Rez.Drawables.ic_refresh);
        }
    }

    private function _drawDepartures(dk) {
        var font = Graphene.FONT_XTINY;
        var fh = dk.dc.getFontHeight(font);
        var lineHeight = 1.5;
        var offsetX = 10;
        var offsetY = 60;
        var rCircle = 4;

        var departures = _viewModel.getSelectedDepartures();

        for (var d = 0; d < 5 && d < _viewModel.getSelectedDepartureCount(); d++) {
            var departure = departures[d];

            var yText = offsetY + d * fh * lineHeight;
            var yCircle = yText + fh / 2;
            /*if (yCircle > h - offsetY) {
                break;
            }*/

            var xCircle = Chem.minX(offsetY + fh / 2, dk.r) + offsetX + rCircle;
            var xText = xCircle + rCircle + offsetX;

            dk.setColor(departure.getColor());
            dk.dc.fillCircle(xCircle, yCircle, rCircle);
            dk.resetColor();
            dk.dc.drawText(xText, yText, font, departure.toString(), Graphics.TEXT_JUSTIFY_LEFT);
        }
    }

    private function _drawGpsStatus(dk) {
        var font = Graphene.FONT_XTINY;
        var fh = dk.dc.getFontHeight(font);
        var arrowEdgeOffset = 4;
        var arrowHeight = 8;
        var arrowNumberOffset = 8;
        var x = dk.cx - 24;
        var y = dk.h - arrowEdgeOffset - arrowHeight - fh - arrowNumberOffset;

        var hasGps = _viewModel.isPositionRegistered();

        var text = hasGps ? "GPS" : "---";
        var color = hasGps ? Graphene.COLOR_GREEN : Color.CONTROL_NORMAL;

        dk.setColor(color);
        dk.dc.drawText(x, y, font, text, Graphics.TEXT_JUSTIFY_RIGHT);
    }

    private function _drawClockTime(dk) {
        var font = Graphene.FONT_XTINY;
        var fh = dk.dc.getFontHeight(font);
        var arrowEdgeOffset = 4;
        var arrowHeight = 8;
        var arrowNumberOffset = 8;
        var x = dk.cx + 24;
        var y = dk.h - arrowEdgeOffset - arrowHeight - fh - arrowNumberOffset;

        var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var text = info.hour.format("%02d") + ":" + info.min.format("%02d");

        dk.setColor(Color.CONTROL_NORMAL);
        dk.dc.drawText(x, y, font, text, Graphics.TEXT_JUSTIFY_LEFT);
    }

}
