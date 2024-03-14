# Beskrivning

Avgånär är en widget för kollektivtrafik som visar närliggande hållplatser och avgångar inom Stockholms Lokaltrafik (SL) i Sverige.

För täckning av hela Sverige, se Avgånär: Sverige avgångar.

**Funktioner**:

- Visa närliggande hållplatser
- Spara favoriter (via menyn*) och visa var som helst
- Visa avgångar
  - Färgkodade och uppdelade efter transporttyp
  - Se avvikelser och deras viktighetsnivå
- Begränsa minnesbelastning genom att justera inställningar*

\* Meny och inställningar nås på samma sätt som vanligt. På vissa klockor håller man inne UP, på andra BACK.

**Färgkodning**:

- Avgångstider: planerade (vit), förväntade (grön)
- Avvikelsers viktighetsnivå: låg (gul), medium (orange), hög (röd), inställd (genomstruken)
- Transporttyp: matchar SL:s färgkodning

**Behörigheter** – Appen använder internet för att hämta data och GPS för att hitta närliggande hållplatser. Minsta API-nivå är 3.1.0.

**API:er** – Data hämtas från Trafiklabs API:er "SL Närliggande hållplatser 2" och "SL Realtidsinformation 4". Avgånär är inte på något sätt ansluten till Trafiklab eller SL. Avgånär kan inte garantera att presenterad data (ex. avgångstider) alltid är korrekta.

**Integritet** – Genom att ladda ned och använda appen godkänner du integritetspolicyn (https://github.com/felwal/avganar/blob/main/PRIVACY.md). I korthet: Avgånär sparar ingen data, men platsdata skickas till Trafiklab.

**Support** – För support, vänligen kontakta mig via felwal.studios@proton.me.

**Nyckelord** – kollektivtrafik, lokaltrafik, kommunaltrafik, pendel, avgångar, resa, tåg, buss, tunnelbana, lokalbana, spårvagn; public transport, commute, departures, travel, train, bus, metro, tram, light rail

## FAQ

**Närliggande hållpatser uppdaterar inte** – Att hämta närliggande hållplatser kräver GPS-signal vilket kan ta lite tid. Försök med att vänta ett tag, eller gå utomhus. Progress-baren indikerar om appen väntar på platsdata (⅓) eller på API-svar (⅔).

**Jag fortsätter få "Ogiltig begäran"** – Detta är troligen pga API-förändringar. Vänligen pröva uppdatera till den senaste versionen.

**Jag fortsätter få "Serverfel"** – Detta är SL:s problem och händer då och då. Allt vi kan göra är att ha tålamod.

**Jag fortsätter få "Klientfel"** – Detta är troligen mitt fel. Jag kulle uppskatta om du ville skicka detaljer till mailadressen ovan.

**Långa laddningstider** – Om progress-baren konsekvent går väldigt långt betyder detta att svaren är för stora och måste bes om igen, med mindre data. Överväg att minska "Största tidsfönster" i inställningarna.
