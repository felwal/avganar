
(:glance)
class Container {

    // data source
    private var _sl = new SlApi();
    private var _pos = new PositionCompat();

    // repository
    private var _repo = new Repository(_sl, _pos);

    // viewmodel
    var glanceViewModel = new SlWidgetGlanceViewModel(_repo);
    var viewViewModel = new SlWidgetViewViewModel(_repo);

    //

    function initialize() {
    }

}
