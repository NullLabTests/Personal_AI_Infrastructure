---
tags: [dashboard, capital, finance, net-worth, live]
---

# Capital Dashboard

```dataviewjs
dv.paragraph(`**Last updated:** ${dv.date("now").toFormat("yyyy-MM-dd HH:mm")}`);
const snapshots = dv.pages('"03_Capital/Net-Worth"').sort(p => p.date, 'desc');
if (snapshots.length > 0) {
  dv.paragraph(`**Latest net worth snapshot:** ${snapshots[0].file.link}`);
  dv.paragraph(`**Net worth trend:** ${snapshots.length} snapshots tracked`);
}
```

## Net Worth Timeline

```dataview
TABLE date as "Date", total as "Total", assets as "Assets", liabilities as "Liabilities"
FROM "03_Capital/Net-Worth"
SORT date DESC
LIMIT 12
```

## Budget Variance

```dataview
TABLE date as "Month", planned as "Planned", actual as "Actual", variance as "Variance"
FROM "03_Capital/Budget"
SORT date DESC
LIMIT 12
```

## Investment Allocation

```dataview
TABLE date as "Date", asset_class as "Class", allocation as "Allocation %"
FROM "03_Capital/Investments"
SORT date DESC
LIMIT 20
```

## Recent Expenses

```dataview
TABLE date as "Date", category as "Category", amount as "Amount", note as "Note"
FROM "03_Capital/Expenses"
SORT date DESC
LIMIT 30
```
