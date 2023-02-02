using Toybox.Application;
using Toybox.WatchUi;

module RezUtil {

    function drawBitmap(dc, x, y, rezId) {
        var bitmap = new WatchUi.Bitmap({ :rezId => rezId });

        bitmap.setLocation(x - bitmap.width / 2, y - bitmap.height / 2);
        bitmap.draw(dc);
    }

}

(:glance)
function rez(rezId) {
    return Application.loadResource(rezId);
}
