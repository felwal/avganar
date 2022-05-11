using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Carbon.Graphene;
using Carbon.Chem;

class StopListView extends WatchUi.View {

    var _viewModel;

    // init

    function initialize(viewModel) {
        View.initialize();
        _viewModel = viewModel;
    }

    // override View

    //! Load resources
    function onLayout(dc) {
        setLayout(Rez.Layouts.stoplist_layout(dc));
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
        var response = _viewModel.getResponse();

        // error
        if (response instanceof ResponseError) {
            // info
            dk.drawDialog(response.title, response.message);

            // banner
            if (!response.hasConnection()) {
                dk.drawExclamationBanner();
            }

            // start indicator
            if (response.isRerequestable()) {
                dk.drawStartIndicatorWithBitmap(Rez.Drawables.ic_refresh);
            }

            _viewModel.stopCursor = 0;
        }

        // stops
        else {
            _drawStops(dk, response);

            // page indicator
            var stopCount = response.size();
            dk.setColor(Color.CONTROL_NORMAL);
            dk.drawVerticalPageArrows(stopCount, _viewModel.stopCursor);
            dk.resetColor();
            dk.drawVerticalScrollbarCSmall(stopCount, max(_viewModel.stopCursor - 2, 0), min(_viewModel.stopCursor + 3, stopCount));
        }

        // at top
        if (_viewModel.stopCursor == 0) {
            // icon
            dk.drawBitmap(dk.cx, 60, Rez.Drawables.ic_launcher);

            // gps
            //_drawGpsStatus(dk);
        }
    }

    private function _drawStops(dk, stops) {
        var fontSelected = Graphene.FONT_LARGE;
        var font = Graphene.FONT_TINY;
        var fontHeight = dk.dc.getFontHeight(font);
        var lineHeight = 1.6;
        var lineHeightPx = fontHeight * lineHeight;

        var cursor = _viewModel.stopCursor;

        // only draw 2 stops above and 2 below cursor
        var stopOffset = 2;
        var firstStopIndex = max(0, cursor - stopOffset);
        var lastStopIndex = min(stops.size(), cursor + stopOffset + 1);

        for (var i = firstStopIndex; i < lastStopIndex; i++) {
            var stop = stops[i];

            var yText = dk.cy + (i - cursor) * lineHeightPx;

            if (i == cursor) {
                dk.setColor(Color.TEXT_PRIMARY);
                dk.dc.drawText(dk.cx, yText, fontSelected, stop.name, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
            }
            else {
                dk.setColor(Color.TEXT_SECONDARY);
                dk.dc.drawText(dk.cx, yText, font, stop.name, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
            }
        }
    }

    private function _drawGpsStatus(dk) {
        var x = dk.cx + 45;
        var y = 60;
        var r = 5;

        var hasGps = _viewModel.isPositionRegistered();
        var color = hasGps ? Graphene.COLOR_GREEN : Color.CONTROL_NORMAL;

        dk.setColor(color);
        dk.dc.fillCircle(x, y, r);
    }

}
