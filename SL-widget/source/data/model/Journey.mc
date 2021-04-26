
(:glance)
class Journey {

    public var mode;
    public var line;
    public var destination;
    public var direction;
    public var displayTime;

    function initialize(mode, line, destination, direction, displayTime) {
        self.mode = mode;
        self.line = line;
        self.destination = destination;
        self.direction = direction;
        self.displayTime = displayTime;
    }

    function print() {
        return displayTime + " " + line + " " + destination;
    }

}
