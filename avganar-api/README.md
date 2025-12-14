# Avgånär API

SL discontinued their [Nearby Stops 2](https://github.com/trafiklab/trafiklab.se/blob/development/content/api/our-apis/sl/nearby-stops-2.md) API, central to [Avgånär](https://github.com/felwal/avganar), without providing a replacement. The purpose of this static API is only to fill this need.

The data is combined from:

- [SL Transport](https://www.trafiklab.se/api/our-apis/sl/transport) sites (CC BY based [license](https://www.trafiklab.se/api/our-apis/sl/licence))
- [GTFS Sverige 2](https://www.trafiklab.se/api/gtfs-datasets/gtfs-sverige-2) agency stops (CC0 1.0)

## Usage

Use [ResRobot 2.1 Nearby Stops](https://www.trafiklab.se/api/our-apis/resrobot-v21/nearby-stops) or similar to get a `national_id` ("rikshållplats"), then transform to SL "site id":

`api.avganar.felixwallin.se/sl-national-stops/<national_id>.json`

Example response:

```json
{
  "site_id": 1079,
  "name": "Stockholm Odenplan"
}
```

Example URLs:

- https://api.avganar.felixwallin.se/sl-national-stops.json
- https://api.avganar.felixwallin.se/sl-national-stops/740001618.json

## Problems

- 757 SL sites have are not linked to any national id
- 30 SL sites have no unique mapping to a national id
