# Life OS Tools

CLI tools for interacting with the vault via DeepSeek + Ollama.

## Quick Start

```bash
# Index vault for semantic search (do once, re-run after adding notes)
python3 life-os-rag.py index

# Search vault semantically
python3 life-os-rag.py query "sleep and exercise trends"

# Ask DeepSeek with RAG context (1.5B — verify answers!)
python3 life-os-rag.py ask "what are my active projects?"

# Interactive chat with DeepSeek
bash life-os-ask.sh --chat

# One-shot question
bash life-os-ask.sh "what is in my body stack?"
```

## Tools

### `life-os-rag.py` — Semantic Search + RAG
- `index` — Build embedding index using `nomic-embed-text`
- `query "..."` — Find semantically similar notes
- `ask "..."` — Query + ask DeepSeek with context
- `extract "..."` — Same as query (alias)

### `life-os-ask.sh` — CLI Chat
- Wraps `life-os-rag.py` and Ollama API
- `--chat` for interactive mode
- Accepts optional model name as 2nd arg

### `ollama-webui.html` — Browser Chat
Open in browser or serve via:
```bash
python3 -m http.server 8080 --directory "$(dirname "$(dirname "$(readlink -f "$0")")")/Tools"
# → http://localhost:8080/ollama-webui.html
```

## Models Available

| Model | Size | Use Case |
|-------|------|----------|
| `deepseek-r1:1.5b` | 1.1 GB | Default — fast chat, light RAG |
| `deepseek-r1:7b` | 4.7 GB | Higher quality (needs 5GB+ free RAM) |
| `nomic-embed-text` | 274 MB | Embeddings for semantic search |

## Note on RAG Quality

The 1.5B DeepSeek model is fast but may hallucinate when answering from context.
Always verify against the sources shown. For production RAG quality, use the 7B model
when more RAM is available, or use `query` mode to read context directly.
