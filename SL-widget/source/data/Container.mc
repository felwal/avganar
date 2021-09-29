
(:glance)
class Container {

    // data source
    private var _pos = new PositionModel();
    private var _storage = new StorageModel();
    private var _sl = new SlApi(_storage);

    // repository
    private var _repo = new Repository(_pos, _storage, _sl);

    // viewmodel
    var stopGlanceViewModel = new StopGlanceViewModel(_repo);
    var stopDetailViewModel = new StopDetailViewModel(_repo);

    //

    function initialize() {
    }

}
