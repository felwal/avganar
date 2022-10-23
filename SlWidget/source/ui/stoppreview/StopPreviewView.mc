using Toybox.WatchUi;
using Toybox.Graphics;
using Carbon.Graphene;
using Carbon.Graphite;

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
        _draw(dc);
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
    }

    // draw

    private function _draw(dc) {
        var stopNames = _viewModel.getStopNames();

        // icon
        WidgetUtil.drawBitmap(dc, Graphite.getCenterX(dc), 60, Rez.Drawables.ic_launcher);

        // 3 nearest stops
        if (stopNames.size() == 0) {
            WidgetUtil.drawDialog(dc, rez(Rez.Strings.lbl_preview_title_no_stops), "");
        }
        else {
            _drawStops(dc, stopNames);
        }
    }

    private function _drawStops(dc, stopNames) {
        var font = Graphene.FONT_TINY;
        var fontHeight = dc.getFontHeight(font);
        var lineHeight = 1.6;
        var lineHeightPx = fontHeight * lineHeight;

        for (var i = 0; i < stopNames.size(); i++) {
            var yText = Graphite.getCenterY(dc) + i * lineHeightPx;

            Graphite.setColor(dc, AppColors.TEXT_PRIMARY);
            dc.drawText(Graphite.getCenterX(dc), yText, font, stopNames[i], Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

}
