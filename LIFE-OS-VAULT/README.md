# ⚒️ ForgeOS — Single Source of Truth

> *"A life unexamined is not worth living. A life unrecorded cannot be improved."*

## Vision

ForgeOS is a living, queryable, version-controlled second brain — a Single Source of Truth for every dimension of life: mind, body, capital, relationships, and impact. Every note, metric, decision, and reflection lives in one place, linkable, taggable, and queryable via Obsidian Dataview.

## The Five Stacks (Feedback Loop)

```
 01_Cognition ————————————→ 02_Body
     ↑                            ↓
     |                         03_Capital
     ↑                            ↓
     |                         04_Relationships
     ↑                            ↓
     +———— 05_Impact ←———————+
```

| Stack | Layer | Purpose |
|-------|-------|---------|
| [🧠 **01_Cognition**](01_Cognition/) | Executive | Mental models, decisions, daily reports, chat histories |
| [💪 **02_Body**](02_Body/) | Sensory | Health metrics, sleep, bloodwork, Oura/Whoop exports |
| [💰 **03_Capital**](03_Capital/) | Resource | Finances, investments, budget tracking, net worth |
| [🤝 **04_Relationships**](04_Relationships/) | Social | People notes, commitments, meeting logs |
| [🌍 **05_Impact**](05_Impact/) | Actuation | Projects, creative output, open-source, content |

## Live Dashboards

Each stack has a `Dashboard.md` with DataviewJS queries — open them in Obsidian with the **Dataview plugin** enabled:

| Stack | Dashboard | Key Query |
|-------|-----------|-----------|
| 🧠 Cognition | [`01_Cognition/Dashboard.md`](01_Cognition/Dashboard.md) | Recent reports, open tasks |
| 💪 Body | [`02_Body/Dashboard.md`](02_Body/Dashboard.md) | Health metrics summary |
| 💰 Capital | [`03_Capital/Dashboard.md`](03_Capital/Dashboard.md) | Budget variance, net worth |
| 🤝 Relationships | [`04_Relationships/Dashboard.md`](04_Relationships/Dashboard.md) | People directory, due commitments |
| 🌍 Impact | [`05_Impact/Dashboard.md`](05_Impact/Dashboard.md) | Active projects, ideas pipeline |

Example query — recent reports across the vault:
```
\`\`\`dataview
TABLE date as "Date", Wins as "Top Win"
FROM "01_Cognition"
WHERE contains(file.name, "Daily-Systems-Report")
SORT date DESC
LIMIT 10
\`\`\`
```

## Templates

| Template | Location | Use |
|----------|----------|-----|
| Daily Report | `01_Cognition/Daily-Systems-Report-YYYY-MM-DD.md` | `./forgeos report` or copy date-stamped file |
| Decision Log | `01_Cognition/Decision-Log/TEMPLATE.md` | Document every significant decision with context, options, outcome |
| Monthly Review | `01_Cognition/Monthly-Review-Template.md` | Cross-stack monthly reflection |
| People Note | `04_Relationships/People/TEMPLATE.md` | Per-person context, commitments, history |
| Budget CSV | `03_Capital/Budget/budget-template.csv` | Income vs expense tracking |

## PAI Pulse Dashboard

ForgeOS ships with **PAI Pulse** — a real-time life dashboard at **`http://localhost:31337`** covering goals, metrics, projects, budget, team, and recommendations across all 5 stacks.

## Integration with Local LLM

This vault pairs with Ollama + DeepSeek R1 7B (or Qwen 2.5 7B). The LLM can:

- Ingest Daily Systems Reports and suggest next actions
- Cross-reference health data with cognitive performance
- Query vault contents via RAG (`./Tools/ask-vault.sh`)
- Generate financial summaries from 03_Capital CSVs
- Draft project plans in 05_Impact

LLM endpoint: `http://localhost:11434` — local only, no API keys.

## Recommended Obsidian Plugins

| Plugin | Why |
|--------|-----|
| **Dataview** | Essential — query any note as a live database. Powers all dashboards. |
| Periodic Notes | Auto-create Daily/Weekly/Monthly notes from templates |
| Tasks | Rich task management with dates, priorities, project groupings |
| Calendar | Visual calendar — click any date to open daily note |
| Kanban | Turn lists into boards for project tracking |

## Repository

```bash
# Quick start
git clone https://github.com/NullLabTests/ForgeOS.git
cd ForgeOS
./setup.sh               # Install everything
./forgeos start           # Start Ollama + Dashboard
./forgeos report          # First daily report
```

---

*Initialized: 2026-06-04 · Repository: [github.com/NullLabTests/ForgeOS](https://github.com/NullLabTests/ForgeOS)*
