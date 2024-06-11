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
using Toybox.WatchUi;

class StopListViewModel {

    static private const _STORAGE_LAST_POS = "last_pos";
    static private const _MOVED_DISTANCE_MIN = 100;

    var stopCursor as Number = 0;

    private var _lastPos as LatLon?;

    // init

    function initialize() {
        stopCursor = getFavoriteCount();

        var lastPosArr = StorageUtil.getArray(_STORAGE_LAST_POS);
        _lastPos = lastPosArr.size() == 2 ? lastPosArr : null;
    }

    function enableRequests() as Void {
        _requestPosition();
    }

    function disableRequests() as Void {
        Footprint.disableLocationEvents();
    }

    // position

    private function _requestPosition() as Void {
        // don't look for position if location setting is off
        if (NearbyStopsService.handleLocationOff()) { return; }

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

            // only request stops if the user has moved 100m since last request
            if (movedDistance > _MOVED_DISTANCE_MIN) {
                _requestNearbyStops();
            }
            else {
                WatchUi.requestUpdate();
            }
        }
    }

    private function _isPositioned() as Boolean {
        return Footprint.isPositioned() && SettingsStorage.getUseLocation();
    }

    // service

    private function _requestNearbyStops() as Void {
        // don't request using position if location setting is off
        if (NearbyStopsService.handleLocationOff()) { return; }

        // set searching (override errors, but not stops)
        if (!NearbyStopsStorage.hasStops()) {
            NearbyStopsStorage.resetResponse();
        }

        NearbyStopsService.requestNearbyStops(Footprint.getLatLonDeg());
        WatchUi.requestUpdate();

        // update last position
        _lastPos = Footprint.getLatLonRad();
        // save to storage to avoid requesting every time the user enters the app
        Storage.setValue(_STORAGE_LAST_POS, _lastPos);
    }

    // nearby

    function hasStops() as Boolean {
        return NearbyStopsStorage.hasStops() || FavoriteStopsStorage.favorites.size() > 0;
    }

    private function _getStops() as Array<StopType> {
        var nearby = NearbyStopsStorage.getStops();
        var favs = FavoriteStopsStorage.favorites;
        var stops = ArrUtil.merge(favs, nearby); // order is important

        // coerce cursor
        stopCursor = MathUtil.min(stopCursor, _getItemCount() - 1);

        return stops;
    }

    function getStopNames() as Array<String> {
        var stops = _getStops();
        var names = [];

        for (var i = 0; i < stops.size(); i++) {
            names.add(stops[i].name);
        }

        return names;
    }

    private function _getItemCount() as Number {
        var nearbyCount = NearbyStopsStorage.getStopCount();
        return getFavoriteCount() + (nearbyCount > 0 ? nearbyCount : 1);
    }

    function getSelectedStop() as StopType? {
        var stops = _getStops();
        return stopCursor < stops.size() ? stops[stopCursor] : null;
    }

    function getNearbyCursor() as Number {
        return stopCursor - getFavoriteCount();
    }

    // message

    function getMessage() as String {
        var response = NearbyStopsStorage.response;

        // status message
        if (response == null) {
            return getString(_isPositioned()
                ? Rez.Strings.msg_i_stops_requesting
                : Rez.Strings.msg_i_stops_no_gps);
        }
        // error or empty
        else {
            return response instanceof ResponseError
                ? response.getTitle()
                : getString(Rez.Strings.msg_i_stops_none);
        }
    }

    function isShowingMessage() as Boolean {
        return !NearbyStopsStorage.hasStops() && stopCursor == _getItemCount() - 1;
    }

    // favorites

    function getFavoriteCount() as Number {
        return FavoriteStopsStorage.favorites.size();
    }

    function isSelectedStopFavorite() as Boolean {
        var stop = getSelectedStop();
        return stop != null && FavoriteStopsStorage.isFavorite(stop);
    }

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

    // input

    function isUserRefreshable() as Boolean {
        return NearbyStopsStorage.response instanceof ResponseError
            && NearbyStopsStorage.response.isUserRefreshable();
    }

    function onSelectMessage() as Void {
        // let the user trigger a refresh also by clicking on the error msg
        // – not only by scrolling down for the action footer.
        if (isUserRefreshable()) {
            _requestNearbyStops();
        }
    }

    function onScrollDown() as Void {
        if (isShowingMessage() && isUserRefreshable()) {
            _requestNearbyStops();
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

    private function _rotStopCursor(step as Number) as Void {
        if (hasStops()) {
            stopCursor = MathUtil.modulo(stopCursor + step, _getItemCount());
            WatchUi.requestUpdate();
        }
    }

}
