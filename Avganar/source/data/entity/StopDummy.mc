class StopDummy {

    var name;

    hidden var _id;

    // init

    function initialize(id, name) {
        _id = id;
        me.name = name;
    }

    function equals(other) {
        return (other instanceof Stop || other instanceof StopDouble || other instanceof StopDummy)
            && other.getId() == _id && other.name.equals(name);
    }

    //

    function getId() {
        return _id;
    }

}
