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
        // gray out stops if not current (waiting for GPS or request)
        var nearbyColors = [
            Graphene.COLOR_BLACK,
            _viewModel.areStopsCurrent() ? AppColors.TEXT_PRIMARY : AppColors.TEXT_SECONDARY,
            _viewModel.areStopsCurrent() ? AppColors.TEXT_SECONDARY : AppColors.TEXT_TERTIARY,
            AppColors.TEXT_TERTIARY ];

        WidgetUtil.drawPanedList(dc, stopNames, favCount, cursor, favHints, nearbyHints, favColors, nearbyColors);
    }

    hidden function _drawGpsStatus(dc) {
        var x = Graphite.getCenterX(dc) + pxX(dc, 45);
        var y = pxY(dc, 60);
        var r = px(dc, 5);

        var hasGps = Footprint.isPositionRegistered;
        var color = hasGps ? Graphene.COLOR_GREEN : AppColors.CONTROL_NORMAL;

        Graphite.setColor(dc, color);
        dc.fillCircle(x, y, r);
    }

}
