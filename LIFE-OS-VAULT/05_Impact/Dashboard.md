---
tags: [dashboard, impact, projects, live]
---

# Impact Dashboard

```dataviewjs
dv.paragraph(`**Last updated:** ${dv.date("now").toFormat("yyyy-MM-dd HH:mm")}`);
const projects = dv.pages('"05_Impact/Projects"').where(p => p.file.name != "README");
dv.paragraph(`**Active projects:** ${projects.length}`);
const ideas = dv.pages('"05_Impact/Ideas"');
dv.paragraph(`**Ideas incubating:** ${ideas.length}`);
```

## Active Projects

```dataview
TABLE file.ctime as "Started", status as "Status", priority as "Priority"
FROM "05_Impact/Projects"
WHERE status != "archived" AND file.name != "README"
SORT priority ASC
```

## Project Tasks

```dataview
TASK
FROM "05_Impact/Projects"
WHERE !completed
GROUP BY file.link
SORT file.ctime DESC
```

## Open Source Contributions

```dataview
TABLE date as "Date", repo as "Repo", type as "Type"
FROM "05_Impact/Open-Source"
SORT date DESC
LIMIT 20
```

## Content Published

```dataview
TABLE date as "Date", type as "Type", status as "Status"
FROM "05_Impact/Content"
SORT date DESC
LIMIT 20
```

## Idea Incubator

```dataview
TABLE file.ctime as "Created", confidence as "Confidence"
FROM "05_Impact/Ideas"
SORT confidence DESC
```
