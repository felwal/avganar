<p align="center"><img width="128" height="128" src="presentation/logo.png"></p>
<h1 align="center">Avgånär: Sweden departures</h1>

Avgånär is a Garmin Connect IQ widget displaying (public transport) nearby stops and departures within Sweden.

Get it on the [Connect IQ Store](https://apps.garmin.com/apps/993cae37-27d3-46b2-9f87-443ece770a61).

## Preview

<p><img src="presentation/view-glance.png" width="32%" /> <img src="presentation/view-preview.png" width="32%" /> <img src="presentation/view-stops-nearby.png" width="32%" /> <img src="presentation/view-stops-favorites.png" width="32%" /> <img src="presentation/view-departures-train.png" width="32%" /> <img src="presentation/view-departures-bus.png" width="32%" /> </p>

## Features

- View nearby stops
- Save favorite stops and view anywhere
- View departures
  - Sectioned and color coded by transport mode and group
- Limit memory consumption by tuning settings

## API

Avgånär uses [Trafiklab](https://www.trafiklab.se)'s APIs:

- [Resrobot 2.1](https://www.trafiklab.se/api/trafiklab-apis/resrobot-v21/)

## Develop

Place your API keys somewhere gitignored, such as `ServiceSecrets.mc`:

```
const API_KEY = "<KEY>";
```

## Build

I develop on `develop` and build on `main` using [Prettier Monkey C](https://github.com/markw65/prettier-extension-monkeyc).

## Fork

You are more than welcome to make a fork and adapt the project to your own country's public transport.

## Credits

Some icons have been adapted from [Google Fonts](https://fonts.google.com/icons?icon.query=sign). (Removed in [#4e4e772](https://github.com/felwal/avganar/commit/4e4e7724eca011174257edb4b2e3462818f5bd86).)
