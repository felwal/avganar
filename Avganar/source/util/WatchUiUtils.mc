using Toybox.WatchUi;

function invertTransition(transition) {
    if (transition == WatchUi.SLIDE_UP) {
        return WatchUi.SLIDE_DOWN;
    }
    else if (transition == WatchUi.SLIDE_DOWN) {
        return WatchUi.SLIDE_UP;
    }
    if (transition == WatchUi.SLIDE_RIGHT) {
        return WatchUi.SLIDE_LEFT;
    }
    else if (transition == WatchUi.SLIDE_LEFT) {
        return WatchUi.SLIDE_RIGHT;
    }
    else {
        return transition;
    }
}
