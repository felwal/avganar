using Toybox.WatchUi;

class StopPreviewDelegate extends WatchUi.BehaviorDelegate {

    private var _repo;
    private var _viewModel;

    // init

    function initialize(repo, viewModel) {
        BehaviorDelegate.initialize();
        _repo = repo;
        _viewModel = viewModel;
    }

    // override BehaviorDelegate

    //! "START-STOP"
    function onSelect() {
        _pushStopList();
        return true;
    }

    //

    private function _pushStopList() {
        var viewModel = new StopListViewModel(_repo);
        var view = new StopListView(viewModel);
        var delegate = new StopListDelegate(_repo, viewModel);

        WatchUi.pushView(view, delegate, WatchUi.SLIDE_BLINK);
    }

}
