class StopPreviewViewModel {

    private var _repo;

    // init

    function initialize(repo) {
        _repo = repo;
    }

    // read

    function getStops() {
        var response = _repo.getStopsResponse();
        return response instanceof ResponseError ? null : response.slice(0, 3);
    }

}
