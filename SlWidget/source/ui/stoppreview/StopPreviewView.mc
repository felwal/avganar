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
        _draw(new DcWrapper(dc));
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
    }

    // draw

    private function _draw(dcw) {
        var stopNames = _viewModel.getStopNames();

        // icon
        dcw.drawBitmap(dcw.cx, 60, Rez.Drawables.ic_launcher);

        // 3 nearest stops
        if (stopNames.size() == 0) {
            dcw.drawDialog(rez(Rez.Strings.lbl_preview_title_no_stops), "");
        }
        else {
            _drawStops(dcw, stopNames);
        }
    }

    private function _drawStops(dcw, stopNames) {
        var font = Graphene.FONT_TINY;
        var fontHeight = dcw.dc.getFontHeight(font);
        var lineHeight = 1.6;
        var lineHeightPx = fontHeight * lineHeight;

        for (var i = 0; i < stopNames.size(); i++) {
            var yText = dcw.cy + i * lineHeightPx;

            dcw.setColor(AppColors.TEXT_PRIMARY);
            dcw.dc.drawText(dcw.cx, yText, font, stopNames[i], Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

}
