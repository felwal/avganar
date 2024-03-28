# Description

Avgånär is a public transport widget for viewing nearby stops and departures within Stockholms Lokaltrafik (SL) in Sweden.

For coverage of the whole of Sweden, see Avgånär: Sweden departures.

**Features**:

- View nearby stops
- Save favorite stops (via the menu*) and view anywhere
- View departures
  - Color coded and sectioned by mode
  - See deviations and their importance level
- Limit memory consumption by tuning settings*

\* Menu and settings are reached in the same way as usual. On some watches you long-press UP, on others BACK.

**Color coding**:

- Departure times: planned (white), expected (green)
- Deviation importance level: low (yellow), medium (orange), high (red), cancelled (strikethrough)
- Transport mode: matches SLs color coding

**Permissions** – The app uses Internet for making requests and GPS for fetching nearby stops. Minimum API level is 3.1.0.

**APIs** – Data is retrieved using Trafiklab's APIs "SL Nearby stops 2" and "SL Departures 4". Avgånär is in no way affiliated with Trafiklab or SL. Avgånär can not guarantee that presented data (e.g. departure times) are always correct.

**Privacy** – By downloading and using this app, you agree to the Privacy Policy (https://github.com/felwal/avganar/blob/main/PRIVACY.md). In short: Avgånär does not store any data, but location is sent to Trafiklab.

**Support** – For support, please contact me at felwal.studios@proton.me. I'll get back to you as soon as I can.

**Keywords** – public transport, public transit, commute, departures, travel, train, bus, metro, tram, light rail; kollektivtrafik, lokaltrafik, kommunaltrafik, pendel, avgångar, resa, tåg, buss, tunnelbana, lokalbana, spårvagn

## FAQ

**Nearby stops aren't updating** – Fetching nearby stops requires a GPS signal which might take some time. Try waiting a while, or going outside. The progress bar indicates if the app is waiting for location (⅓) or for API response (⅔).

**I keep getting "No Data"** – This is likely due to breaking API changes. Please try updating to the latest version of the app.

**I keep getting "Server Error"** – This is SL's problem and happens from time to time. All we can do is have patience.

**I keep getting "Client Error"** – This likely means that I have made some mistake. If you wouldn't mind, please get in touch with details.

**Long loading times** – If the loading bar consistently goes very far, this means that the responses are too large and must be requested again, asking for less data. Consider lowering “Default Time Window” in settings.
