using Toybox.WatchUi;
using Toybox.Graphics;
using Carbon.Graphene;
using Carbon.Graphite;
using Carbon.Footprint;

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
        _draw(dc);
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
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
            WidgetUtil.drawDialog(dc, response.getTitle(), "");

            // start indicator
            if (response instanceof ResponseError && response.isRerequestable()) {
                // TODO: make clickable
                WidgetUtil.drawStartIndicatorWithBitmap(dc, Rez.Drawables.ic_refresh);
            }
        }
        /*if (response instanceof ResponseError) {
            // banner
            if (!response.hasConnection()) {
                WidgetUtil.drawExclamationBanner(dc);
            }
        }*/
    }

    private function _drawStops(dc) {
        var stopNames = _viewModel.getStopNames();
        var favCount = _viewModel.getFavoriteCount();
        var cursor = _viewModel.stopCursor;
        var favHints = [ "Favorites", "No favorites" ];
        var nearbyHints = [ "Nearby", "None nearby" ];
        var cc = new ColorContext(AppColors.PRIMARY, AppColors.ON_PRIMARY, AppColors.ON_PRIMARY_SECONDARY, AppColors.ON_PRIMARY_TERTIARY);

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
