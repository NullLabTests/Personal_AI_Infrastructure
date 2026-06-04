---
tags: [dashboard, body, health, live]
---

# Body Dashboard

```dataviewjs
dv.paragraph(`**Last updated:** ${dv.date("now").toFormat("yyyy-MM-dd HH:mm")}`);
const notes = dv.pages('"02_Body"').where(p => p.file.name != "README" && p.file.name != "Dashboard");
dv.paragraph(`**Health notes archived:** ${notes.length}`);
```

## Sleep Log

```dataview
TABLE date as "Date", score as "Score", hrv as "HRV"
FROM "02_Body/Sleep"
SORT date DESC
LIMIT 14
```

## Bloodwork History

```dataview
TABLE date as "Date", file.tags as "Markers"
FROM "02_Body/Bloodwork"
SORT date DESC
LIMIT 10
```

## Workout Log

```dataview
TABLE date as "Date", type as "Type", duration as "Duration"
FROM "02_Body/Workouts"
SORT date DESC
LIMIT 20
```

## Metrics Overview

```dataview
TABLE rows.file.link as "Date", rows.weight as "Weight"
FROM "02_Body/Metrics"
FLATTEN file.name
GROUP BY date
SORT date DESC
LIMIT 30
```
