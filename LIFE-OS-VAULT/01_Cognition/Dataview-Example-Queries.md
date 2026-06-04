---
tags: [dataview, queries, dashboard]
---

# Dataview Example Queries

> Copy-paste these into any note to see live data. Requires the **Dataview** plugin.

## 1. Open Projects from 05_Impact

```dataview
TABLE file.ctime as "Created", file.tags as "Tags"
FROM "05_Impact/Projects"
WHERE file.name != "README"
SORT file.ctime DESC
```

## 2. Recent Daily Systems Reports

```dataview
TABLE date as "Date", Wins as "Top Win"
FROM "01_Cognition"
WHERE contains(file.name, "Daily-Systems-Report")
SORT date DESC
LIMIT 10
```

## 3. All Tasks Tagged #todo Across Vault

```dataview
TASK
FROM ""
WHERE contains(tags, "#todo") OR contains(text, "- [ ]")
GROUP BY file.link
SORT file.ctime DESC
```

## 4. Finance Summary from 03_Capital

```dataview
TABLE file.name as "Snapshot", date as "Date"
FROM "03_Capital/Net-Worth"
SORT date DESC
LIMIT 5
```

## 5. Latest People Notes

```dataview
TABLE file.ctime as "Last Updated"
FROM "04_Relationships/People"
SORT file.ctime DESC
LIMIT 10
```
