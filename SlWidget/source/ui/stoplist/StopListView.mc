using Toybox.WatchUi;
using Toybox.Graphics;
using Carbon.Graphene;

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
        _draw(new DcWrapper(dc));
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
        _viewModel.disableRequests();
    }

    // draw

    private function _draw(dcw) {
        var response = _viewModel.getResponse();

        // stops
        _drawStops(dcw);

        // error
        if (_viewModel.isShowingMessage()) {
            // info
            dcw.drawDialog(response.getTitle(), "");

            // start indicator
            if (response instanceof ResponseError && response.isRerequestable()) {
                // TODO: make clickable
                dcw.drawStartIndicatorWithBitmap(Rez.Drawables.ic_refresh);
            }
        }
        /*if (response instanceof ResponseError) {
            // banner
            if (!response.hasConnection()) {
                dcw.drawExclamationBanner();
            }
        }*/
    }

    private function _drawStops(dcw) {
        var stopNames = _viewModel.getStopNames();
        var favCount = _viewModel.getFavoriteCount();
        var cursor = _viewModel.stopCursor;
        var favHints = [ "Favorites", "No favorites" ];
        var nearbyHints = [ "Nearby", "None nearby" ];
        var cc = new ColorContext(Color.PRIMARY, Color.ON_PRIMARY, Color.ON_PRIMARY_SECONDARY, Color.ON_PRIMARY_TERTIARY);

        dcw.drawPanedList(stopNames, favCount, cursor, favHints, nearbyHints, cc);
    }

    private function _drawGpsStatus(dcw) {
        var x = dcw.cx + 45;
        var y = 60;
        var r = 5;

        var hasGps = _viewModel.isPositionRegistered();
        var color = hasGps ? Graphene.COLOR_GREEN : Color.CONTROL_NORMAL;

        dcw.setColor(color);
        dcw.dc.fillCircle(x, y, r);
    }

}
