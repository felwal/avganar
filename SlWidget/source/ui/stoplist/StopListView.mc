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
        var response = _viewModel.getResponse();

        // stops
        _drawStops(dcc);

        // error
        if (_viewModel.isShowingMessage()) {
            // info
            dcc.drawDialog(response.title, response.message);

            // start indicator
            if (response.isRerequestable()) {
                // TODO: make clickable
                dcc.drawStartIndicatorWithBitmap(Rez.Drawables.ic_refresh);
            }
        }
        /*if (response instanceof ResponseError) {
            // banner
            if (!response.hasConnection()) {
                dcc.drawExclamationBanner();
            }
        }*/
    }

    private function _drawStops(dcc) {
        var stopNames = _viewModel.getStopNames();
        var favCount = _viewModel.getFavouriteCount();
        var cursor = _viewModel.stopCursor;
        var favHints = [ "Favourites", "No favourites" ];
        var nearbyHints = [ "Nearby", "None nearby" ];
        var cc = new ColorContext(Color.PRIMARY, Color.ON_PRIMARY, Color.ON_PRIMARY_SECONDARY, Color.ON_PRIMARY_TERTIARY);

        dcc.drawPanedList(stopNames, favCount, cursor, favHints, nearbyHints, cc);
    }

    private function _drawGpsStatus(dcc) {
        var x = dcc.cx + 45;
        var y = 60;
        var r = 5;

        var hasGps = _viewModel.isPositionRegistered();
        var color = hasGps ? Graphene.COLOR_GREEN : Color.CONTROL_NORMAL;

        dcc.setColor(color);
        dcc.dc.fillCircle(x, y, r);
    }

}
