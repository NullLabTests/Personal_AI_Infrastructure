# ForgeOS Five-Stack Architecture Diagram

## Mermaid (renders on GitHub)

```mermaid
graph TD
    subgraph "ForgeOS — Five Life Stacks"
        C1[🧠 01_Cognition<br/>Mental Models, Decisions, Daily Reports]
        C2[💪 02_Body<br/>Health Metrics, Sleep, Bloodwork]
        C3[💰 03_Capital<br/>Finances, Net Worth, Budget]
        C4[🤝 04_Relationships<br/>People, Commitments, Meetings]
        C5[🌍 05_Impact<br/>Projects, Content, Output]
    end

    subgraph "Feedback Loops"
        C1 -->|directs| C2
        C2 -->|resources| C3
        C3 -->|enables| C4
        C4 -->|collaborates| C5
        C5 -->|learns| C1
    end

    subgraph "AI Layer (Local)"
        OLLAMA[Ollama - Qwen 2.5 7B<br/>DeepSeek R1 7B]
        PAI[PAI Interface<br/>Agents + Workflows]
        DV[Obsidian Dataview<br/>Live Queries]
        OLLAMA --> PAI
        PAI --> C1
        DV --> C1
        DV --> C2
        DV --> C3
        DV --> C4
        DV --> C5
    end

    style C1 fill:#4a6cf7,stroke:#fff,color:#fff
    style C2 fill:#10b981,stroke:#fff,color:#fff
    style C3 fill:#f59e0b,stroke:#fff,color:#fff
    style C4 fill:#ec4899,stroke:#fff,color:#fff
    style C5 fill:#8b5cf6,stroke:#fff,color:#fff
    style OLLAMA fill:#1e293b,stroke:#64748b,color:#fff
    style PAI fill:#1e293b,stroke:#64748b,color:#fff
    style DV fill:#1e293b,stroke:#64748b,color:#fff
```

## ASCII Art

```
┌──────────────────────────────────────────────────────────────┐
│                     FORGEOS — FIVE STACKS                    │
│                    (with feedback loops)                     │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  01_Cognition  ──────────────────────────────→  02_Body      │
│  (Mental Models,   ←─────────────────────────  (Health,      │
│   Decisions,        Feedback Loop: Learning     Sleep,       │
│   Daily Reports)     informs all stacks        Bloodwork)   │
│       ↑                                                  ↓   │
│       │                                                  │   │
│       │              03_Capital                           │   │
│       │              (Finances, Budget,                   │   │
│       │               Net Worth)                          │   │
│       │                  ↓                                │   │
│       │              04_Relationships                      │   │
│       │              (People, Commitments,                │   │
│       │               Meetings)                           │   │
│       │                  ↓                                │   │
│       └────────── 05_Impact  ←───────────────────────────┘   │
│                  (Projects, Content,                        │
│                   Legacy)                                   │
│                                                              │
│               ┌────────────────────────┐                    │
│               │   AI Layer (Local)    │                    │
│               │  Ollama → Qwen 7B    │                    │
│               │  PAI Agents          │                    │
│               │  Dataview Queries    │                    │
│               └────────┬───────────────┘                    │
│                        ↓                                    │
│               Queries all 5 stacks                          │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```
