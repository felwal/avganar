
(:glance)
class Container {

    // data source
    private var _position = new PositionModel();
    private var _storage = new StorageModel();

    // repository
    private var _stopGlanceRepo = new StopGlanceRepository(_position, _storage);
    private var _stopDetailRepo = new StopDetailRepository(_position, _storage);

    // viewmodel
    var stopGlanceViewModel = new StopGlanceViewModel(_stopGlanceRepo);
    var stopDetailViewModel = new StopDetailViewModel(_stopDetailRepo);

}
