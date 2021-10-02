
(:glance)
class Container {

    // data source
    private var _position = new PositionModel();
    private var _storage = new StorageModel();
    private var _api = new SlApi(_storage);

    // repository
    private var _stopGlanceRepo = new StopGlanceRepository(_position, _storage, _api);
    private var _stopDetailRepo = new StopDetailRepository(_position, _storage, _api);

    // viewmodel
    var stopGlanceViewModel = new StopGlanceViewModel(_stopGlanceRepo);
    var stopDetailViewModel = new StopDetailViewModel(_stopDetailRepo);

}
