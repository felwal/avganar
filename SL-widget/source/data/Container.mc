
(:glance)
class Container {

    // data source
    private var _sl = new SlApi();
    private var _pos = new PositionCompat();

    // repository
    private var _repo = new Repository(_sl, _pos);

    // viewmodel
    var stopGlanceViewModel = new StopGlanceViewModel(_repo);
    var stopDetailViewModel = new StopDetailViewModel(_repo);

    //

    function initialize() {
    }

}
