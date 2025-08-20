// This file is part of Avgånär.
//
// Avgånär is free software: you can redistribute it and/or modify it under the terms of
// the GNU General Public License as published by the Free Software Foundation,
// either version 3 of the License, or (at your option) any later version.
//
// Avgånär is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
// without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with Avgånär.
// If not, see <https://www.gnu.org/licenses/>.

import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class DialogView extends WatchUi.View {

    private var _viewModel as DialogViewModel;
    private var _transition as SlideType;

    // init

    function initialize(viewModel as DialogViewModel, transition as SlideType) {
        View.initialize();

        _viewModel = viewModel;
        _transition = transition;
    }

    static function push(title as String?, messages as Array<String>,
        iconRezId as ResourceId?, transition as SlideType) as Void {

        var viewModel = new DialogViewModel(title, messages, iconRezId);
        var view = new DialogView(viewModel, transition);
        var delegate = new DialogDelegate(viewModel, invertTransition(transition));

        WatchUi.pushView(view, delegate, transition);
    }

    // lifecycle

    function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);
        DrawUtil.enableAntiAlias(dc);

        _draw(dc);
    }

    // draw

    private function _draw(dc as Dc) as Void {
        DrawUtil.resetColor(dc);

        // text
        WidgetUtil.drawPreviewTitle(dc, _viewModel.title, _viewModel.iconRezId, true);
        DrawUtil.fillTextArea(dc, _viewModel.getMessage(), AppColors.TEXT_PRIMARY);
        DrawUtil.setColor(dc, AppColors.TEXT_TERTIARY);

        // arrow
        if (_transition == WatchUi.SLIDE_DOWN) {
            WidgetUtil.drawBottomPageArrow(dc);
        }
        else if (_transition == WatchUi.SLIDE_UP) {
            WidgetUtil.drawTopPageArrow(dc);
        }

        DrawUtil.resetColor(dc);

        // page indicator
        WidgetUtil.drawHorizontalPageIndicator(dc, _viewModel.messages.size(), _viewModel.pageCursor);
    }

}
