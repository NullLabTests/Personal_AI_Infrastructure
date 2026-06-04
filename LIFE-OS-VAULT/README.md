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

- **01_Cognition**: Mental models, decision logs, Daily Systems Reports, chat histories with PAI/local LLM. *The executive center.*
- **02_Body**: Health metrics, sleep data, bloodwork, Oura/Whoop exports. *The sensory layer.*
- **03_Capital**: Finances, investments, budget tracking, net worth. *The resource layer.*
- **04_Relationships**: People notes, commitments, meeting logs. *The social layer.*
- **05_Impact**: Projects, creative output, open-source plans, content. *The actuation layer.* Each feeds the next and loops back into cognition.

## PAI Pulse Dashboard

ForgeOS ships with **PAI Pulse** — a real-time life dashboard at **`http://localhost:31337`**. It renders your goals, metrics, projects, budget, team, and recommendations.

```bash
# Start the dashboard
cd ~/.claude/PAI/PULSE && bun run pulse.ts
# Then open http://localhost:31337
```

The dashboard covers all five stacks: Cognition (goals/recs), Body (health metrics), Capital (budget), Relationships (team/people), Impact (projects).

## Integration with PAI + Local LLM

This vault pairs with the **PAI (Personal AI Infrastructure)** codebase running in this Codespace. The local **Qwen 2.5 7B** or **DeepSeek R1 7B** model (via Ollama) can:
- Ingest Daily Systems Reports and suggest next actions
- Cross-reference health data (02_Body) with cognitive performance (01_Cognition)
- Query vault contents via vector embeddings (future: RAG with `nomic-embed-text`)
- Generate financial summaries from 03_Capital CSVs
- Draft project plans in 05_Impact

LLM endpoint: `http://localhost:11434` (Ollama, local only — no API keys, no external calls)

## Recommended Obsidian Plugins

> These turn a folder of markdown files into a **living dashboard**.

| Plugin | Why |
|--------|-----|
| **Dataview** | **Essential.** Query any note across the vault as a live database. Filter by tags, dates, fields, links. Powers the dashboards below. |
| Periodic Notes | Auto-create Daily/Weekly/Monthly notes from templates. Keeps 01_Cognition flowing. |
| Tasks | Rich task management with dates, priorities, project groupings. Syncs with Dataview queries. |
| Calendar | Visual calendar view — click any date to open or create its daily note. |
| Kanban | Turn lists into boards for project tracking in 05_Impact. |

With Dataview alone, this vault becomes queryable like a database:
```dataview
TABLE file.ctime, file.tags
FROM "01_Cognition"
SORT file.ctime DESC
```

---

*Initialized: 2026-06-04 | Repository: github.com/NullLabTests/ForgeOS*
