---
tags: [dashboard, body, health, live]
---

# 💪 Body Dashboard

\`\`\`dataviewjs
dv.paragraph(`**Last updated:** ${dv.date("now").toFormat("yyyy-MM-dd HH:mm")}`);
const notes = dv.pages('"02_Body"')
  .where(p => p.file.name != "README" && p.file.name != "Dashboard");
dv.paragraph(`**Health notes archived:** ${notes.length}`);
dv.paragraph(`**Categories:** Sleep, Exercise, Bloodwork, Metrics`);
\`\`\`

## Recent Health Logs

\`\`\`dataview
TABLE file.ctime as "Date", file.tags as "Tags"
FROM "02_Body"
WHERE file.name != "README" AND file.name != "Dashboard"
SORT file.ctime DESC
LIMIT 10
\`\`\`

## All Body Notes

\`\`\`dataview
TABLE file.ctime as "Created"
FROM "02_Body"
SORT file.ctime DESC
\`\`\`
