import Toybox.Lang;

using Toybox.WatchUi;
using Toybox.Graphics;
using Carbon.Graphite as Graphite;
using Carbon.Graphene as Graphene;
using Carbon.Chem as Chem;

class StopDetailView extends WatchUi.View {

    private var _model as StopDetailViewModel;

    //

    function initialize(container as Container) as Void {
        View.initialize();
        _model = container.stopDetailViewModel;
    }

    // override View

    //! Load resources
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.main_layout(dc));
    }

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    function onShow() as Void {
        _model.enableRequests();
    }

    //! Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        // draw
        dc.setAntiAlias(true);
        _draw(dc);
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() as Void {
        _model.disableRequests();
    }

    // draw

    private function _draw(dc as Dc) as Void {
        var stop = _model.getSelectedStop();
        var w = dc.getWidth();
        var h = dc.getHeight();
        var r = w / 2;

        Graphite.resetColor(dc);
        dc.drawText(w / 2, 27, Graphene.FONT_TINY, stop.name.toUpper(), Graphics.TEXT_JUSTIFY_CENTER);

        var font = Graphene.FONT_XTINY;
        var fh = dc.getFontHeight(font);
        var lineHeight = 1.5;
        var offsetX = 10;
        var offsetY = 64;
        var rCircle = 4;

        var journeys = _model.getSelectedJourneys();

        for (var j = 0; j < 10 && j < journeys.size(); j++) {
            var journey = journeys[j];

            var yText = offsetY + j * fh * lineHeight;
            var yCircle = yText + fh / 2;
            /*if (yCircle > h - offsetY) {
                break;
            }*/

            var xCircle = Chem.minX(offsetY + fh / 2, r) + offsetX + rCircle;
            var xText = xCircle + rCircle + offsetX;

            Graphite.setColor(dc, journey.getColor());
            dc.fillCircle(xCircle, yCircle, rCircle);
            Graphite.resetColor(dc);
            dc.drawText(xText, yText, font, journey.toString(), Graphics.TEXT_JUSTIFY_LEFT);
        }
    }

}
