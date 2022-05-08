using Toybox.WatchUi;
using Carbon.Graphene;

class ApiInfoView extends WatchUi.View {

    // init

    function initialize() {
        View.initialize();
    }

    // override View

    //! Load resources
    function onLayout(dc) {
        setLayout(Rez.Layouts.apiinfo_layout(dc));
    }

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    function onShow() {
    }

    //! Update the view
    function onUpdate(dc) {
        // invert colors
        dc.setColor(Graphene.COLOR_BLACK, Graphene.COLOR_WHITE);
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
    }

}
