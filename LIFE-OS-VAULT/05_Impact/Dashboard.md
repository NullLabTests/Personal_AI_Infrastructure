---
tags: [dashboard, impact, projects, live]
---

# 🌍 Impact Dashboard

\`\`\`dataviewjs
dv.paragraph(`**Last updated:** ${dv.date("now").toFormat("yyyy-MM-dd HH:mm")}`);
const projects = dv.pages('"05_Impact/Projects"')
  .where(p => p.file.name != "README");
dv.paragraph(`**Active projects:** ${projects.length}`);
const ideas = dv.pages('"05_Impact/Ideas"');
dv.paragraph(`**Ideas in pipeline:** ${ideas.length}`);
\`\`\`

## Active Projects

\`\`\`dataview
TABLE file.ctime as "Started", file.tags as "Tags"
FROM "05_Impact/Projects"
SORT file.ctime DESC
\`\`\`

## Content Published

\`\`\`dataview
TABLE file.ctime as "Published"
FROM "05_Impact/Content"
SORT file.ctime DESC
LIMIT 10
\`\`\`

## Ideas Pipeline

\`\`\`dataview
TABLE file.ctime as "Created"
FROM "05_Impact/Ideas"
SORT file.ctime DESC
\`\`\`

## Open Tasks Across Impact

\`\`\`dataview
TASK
FROM "05_Impact"
WHERE !completed
SORT file.ctime DESC
\`\`\`

## All Impact Notes

\`\`\`dataview
TABLE file.ctime as "Created"
FROM "05_Impact"
SORT file.ctime DESC
\`\`\`
