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

using Toybox.Application.Storage;
using Toybox.Position;
using Toybox.Timer;
using Toybox.WatchUi;

class StopListViewModel {

    static hidden const _STORAGE_LAST_POS = "last_pos";

    var stopCursor = 0;

    hidden var _lastPos as LatLon?;

    // init

    function initialize() {
        stopCursor = getFavoriteCount();
        _lastPos = StorageUtil.getArray(_STORAGE_LAST_POS) as LatLon;
    }

    // timer

    function enableRequests() as Void {
        _requestPosition();
    }

    function disableRequests() as Void {
        Footprint.disableLocationEvents();
    }

    // position

    hidden function _requestPosition() as Void {
        // check if location use is turned off
        if (!SettingsStorage.getUseLocation()) {
            NearbyStopsStorage.setResponseError(null);
            WatchUi.requestUpdate();
            return;
        }

        // set location event listener and get last location while waiting
        Footprint.onRegisterPosition = method(:onPosition);
        Footprint.enableLocationEvents(false);
        Footprint.registerLastKnownPosition();
    }

    function onPosition() as Void {
        // request directly if there is no last position saved,
        // there has been no request,
        // or if last request resulted in an error.
        if (_lastPos == null
            || NearbyStopsStorage.response == null
            || NearbyStopsStorage.response instanceof ResponseError) {

            _requestNearbyStops();
        }
        else {
            var movedDistance = Footprint.distanceTo(_lastPos);

            // only request stops if the user has moved 100 m since last request
            if (movedDistance > 100) {
                _requestNearbyStops();
            }
        }
    }

    hidden function _isPositioned() as Boolean {
        return Footprint.isPositioned() && SettingsStorage.getUseLocation();
    }

    // service

    hidden function _requestNearbyStops() as Void {
        if (!NearbyStopsStorage.hasStops()) {
            // set searching (override errors, but not stops)
            NearbyStopsStorage.setResponseError(null);
        }

        NearbyStopsService.requestNearbyStops(Footprint.getLatLonDeg());

        // update last position
        _lastPos = Footprint.getLatLonRad();
        // save to storage to avoid requesting every time the user enters the app
        Storage.setValue(_STORAGE_LAST_POS, _lastPos);
    }

    // storage - read

    function getMessage() as String {
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

    function hasStops() as Boolean {
        return NearbyStopsStorage.hasStops() || FavoriteStopsStorage.favorites.size() > 0;
    }

    // TODO: does this need to be nullable?
    hidden function _getStops() as Array<StopType>? {
        var response = NearbyStopsStorage.response;
        var favs = FavoriteStopsStorage.favorites;
        var stops = response instanceof Lang.Array ? ArrUtil.merge(favs, response) : favs;

        // coerce cursor
        stopCursor = MathUtil.min(stopCursor, getItemCount() - 1);

        return stops;
    }

    function getStopNames() as Array<String>? {
        var stops = _getStops();
        if (stops == null) { return null; }

        var names = new [stops.size()];
        for (var i = 0; i < names.size(); i++) {
            names[i] = stops[i].name;
        }

        return names;
    }

    function getItemCount() as Number {
        var response = NearbyStopsStorage.response;

        return getFavoriteCount() + (response instanceof Lang.Array ? response.size() : 1);
    }

    function getFavoriteCount() as Number {
        return FavoriteStopsStorage.favorites.size();
    }

    function getSelectedStop() as StopType? {
        var stops = _getStops();
        return stopCursor < stops.size() ? stops[stopCursor] : null;
    }

    function isSelectedStopFavorite() as Boolean {
        var stop = getSelectedStop();
        return stop != null && FavoriteStopsStorage.isFavorite(stop);
    }

    function isShowingMessage() as Boolean {
        return !(NearbyStopsStorage.response instanceof Lang.Array) && stopCursor == getItemCount() - 1;
    }

    // storage - write

    function addFavorite() as Void {
        var stop = getSelectedStop();

        // double check that we have a stop response
        if (stop instanceof Stop || stop instanceof StopDouble) {
            FavoriteStopsStorage.addFavorite(stop);
            // navigate to newly added
            stopCursor = getFavoriteCount() - 1;
        }
    }

    function removeFavorite() as Void {
        var isInFavoritesPane = stopCursor < getFavoriteCount();

        FavoriteStopsStorage.removeFavorite(getSelectedStop());

        // keep cursor inside favorites panel
        // – or where it was
        stopCursor = isInFavoritesPane
            ? MathUtil.coerceIn(stopCursor, 0, MathUtil.max(getFavoriteCount() - 1, 0))
            : stopCursor - 1;
    }

    function moveFavorite(diff as Number) as Void {
        FavoriteStopsStorage.moveFavorite(getSelectedStop(), diff);
        stopCursor += diff;
    }

    //

    function isUserRefreshable() as Boolean {
        return NearbyStopsStorage.response instanceof ResponseError
            && NearbyStopsStorage.response.isUserRefreshable();
    }

    function onSelectMessage() as Void {
        // for now we let the user trigger a refresh also
        // by clicking on the error msg. TODO: remove?
        if (isUserRefreshable()) {
            _requestNearbyStops();
            WatchUi.requestUpdate();
        }
    }

    function getNearbyCursor() as Number {
        return stopCursor - getFavoriteCount();
    }

    function onScrollDown() as Void {
        if (isShowingMessage() && isUserRefreshable()) {
            _requestNearbyStops();
            WatchUi.requestUpdate();
            return;
        }

        _rotStopCursor(1);
    }

    //! @return true if successfully rotating
    function onScrollUp() as Boolean {
        // if the user has no favorites, scrolling off-screen
        // should not result in going back round.
        if (getFavoriteCount() == 0 && stopCursor == 0) {
            return false;
        }

        _rotStopCursor(-1);
        return true;
    }

    hidden function _rotStopCursor(step as Number) as Void {
        if (hasStops()) {
            stopCursor = MathUtil.mod(stopCursor + step, getItemCount());
            WatchUi.requestUpdate();
        }
    }

}
