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
        View.onUpdate(dc);

        // draw
        enableAntiAlias(dc);
        _draw(dc);
    }

    function onHide() {
        _viewModel.disableRequests();
    }

    // draw

    hidden function _draw(dc) {
        var response = NearbyStopsStorage.response;

        // stops
        _drawStops(dc);
        _drawLoadingStatus(dc);

        // error
        if (_viewModel.isShowingMessage()) {
            // info
            WidgetUtil.drawDialog(dc, _viewModel.getMessage());
        }
    }

    hidden function _drawStops(dc) {
        var stopNames = _viewModel.getStopNames();
        var favCount = _viewModel.getFavoriteCount();
        var cursor = _viewModel.stopCursor;

        var favHints = [ rez(Rez.Strings.lbl_list_favorites), rez(Rez.Strings.lbl_list_favorites_none) ];
        var nearbyHints = [ rez(Rez.Strings.lbl_list_nearby), rez(Rez.Strings.lbl_list_nearby) ];

        var favColors = [ AppColors.PRIMARY, AppColors.ON_PRIMARY, AppColors.ON_PRIMARY_SECONDARY, AppColors.ON_PRIMARY_TERTIARY ];
        var nearbyColors = [ Graphene.COLOR_BLACK, AppColors.TEXT_PRIMARY, AppColors.TEXT_SECONDARY, AppColors.TEXT_TERTIARY ];

        WidgetUtil.drawPanedList(dc, stopNames, favCount, cursor, favHints, nearbyHints, favColors, nearbyColors);
    }

    hidden function _drawLoadingStatus(dc) {
        var w = dc.getWidth();
        var middle;

        if (NearbyStopsService.isRequesting) {
            middle = w * 0.67f;
        }
        else if (!Footprint.isPositionRegistered) {
            middle = w * 0.33f;
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

        var h = px(3);
        var hasFavs = _viewModel.getFavoriteCount() > 0;

        Graphite.setColor(dc, hasFavs ? Graphene.COLOR_LT_AZURE : Graphene.COLOR_LT_GRAY);
        dc.fillRectangle(0, y, middle, h);
        Graphite.setColor(dc, hasFavs ? AppColors.ON_PRIMARY_TERTIARY : Graphene.COLOR_DK_GRAY);
        dc.fillRectangle(middle, y, w, h);
    }

}
