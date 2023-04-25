using Toybox.WatchUi;

function invertTransition(transition) {
    return transition == WatchUi.SLIDE_UP ? WatchUi.SLIDE_DOWN
        : transition == WatchUi.SLIDE_DOWN ? WatchUi.SLIDE_UP
        : transition == WatchUi.SLIDE_RIGHT ? atchUi.SLIDE_LEFT
        : transition == WatchUi.SLIDE_LEFT ? WatchUi.SLIDE_RIGHT
        : transition;
}
