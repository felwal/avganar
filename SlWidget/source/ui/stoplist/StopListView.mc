using Toybox.WatchUi;
using Carbon.Footprint;
using Carbon.Graphene;
using Carbon.Graphite;

class StopListView extends WatchUi.View {

    var _viewModel;

    // init

    function initialize(viewModel) {
        View.initialize();
        _viewModel = viewModel;
    }

    // override View

    function onShow() {
        _viewModel.enableRequests();
    }

    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        // draw
        dc.setAntiAlias(true);
        _draw(dc);
    }

    function onHide() {
        _viewModel.disableRequests();
    }

    // draw

    private function _draw(dc) {
        var response = NearbyStopsStorage.response;

        // stops
        _drawStops(dc);

        // error
        if (_viewModel.isShowingMessage()) {
            // info
            WidgetUtil.drawDialog(dc, _viewModel.getMessage(), "");
        }
    }

    private function _drawStops(dc) {
        var stopNames = _viewModel.getStopNames();
        var favCount = _viewModel.getFavoriteCount();
        var cursor = _viewModel.stopCursor;
        var favHints = [ rez(Rez.Strings.lbl_list_favorites), rez(Rez.Strings.lbl_list_favorites_none) ];
        var nearbyHints = [ rez(Rez.Strings.lbl_list_nearby), rez(Rez.Strings.lbl_list_nearby) ];
        var cc = [ AppColors.PRIMARY, AppColors.ON_PRIMARY, AppColors.ON_PRIMARY_SECONDARY, AppColors.ON_PRIMARY_TERTIARY ];

        WidgetUtil.drawPanedList(dc, stopNames, favCount, cursor, favHints, nearbyHints, cc);
    }

    private function _drawGpsStatus(dc) {
        var x = Graphite.getCenterX(dc) + 45;
        var y = 60;
        var r = 5;

        var hasGps = Footprint.isPositionRegistered;
        var color = hasGps ? Graphene.COLOR_GREEN : AppColors.CONTROL_NORMAL;

        Graphite.setColor(dc, color);
        dc.fillCircle(x, y, r);
    }

}
