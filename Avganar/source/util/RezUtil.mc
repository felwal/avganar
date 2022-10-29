using Toybox.Application;
using Toybox.WatchUi;

module RezUtil {

    function drawBitmap(dc, x, y, rezId) {
        var drawable = new WatchUi.Bitmap({ :rezId => rezId });

        drawable.setLocation(x - drawable.width / 2, y - drawable.height / 2);
        drawable.draw(dc);
    }

}

(:glance)
function rez(rezId) {
    return Application.loadResource(rezId);
}
