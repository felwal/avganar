using Toybox.WatchUi;
using Toybox.Graphics;
using Carbon.Graphene;

class StopPreviewView extends WatchUi.View {

    var _viewModel;

    // init

    function initialize(viewModel) {
        View.initialize();
        _viewModel = viewModel;
    }

    // override View

    //! Load resources
    function onLayout(dc) {
        setLayout(Rez.Layouts.stoppreview_layout(dc));
    }

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    function onShow() {
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
    }

    // draw

    private function _draw(dcc) {
        var stops = _viewModel.getStops();

        // icon
        dcc.drawBitmap(dcc.cx, 60, Rez.Drawables.ic_launcher);

        // 3 nearest stops
        if (stops == null || stops.size() == 0) {
            dcc.drawDialog(rez(Rez.Strings.lbl_preview_title_no_stops), "");
        }
        else {
            _drawStops(dcc, stops);
        }
    }

    private function _drawStops(dcc, stops) {
        var font = Graphene.FONT_TINY;
        var fontHeight = dcc.dc.getFontHeight(font);
        var lineHeight = 1.6;
        var lineHeightPx = fontHeight * lineHeight;

        for (var i = 0; i < stops.size(); i++) {
            var stop = stops[i];

            var yText = dcc.cy + i * lineHeightPx;

            dcc.setColor(Color.TEXT_PRIMARY);
            dcc.dc.drawText(dcc.cx, yText, font, stop.name, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

}
