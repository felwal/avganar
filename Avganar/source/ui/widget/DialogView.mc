using Toybox.WatchUi;

class DialogView extends WatchUi.View {

    hidden var _title;
    hidden var _message;
    hidden var _transition;

    // init

    function initialize(title, message, transition) {
        View.initialize();

        _title = title;
        _message = message;
        _transition = transition;
    }

    function push(title, message, transition) {
        var view = new DialogView(title, message, transition);
        var delegate = new DialogDelegate(invertTransition(transition));

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

        if (_title != null) {
            WidgetUtil.drawPreviewTitle(dc, _title, null);
        }

        WidgetUtil.drawDialog(dc, _message);
        Graphite.setColor(dc, AppColors.TEXT_TERTIARY);

        if (_transition == WatchUi.SLIDE_DOWN) {
            WidgetUtil.drawBottomPageArrow(dc);
        }
        else if (_transition == WatchUi.SLIDE_UP) {
            WidgetUtil.drawTopPageArrow(dc);
        }

        Graphite.resetColor(dc);
    }

}
