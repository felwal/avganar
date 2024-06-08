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

import Toybox.Lang;
import Toybox.WatchUi;

//! The StopList options menu, handling favorites and about info.
class OptionsMenuDelegate extends WatchUi.Menu2InputDelegate {

    static const ITEM_FAVORITE_ADD = :addFavorite;
    static const ITEM_FAVORITE_REMOVE = :removeFavorite;
    static const ITEM_FAVORITE_MOVE_UP = :moveFavoriteUp;
    static const ITEM_FAVORITE_MOVE_DOWN = :moveFavoriteDown;
    static const ITEM_SETTINGS = :settings;
    static const ITEM_ABOUT = :aboutInfo;

    hidden var _viewModel as StopListViewModel;
    hidden var _menu as Menu2;

    // init

    function initialize(viewModel as StopListViewModel) {
        Menu2InputDelegate.initialize();

        _viewModel = viewModel;
        _menu = new WatchUi.Menu2({ :title => getString(Rez.Strings.lbl_options_title) });
        _addItems();
    }

    hidden function _addItems() as Void {
        // favorite settings
        if (_viewModel.isSelectedStopFavorite()) {
            var isInFavorites = _viewModel.stopCursor < _viewModel.getFavoriteCount();

            // move favorite
            if (isInFavorites && _viewModel.stopCursor != 0) {
                // move up
                _menu.addItem(new WatchUi.MenuItem(
                    getString(Rez.Strings.itm_options_favorite_move_up), "",
                    ITEM_FAVORITE_MOVE_UP, {}
                ));
            }
            if (isInFavorites && _viewModel.stopCursor != _viewModel.getFavoriteCount() - 1) {
                // move down
                _menu.addItem(new WatchUi.MenuItem(
                    getString(Rez.Strings.itm_options_favorite_move_down), "",
                    ITEM_FAVORITE_MOVE_DOWN, {}
                ));
            }

            // remove favorite
            _menu.addItem(new WatchUi.MenuItem(
                getString(Rez.Strings.itm_options_favorite_remove), "",
                ITEM_FAVORITE_REMOVE, {}
            ));
        }
        else if (!_viewModel.isShowingMessage()) {
            // add favorite
            _menu.addItem(new WatchUi.MenuItem(
                getString(Rez.Strings.itm_options_favorite_add), "",
                ITEM_FAVORITE_ADD, {}
            ));
        }

        // settings
        _menu.addItem(new WatchUi.MenuItem(
            getString(Rez.Strings.lbl_settings_title), "",
            ITEM_SETTINGS, {}
        ));

        // about
        _menu.addItem(new WatchUi.MenuItem(
            getString(Rez.Strings.itm_options_about), "",
            ITEM_ABOUT, {}
        ));
    }

    function push(transition as SlideType) as Void {
        WatchUi.pushView(_menu, me, transition);
    }

    // override Menu2InputDelegate

    function onSelect(item as MenuItem) as Void {
        var view = null;
        var id = item.getId();

        if (id == ITEM_FAVORITE_ADD) {
            _viewModel.addFavorite();
        }
        else if (id == ITEM_FAVORITE_REMOVE) {
            _viewModel.removeFavorite();
        }
        else if (id == ITEM_FAVORITE_MOVE_UP) {
            _viewModel.moveFavorite(-1);
        }
        else if (id == ITEM_FAVORITE_MOVE_DOWN) {
            _viewModel.moveFavorite(1);
        }
        else if (id == ITEM_SETTINGS) {
            new SettingsMenuDelegate().push(WatchUi.SLIDE_LEFT);
            return;
        }
        else if (id == ITEM_ABOUT) {
            var text = getString(Rez.Strings.app_version) + ". " + getString(Rez.Strings.lbl_info_about);
            view = new InfoView(text);
        }

        if (view == null) {
            // if no new view is opened, close the menu
            onBack();
        }
        else {
            WatchUi.pushView(view, null, WatchUi.SLIDE_LEFT);
        }
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_BLINK);
    }

}
