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

using Toybox.Application.Storage;
using Toybox.Lang;
using Toybox.Position;
using Toybox.Timer;
using Toybox.WatchUi;

class StopListViewModel {

    static hidden const _STORAGE_LAST_POS = "last_pos";

    var stopCursor = 0;

    hidden var _lastPos;

    // init

    function initialize() {
        stopCursor = getFavoriteCount();
        _lastPos = StorageUtil.getArray(_STORAGE_LAST_POS);
    }

    // timer

    function enableRequests() {
        if (DEBUG) {
            //_requestNearbyStops();
            return;
        }

        _requestPosition();
    }

    function disableRequests() {
        Footprint.disableLocationEvents();
    }

    // position

    hidden function _requestPosition() {
        // check if location use is turned off
        if (!SettingsStorage.getUseLocation()) {
            NearbyStopsStorage.setResponse([], [], [], null);
            WatchUi.requestUpdate();
            return;
        }

        // set location event listener and get last location while waiting
        Footprint.onRegisterPosition = method(:onPosition);
        Footprint.enableLocationEvents(false);
        Footprint.registerLastKnownPosition();
    }

    function onPosition() {
        // request directly if there is no last position saved,
        // there has been no request,
        // or if last request resulted in an error.
        if (_lastPos.size() != 2
            || NearbyStopsStorage.response == null
            || NearbyStopsStorage.response instanceof ResponseError) {

            _requestNearbyStops();
        }
        else if (_lastPos.size() == 2) {
            var movedDistance = Footprint.distanceTo(_lastPos[0], _lastPos[1]);

            // only request stops if the user has moved 100 m since last request
            if (movedDistance > 100) {
                _requestNearbyStops();
            }
        }
    }

    hidden function _isPositioned() {
        return (Footprint.isPositioned() || DEBUG)
            && SettingsStorage.getUseLocation();
    }

    // service

    hidden function _requestNearbyStops() {
        if (!NearbyStopsStorage.hasStops()) {
            // set searching (override errors, but not stops)
            NearbyStopsStorage.setResponse([], [], [], null);
        }

        NearbyStopsService.requestNearbyStops(Footprint.getLatDeg(), Footprint.getLonDeg());

        // update last position
        _lastPos = [ Footprint.getLatRad(), Footprint.getLonRad() ];
        // save to storage to avoid requesting every time the user enters the app
        Storage.setValue(_STORAGE_LAST_POS, _lastPos);
    }

    // storage - read

    function getMessage() {
        var response = NearbyStopsStorage.response;

        // status message
        if (response == null) {
            return rez(_isPositioned()
                ? Rez.Strings.msg_i_stops_requesting
                : (SettingsStorage.getUseLocation()
                    ? Rez.Strings.msg_i_stops_no_gps
                    : Rez.Strings.msg_i_stops_location_off));
        }
        // error or response message
        else {
            return response instanceof ResponseError ? response.getTitle() : response;
        }
    }

    function hasStops() {
        return NearbyStopsStorage.hasStops() || FavoriteStopsStorage.favorites.size() > 0;
    }

    hidden function _getStops() {
        var response = NearbyStopsStorage.response;
        var favs = FavoriteStopsStorage.favorites;
        var stops = response instanceof Lang.Array ? ArrUtil.merge(favs, response) : favs;

        // coerce cursor
        stopCursor = MathUtil.min(stopCursor, getItemCount() - 1);

        return stops;
    }

    function getStopNames() {
        var stops = _getStops();
        if (stops == null) { return null; }

        var names = new [stops.size()];
        for (var i = 0; i < names.size(); i++) {
            names[i] = stops[i].name;
        }

        return names;
    }

    function getItemCount() {
        var response = NearbyStopsStorage.response;

        return getFavoriteCount() + (response instanceof Lang.Array ? response.size() : 1);
    }

    function getFavoriteCount() {
        return FavoriteStopsStorage.favorites.size();
    }

    function getSelectedStop() {
        var stops = _getStops();
        return stopCursor < stops.size() ? stops[stopCursor] : null;
    }

    function isSelectedStopFavorite() {
        var stop = getSelectedStop();
        return stop != null && FavoriteStopsStorage.isFavorite(stop);
    }

    function isShowingMessage() {
        return !(NearbyStopsStorage.response instanceof Lang.Array) && stopCursor == getItemCount() - 1;
    }

    // storage - write

    function addFavorite() {
        var stop = getSelectedStop();

        // double check that we have a stop response
        if (stop instanceof Stop || stop instanceof StopDouble) {
            FavoriteStopsStorage.addFavorite(stop);
            // navigate to newly added
            stopCursor = getFavoriteCount() - 1;
        }
    }

    function removeFavorite() {
        var isInFavoritesPane = stopCursor < getFavoriteCount();

        FavoriteStopsStorage.removeFavorite(getSelectedStop());

        // keep cursor inside favorites panel
        // – or where it was
        stopCursor = isInFavoritesPane
            ? MathUtil.coerceIn(stopCursor, 0, MathUtil.max(getFavoriteCount() - 1, 0))
            : stopCursor - 1;
    }

    function moveFavorite(diff) {
        FavoriteStopsStorage.moveFavorite(getSelectedStop(), diff);
        stopCursor += diff;
    }

    //

    function isUserRefreshable() {
        return NearbyStopsStorage.response instanceof ResponseError
            && NearbyStopsStorage.response.isUserRefreshable();
    }

    function onSelectMessage() {
        // for now we let the user trigger a refresh also
        // by clicking on the error msg. TODO: remove?
        if (isUserRefreshable()) {
            _requestNearbyStops();
            WatchUi.requestUpdate();
        }
    }

    function getNearbyCursor() {
        return stopCursor - getFavoriteCount();
    }

    //! Scroll down
    function incStopCursor() {
        if (isShowingMessage() && isUserRefreshable()) {
            _requestNearbyStops();
            WatchUi.requestUpdate();
            return;
        }

        _rotStopCursor(1);
    }

    //! Scroll up
    //! @return true if successfully rotating,
    function decStopCursor() {
        // if the user has no favorites, scrolling off-screen
        // should not result in going back round.
        if (getFavoriteCount() == 0 && stopCursor == 0) {
            return false;
        }

        _rotStopCursor(-1);
        return true;
    }

    hidden function _rotStopCursor(step) {
        if (hasStops()) {
            stopCursor = MathUtil.mod(stopCursor + step, getItemCount());
            WatchUi.requestUpdate();
        }
    }

}
