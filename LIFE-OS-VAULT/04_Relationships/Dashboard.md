---
tags: [dashboard, relationships, people, live]
---

# Relationships Dashboard

```dataviewjs
dv.paragraph(`**Last updated:** ${dv.date("now").toFormat("yyyy-MM-dd HH:mm")}`);
const people = dv.pages('"04_Relationships/People"');
dv.paragraph(`**People tracked:** ${people.length}`);
const meetings = dv.pages('"04_Relationships/Meetings"').sort(p => p.date, 'desc');
dv.paragraph(`**Recent meetings:** ${meetings.length} total`);
```

## People Directory

```dataview
TABLE file.ctime as "Since", file.tags as "Tags", last_contact as "Last Contact"
FROM "04_Relationships/People"
SORT last_contact ASC
LIMIT 50
```

## Meeting History

```dataview
TABLE date as "Date", person as "Person", type as "Type", summary as "Summary"
FROM "04_Relationships/Meetings"
SORT date DESC
LIMIT 20
```

## Open Commitments

```dataview
TASK
FROM "04_Relationships/Commitments"
WHERE !completed
SORT due ASC
```

## Relationship Reflections

```dataview
TABLE date as "Date", person as "Person", rating as "Health"
FROM "04_Relationships/Annual-Review"
SORT date DESC
LIMIT 10
```
