---
tags: [dashboard, capital, finance, live]
---

# 💰 Capital Dashboard

\`\`\`dataviewjs
dv.paragraph(`**Last updated:** ${dv.date("now").toFormat("yyyy-MM-dd HH:mm")}`);
const notes = dv.pages('"03_Capital"')
  .where(p => p.file.name != "README" && p.file.name != "Dashboard");
dv.paragraph(`**Financial snapshots:** ${notes.length}`);
dv.paragraph(`**Tracked in vault:** Budget, Net Worth, Investments, Expenses`);
\`\`\`

## Recent Financial Records

\`\`\`dataview
TABLE file.ctime as "Date", file.tags as "Tags"
FROM "03_Capital"
WHERE file.name != "README" AND file.name != "Dashboard"
SORT file.ctime DESC
LIMIT 10
\`\`\`

## All Capital Notes

\`\`\`dataview
TABLE file.ctime as "Created"
FROM "03_Capital"
SORT file.ctime DESC
\`\`\`
