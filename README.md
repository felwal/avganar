<p align="center"><img width="128" height="128" src="presentation/logo.png"></p>
<h1 align="center">Avgånär: Stockholm departures</h1>

Avgånär is a Garmin Connect IQ widget displaying (public transport) nearby stops and departures within Stockholms Lokaltrafik (SL) in Sweden.

Get it on the [Connect IQ Store](https://apps.garmin.com/apps/a96ddb52-3edd-4298-8348-5bd818376a2a).

## Preview

<p><img src="presentation/view-glance.png" width="32%" /> <img src="presentation/view-preview.png" width="32%" /> <img src="presentation/view-stops-nearby.png" width="32%" /> <img src="presentation/view-stops-favorites.png" width="32%" /> <img src="presentation/view-departures-train.png" width="32%" /> <img src="presentation/view-departures-bus.png" width="32%" /> </p>

## Features

- View nearby stops
- Save favorite stops and view anywhere
- View departures
  - Color coded and sectioned by mode
  - See deviations and their importance level
- Limit memory consumption by tuning settings

## APIs

Avgånär uses [SL](https://sl.se/)'s APIs, provided by [Trafiklab](https://www.trafiklab.se):

- [SL Nearby stops 2](https://www.trafiklab.se/api/trafiklab-apis/sl/nearby-stops-2)
- [SL Transport](https://www.trafiklab.se/api/trafiklab-apis/sl/transport)
- ~~[SL Departures 4](https://www.trafiklab.se/api/trafiklab-apis/sl/departures-4/)~~

## Develop

Place your API keys somewhere gitignored, such as `ServiceSecrets.mc`:

```
const API_KEY_STOPS = "<KEY>";
const API_KEY_DEPARTURES = "<KEY>";
```

## Build

I develop on `develop` and build on `main` using [Prettier Monkey C](https://github.com/markw65/prettier-extension-monkeyc).

## Fork

You are more than welcome to make a fork and adapt the project to your own country's public transport.

## Credits

Some icons have been adapted from [Google Fonts](https://fonts.google.com/icons?icon.query=sign). (Removed in [#4e4e772](https://github.com/felwal/avganar/commit/4e4e7724eca011174257edb4b2e3462818f5bd86).)
