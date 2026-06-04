---
tags: [dashboard, relationships, people, live]
---

# 🤝 Relationships Dashboard

\`\`\`dataviewjs
dv.paragraph(`**Last updated:** ${dv.date("now").toFormat("yyyy-MM-dd HH:mm")}`);
const people = dv.pages('"04_Relationships/People"')
  .where(p => p.file.name != "TEMPLATE");
dv.paragraph(`**People tracked:** ${people.length}`);
const active = people.where(p => p.status == "active");
dv.paragraph(`**Active connections:** ${active.length}`);
\`\`\`

## People Directory

\`\`\`dataview
TABLE status as "Status", last-contact as "Last Contact"
FROM "04_Relationships/People"
WHERE file.name != "TEMPLATE"
SORT last-contact DESC
\`\`\`

## Meeting Logs

\`\`\`dataview
TABLE file.ctime as "Date"
FROM "04_Relationships/Meetings"
SORT file.ctime DESC
LIMIT 10
\`\`\`

## Open Commitments

\`\`\`dataview
TASK
FROM "04_Relationships"
WHERE !completed
SORT file.ctime DESC
\`\`\`

## All Relationship Notes

\`\`\`dataview
TABLE file.ctime as "Created"
FROM "04_Relationships"
SORT file.ctime DESC
\`\`\`
