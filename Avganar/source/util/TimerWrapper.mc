using Toybox.Timer;

class TimerWrapper {

    hidden var _timer;
    hidden var _baseTime;
    hidden var _reprs;

    function initialize() {
        _timer = new Timer.Timer();
    }

    function start(baseTime, reprs) {
        _baseTime = baseTime;
        _reprs = reprs;

        _timer.start(method(:onTimer), _baseTime, true);
    }

    function stop() {
        _timer.stop();
    }

    function onTimer() {
        for (var i = 0; i < _reprs.size(); i++) {
            _reprs[i].onBaseTime();
        }
    }

}

class TimerRepr {

    hidden var _callback;
    hidden var _multiple;
    hidden var _currentMultiple = 0;

    function initialize(callback, multipleOfBaseTime) {
        _callback = callback;
        _multiple = multipleOfBaseTime;
    }

    function onBaseTime() {
        _currentMultiple++;

        if (_currentMultiple >= _multiple) {
            _currentMultiple = 0;
            _callback.invoke();
        }
    }

}
