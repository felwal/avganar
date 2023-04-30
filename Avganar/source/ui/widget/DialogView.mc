using Toybox.WatchUi;

class DialogView extends WatchUi.View {

    hidden var _viewModel;
    hidden var _transition;

    // init

    function initialize(viewModel, transition) {
        View.initialize();

        _viewModel = viewModel;
        _transition = transition;
    }

    function push(title, messages, iconRezId, transition) {
        var viewModel = new DialogViewModel(title, messages, iconRezId);
        var view = new DialogView(viewModel, transition);
        var delegate = new DialogDelegate(viewModel, invertTransition(transition));

        WatchUi.pushView(view, delegate, transition);
    }

    // override View

    function onUpdate(dc) {
        View.onUpdate(dc);

        // draw
        Graphite.enableAntiAlias(dc);
        _draw(dc);
    }

    // draw

    function _draw(dc) {
        Graphite.resetColor(dc);

        WidgetUtil.drawPreviewTitle(dc, _viewModel.title, _viewModel.iconRezId, true);

        Graphite.fillTextArea(dc, _viewModel.getMessage(), Graphene.COLOR_WHITE);
        Graphite.setColor(dc, AppColors.TEXT_TERTIARY);

        if (_transition == WatchUi.SLIDE_DOWN) {
            WidgetUtil.drawBottomPageArrow(dc);
        }
        else if (_transition == WatchUi.SLIDE_UP) {
            WidgetUtil.drawTopPageArrow(dc);
        }

        Graphite.resetColor(dc);

        // page indicator
        WidgetUtil.drawHorizontalPageIndicator(dc, _viewModel.messages.size(), _viewModel.pageCursor);
    }

}
