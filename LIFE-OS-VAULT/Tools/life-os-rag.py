#!/usr/bin/env python3
"""
Life OS RAG Pipeline — semantic search across the vault using Ollama embeddings.

Usage:
  python3 life-os-rag.py index          # Build/refresh the embedding index
  python3 life-os-rag.py query "..."    # Search semantically
  python3 life-os-rag.py ask "..."      # Query + DeepSeek answers using context
"""

import sys, os, json, glob, re, time, hashlib
from pathlib import Path

VAULT_DIR = Path(__file__).parent.parent.resolve()
INDEX_FILE = VAULT_DIR / ".rag-index.json"
OLLAMA_URL = "http://localhost:11434"
EMBED_MODEL = "nomic-embed-text"
CHAT_MODEL = "deepseek-r1:1.5b"
MAX_CHUNKS = 5
CHUNK_DISPLAY = 1200

def embed(text: str) -> list[float]:
    import urllib.request
    payload = json.dumps({"model": EMBED_MODEL, "prompt": text}).encode()
    req = urllib.request.Request(f"{OLLAMA_URL}/api/embeddings", data=payload,
                                 headers={"Content-Type": "application/json"})
    resp = urllib.request.urlopen(req, timeout=60)
    return json.loads(resp.read())["embedding"]

def cosine_sim(a: list[float], b: list[float]) -> float:
    dot = sum(x*y for x,y in zip(a,b))
    na = sum(x*x for x in a)**0.5
    nb = sum(x*x for x in b)**0.5
    return dot / (na * nb) if na and nb else 0.0

def load_index() -> dict:
    if INDEX_FILE.exists():
        return json.loads(INDEX_FILE.read_text())
    return {"chunks": [], "version": 1}

def save_index(index: dict):
    INDEX_FILE.write_text(json.dumps(index, indent=2))

def get_md_files():
    return sorted(VAULT_DIR.rglob("*.md"))

def chunk_text(text: str, max_chars=1200) -> list[str]:
    chunks = []
    paragraphs = text.split("\n\n")
    current = ""
    for p in paragraphs:
        p = p.strip()
        if not p:
            continue
        if len(current) + len(p) < max_chars:
            current += "\n\n" + p if current else p
        else:
            if current:
                chunks.append(current[:max_chars])
            current = p
    if current:
        chunks.append(current[:max_chars])
    return chunks or [text[:max_chars]]

def cmd_index():
    index = load_index()
    files = get_md_files()
    new_chunks = []
    total = 0
    for fpath in files:
        rel = str(fpath.relative_to(VAULT_DIR))
        text = fpath.read_text(encoding="utf-8", errors="replace")
        chunks = chunk_text(text)
        for c in chunks:
            cid = hashlib.sha256(f"{rel}:{c[:50]}".encode()).hexdigest()[:12]
            new_chunks.append({"id": cid, "file": rel, "text": c})
            total += 1

    print(f"Indexing {total} chunks from {len(files)} files...")
    for i, chunk in enumerate(new_chunks):
        chunk["embedding"] = embed(chunk["text"])
        if (i+1) % 5 == 0 or i == total-1:
            print(f"  [{i+1}/{total}] embedded")

    index["chunks"] = new_chunks
    index["file_count"] = len(files)
    index["chunk_count"] = total
    index["updated"] = time.time()
    save_index(index)
    print(f"Index saved to {INDEX_FILE}")

def cmd_query(query: str):
    index = load_index()
    if not index.get("chunks"):
        print("No index found. Run 'index' first.")
        return
    qvec = embed(query)
    scored = [(cosine_sim(qvec, c["embedding"]), c) for c in index["chunks"]]
    scored.sort(key=lambda x: -x[0])
    seen_files = set()
    rank = 0
    for score, chunk in scored:
        if score < 0.3:
            break
        if chunk["file"] in seen_files:
            continue
        seen_files.add(chunk["file"])
        rank += 1
        print(f"\n--- [{rank}] {chunk['file']} (score: {score:.3f}) ---")
        print(chunk["text"][:300])
        if rank >= MAX_CHUNKS:
            break
    if not seen_files:
        print("No semantically close results found.")

def cmd_ask(query: str):
    """RAG-powered Q&A. Note: for CPU-only 1.5B models, semantic search is reliable but
    LLM-grounded answers may hallucinate. The context is shown for your verification."""
    index = load_index()
    if not index.get("chunks"):
        print("No index found. Run 'index' first.")
        return
    qvec = embed(query)
    scored = [(cosine_sim(qvec, c["embedding"]), c) for c in index["chunks"]]
    scored.sort(key=lambda x: -x[0])
    context_parts = []
    seen = set()
    for score, chunk in scored:
        if score < 0.3 or len(seen) >= 3:
            break
        if chunk["file"] not in seen:
            seen.add(chunk["file"])
            context_parts.append(f"=== {chunk['file']} ===\n{chunk['text'][:CHUNK_DISPLAY]}")
    context = "\n\n".join(context_parts)

    # Show context to user first (transparency)
    print("\n--- Relevant Context ---")
    for s in seen:
        print(f"  - {s}")
    print()

    import urllib.request
    system = "You are DeepSeek R1. Answer using ONLY the context below. If unsure, say 'Not in context.'"
    messages = [
        {"role": "system", "content": system},
        {"role": "user", "content": f"Context:\n{context}\n\n---\n\nQuestion: {query}\n\n(Answer from context only or say 'Not in context.')"},
    ]
    payload = json.dumps({"model": CHAT_MODEL, "messages": messages, "stream": False}).encode()
    req = urllib.request.Request(f"{OLLAMA_URL}/api/chat", data=payload,
                                 headers={"Content-Type": "application/json"})
    resp = urllib.request.urlopen(req, timeout=300)
    data = json.loads(resp.read())
    reply = data.get("message", {}).get("content", "")
    clean = re.sub(r'<think>.*?</think>', '', reply, flags=re.DOTALL).strip()
    print(f"--- DeepSeek Answer ---\n{clean}\n")
    print("--- Note: 1.5B models may hallucinate. Verify answers against the context shown above. ---")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)
    cmd = sys.argv[1]
    if cmd == "index":
        cmd_index()
    elif cmd == "query" and len(sys.argv) > 2:
        cmd_query(sys.argv[2])
    elif cmd == "ask" and len(sys.argv) > 2:
        cmd_ask(sys.argv[2])
    elif cmd == "extract" and len(sys.argv) > 2:
        cmd_query(sys.argv[2])
    else:
        print(__doc__)
