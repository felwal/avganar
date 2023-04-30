class DialogViewModel {

    var title;
    var messages;
    var iconRezId = null;
    var pageCursor = 0;

    //

    function initialize(title, messages, iconRezId) {
        me.title = title;
        me.messages = messages;
        me.iconRezId = iconRezId;
    }

    function getMessage() {
        return messages[pageCursor];
    }

    function onSelect() {
        if (messages.size() <= 1) {
            return;
        }

        // rotate page
        pageCursor = MathUtil.mod(pageCursor + 1, messages.size());
        WatchUi.requestUpdate();
    }

}
