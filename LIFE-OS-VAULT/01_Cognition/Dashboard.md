---
tags: [dashboard, cognition, live]
---

# 🧠 Cognition Dashboard

\`\`\`dataviewjs
dv.paragraph(`**Last updated:** ${dv.date("now").toFormat("yyyy-MM-dd HH:mm")}`);
const reports = dv.pages('"01_Cognition"')
  .where(p => p.file.name.includes("Daily-Systems-Report"));
dv.paragraph(`**Daily reports logged:** ${reports.length}`);
const latest = reports.sort(p => p.date, 'desc')[0];
if (latest) dv.paragraph(`**Latest:** ${latest.file.link} (${latest.date})`);
\`\`\`

## Recent Daily Reports

\`\`\`dataview
TABLE date as "Date", Wins as "Top Win", Blockers as "Blockers"
FROM "01_Cognition"
WHERE contains(file.name, "Daily-Systems-Report")
SORT date DESC
LIMIT 10
\`\`\`

## Open Tasks

\`\`\`dataview
TASK
FROM "01_Cognition"
WHERE !completed AND !contains(text, "[]")
SORT file.ctime DESC
\`\`\`

## Decision Log

\`\`\`dataview
TABLE date as "Date", status as "Status"
FROM "01_Cognition/Decision-Log"
SORT date DESC
\`\`\`

## All Files

\`\`\`dataview
TABLE file.ctime as "Created", file.tags as "Tags"
FROM "01_Cognition"
SORT file.ctime DESC
\`\`\`
