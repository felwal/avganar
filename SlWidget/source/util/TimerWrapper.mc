using Toybox.Timer;

class TimerWrapper {

    private var _timer;
    private var _baseTime;
    private var _reprs;

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

    private var _callback;
    private var _multiple;

    private var _currentMultiple = 0;

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
