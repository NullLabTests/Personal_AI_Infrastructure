#!/usr/bin/env python3
"""
Life OS CLI Assistant — ask DeepSeek about your vault.
Usage:
  ./life-os-ask.py "your question" [model]
  ./life-os-ask.py --chat              # interactive
"""

import sys, json, re, urllib.request, subprocess

OLLAMA = "http://localhost:11434"
VAULT_DIR = (__file__ and (__import__("pathlib").Path(__file__).parent.parent)) or None

def call_ollama(messages, model="deepseek-r1:1.5b", timeout=300):
    data = json.dumps({"model": model, "messages": messages, "stream": False}).encode()
    req = urllib.request.Request(f"{OLLAMA}/api/chat", data=data, headers={"Content-Type": "application/json"})
    resp = urllib.request.urlopen(req, timeout=timeout)
    d = json.loads(resp.read())
    return re.sub(r'<think>.*?</think>', '', d.get("message", {}).get("content", ""), flags=re.DOTALL).strip()

def chat_mode():
    print(f"Life OS Chat (DeepSeek) — Ctrl+D to exit\n{'='*45}")
    msgs = [{"role": "system", "content": "You are DeepSeek R1 for TheGoldenAnchor Life OS (5 stacks: Cognition, Body, Capital, Relationships, Impact). Answer concisely."}]
    while True:
        try:
            q = input("> ")
        except EOFError:
            break
        if not q:
            continue
        msgs.append({"role": "user", "content": q})
        print()
        reply = call_ollama(msgs)
        print(reply, "\n")
        msgs.append({"role": "assistant", "content": reply})

def ask(query, model="deepseek-r1:1.5b"):
    print("Searching vault for context...")
    result = subprocess.run(
        [sys.executable, str(VAULT_DIR / "Tools" / "life-os-rag.py"), "query", query],
        capture_output=True, text=True, timeout=60
    )
    context = result.stdout.strip() if result.returncode == 0 else ""

    system = "You are DeepSeek R1 for TheGoldenAnchor Life OS. Answer ONLY using the vault context below. If the context doesn't contain the answer, say 'Not found in vault.' Be concise."
    prompt = f"Question: {query}\n\nVault context:\n{context}\n\n(Answer based only on context above)"

    print("Asking DeepSeek...")
    reply = call_ollama([
        {"role": "system", "content": system},
        {"role": "user", "content": prompt}
    ], model)
    print(reply)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)
    if sys.argv[1] == "--chat":
        chat_mode()
    else:
        model = sys.argv[2] if len(sys.argv) > 2 else "deepseek-r1:1.5b"
        ask(sys.argv[1], model)
