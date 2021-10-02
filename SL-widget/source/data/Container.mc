
(:glance)
class Container {

    // data source
    private var _position = new PositionModel();
    private var _storage = new StorageModel();
    private var _api = new SlApi(_storage);

    // repository
    private var _repo = new Repository(_position, _storage, _api);

    // viewmodel
    var stopGlanceViewModel = new StopGlanceViewModel(_repo);
    var stopDetailViewModel = new StopDetailViewModel(_repo);

}
