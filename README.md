# Avgånär: Sweden departures

A Garmin Connect IQ widget displaying (public transport) nearby stops and departures within Sweden. Uses Trafiklab's API.

Get it on the [Connect IQ Store](https://apps.garmin.com/en-GB/apps/a96ddb52-3edd-4298-8348-5bd818376a2a).

## Preview

<p><img src="presentation/view-glance.png" width="32%" /> <img src="presentation/view-preview.png" width="32%" /> <img src="presentation/view-stops-nearby.png" width="32%" /> <img src="presentation/view-stops-favorites.png" width="32%" /> <img src="presentation/view-departures-train.png" width="32%" /> <img src="presentation/view-departures-bus.png" width="32%" /> </p>

## Features

- View nearby stops
- Save favorite stops and view anywhere
- View departures
  - Color coded and sectioned by mode
- Limit memory consumption by tuning settings

## API

- [Resrobot 2.1](https://www.trafiklab.se/api/trafiklab-apis/resrobot-v21/)

## Develop

Place your API key in `ServiceSecrets.mc`:

```
const API_KEY = "<KEY>";
```

## Build

I develop on `main` and build on `release` using [Prettier Monkey C](https://github.com/markw65/prettier-extension-monkeyc).

## Fork

You are more than welcome to make a fork and adapt the project to your own country's public transport.

## Credits

Some icons have been adapted from [Google Fonts](https://fonts.google.com/icons?icon.query=sign).
