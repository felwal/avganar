using Toybox.WatchUi;

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
        View.onUpdate(dc);

        // draw
        Graphite.enableAntiAlias(dc);
        _draw(dc);
    }

    function onHide() {
        _viewModel.disableRequests();
    }

    // draw

    hidden function _draw(dc) {
        // stops
        _drawStops(dc);
        _drawLoadingStatus(dc);

        // error
        if (_viewModel.isShowingMessage()) {
            // info
            WidgetUtil.drawDialog(dc, _viewModel.getMessage());

            // retry
            if (_viewModel.isRerequestable()) {
                WidgetUtil.drawActionFooter(dc, rez(Rez.Strings.lbl_list_retry));
            }
        }
    }

    hidden function _drawStops(dc) {
        var stopNames = _viewModel.getStopNames();
        var favCount = _viewModel.getFavoriteCount();
        var cursor = _viewModel.stopCursor;

        var favHints = [ favCount == 1 ? rez(Rez.Strings.lbl_list_favorites_one) : rez(Rez.Strings.lbl_list_favorites),
            rez(Rez.Strings.lbl_list_favorites_none) ];
        var nearbyHints = [ rez(Rez.Strings.lbl_list_nearby), rez(Rez.Strings.lbl_list_nearby) ];

        var favColors = [ AppColors.PRIMARY, AppColors.ON_PRIMARY, AppColors.ON_PRIMARY_SECONDARY, AppColors.ON_PRIMARY_TERTIARY ];
        var nearbyColors = [ Graphene.COLOR_BLACK, AppColors.TEXT_PRIMARY, AppColors.TEXT_SECONDARY, AppColors.TEXT_TERTIARY ];

        WidgetUtil.drawPanedList(dc, stopNames, favCount, cursor, favHints, nearbyHints, favColors, nearbyColors);
    }

    hidden function _drawLoadingStatus(dc) {
        var w = dc.getWidth();
        var progress;

        if (NearbyStopsService.isRequesting) {
            progress = MathUtil.recursiveShare(0.5f, 0.33f, NearbyStopsStorage.failedRequestCount);
        }
        else if (!Footprint.isPositionRegistered) {
            progress = 0.33f;
        }
        else {
            return;
        }

        var cursor = _viewModel.getNearbyCursor();
        var y;

        if (cursor == 0) {
            y = px(84);
        }
        else if (cursor == 1) {
            y = px(42);
        }
        else if (cursor == -1) {
            y = dc.getHeight() - px(84);
        }
        else if (cursor == -2) {
            y = dc.getHeight() - px(42);
        }
        else {
            return;
        }

        var hasFavs = _viewModel.getFavoriteCount() > 0;
        var h = px(hasFavs ? 3 : 2);
        var activeColor = hasFavs ? AppColors.PRIMARY_LT : AppColors.TEXT_SECONDARY;
        var inactiveColor = hasFavs ? AppColors.ON_PRIMARY_TERTIARY : null;

        WidgetUtil.drawProgressBar(dc, y, h, progress, activeColor, inactiveColor);
    }

}
