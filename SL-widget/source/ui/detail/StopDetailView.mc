using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Time;
using Toybox.Time.Gregorian;
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
        _drawGpsStatus(dcc);
        _drawClockTime(dcc);

        // hori indicator
        dcc.drawHorizontalPageIndicator(_viewModel.getModeCount(), _viewModel.modeCursor);

        // vert indicator
        dcc.drawVerticalPageNumber(_viewModel.getStopCount(), _viewModel.stopCursor);
        dcc.drawVerticalPageArrows(_viewModel.getStopCount(), _viewModel.stopCursor);
        dcc.drawVerticalScrollbarMedium(_viewModel.getStopCount(), _viewModel.stopCursor);

        // banner
        if (!stop.hasConnection()) {
            dcc.drawExclamationBanner();
        }
    }

    private function _drawDepartures(dcc) {
        var font = Graphene.FONT_XTINY;
        var fh = dcc.dc.getFontHeight(font);
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

            var xCircle = Chem.minX(offsetY + fh / 2, dcc.r) + offsetX + rCircle;
            var xText = xCircle + rCircle + offsetX;

            dcc.setColor(departure.getColor());
            dcc.dc.fillCircle(xCircle, yCircle, rCircle);
            dcc.resetColor();
            dcc.dc.drawText(xText, yText, font, departure.toString(), Graphics.TEXT_JUSTIFY_LEFT);
        }
    }

    private function _drawGpsStatus(dcc) {
        if (!_viewModel.isPositionRegistered()) {
            return;
        }

        var font = Graphene.FONT_XTINY;
        var fh = dcc.dc.getFontHeight(font);
        var arrowEdgeOffset = 4;
        var arrowHeight = 8;
        var arrowNumberOffset = 8;
        var x = dcc.cx - 24;
        var y = dcc.h - arrowEdgeOffset - arrowHeight - fh - arrowNumberOffset;

        var text = "GPS";

        dcc.setColor(Graphene.COLOR_DK_GRAY);
        dcc.dc.drawText(x, y, font, text, Graphics.TEXT_JUSTIFY_RIGHT);
    }

    private function _drawClockTime(dcc) {
        var font = Graphene.FONT_XTINY;
        var fh = dcc.dc.getFontHeight(font);
        var arrowEdgeOffset = 4;
        var arrowHeight = 8;
        var arrowNumberOffset = 8;
        var x = dcc.cx + 24;
        var y = dcc.h - arrowEdgeOffset - arrowHeight - fh - arrowNumberOffset;

        var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var text = info.hour.format("%02d") + ":" + info.min.format("%02d");

        dcc.setColor(Graphene.COLOR_DK_GRAY);
        dcc.dc.drawText(x, y, font, text, Graphics.TEXT_JUSTIFY_LEFT);
    }

}
