class ResponseMessage {

    private var _title = "";

    // init

    function initialize(title) {
        _title = title;
    }

    function equals(other) {
        return other instanceof ResponseMessage && other.getTitle().equals(_title);
    }

    function getTitle() {
        return _title;
    }

}
