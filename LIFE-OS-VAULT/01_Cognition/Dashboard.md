---
tags: [dashboard, cognition, live]
---

# Cognition Dashboard

```dataviewjs
const today = dv.date("today");
const currentFile = dv.current().file.path;

dv.paragraph(`**Last updated:** ${dv.date("now").toFormat("yyyy-MM-dd HH:mm")}`);
dv.paragraph(`**Daily streak:** Check consecutive Daily-Systems-Report files`);
```

## Recent Daily Reports

```dataview
TABLE date as "Date", Wins as "Top Win"
FROM "01_Cognition"
WHERE contains(file.name, "Daily-Systems-Report")
SORT date DESC
LIMIT 10
```

## Open Decisions & Next Actions

```dataview
TASK
FROM "01_Cognition"
WHERE !completed
SORT file.ctime DESC
```

## All Cognition Notes

```dataview
TABLE file.ctime as "Created", file.tags as "Tags"
FROM "01_Cognition"
SORT file.ctime DESC
```
