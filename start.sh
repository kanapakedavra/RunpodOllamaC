#!/usr/bin/env bash
set -euo pipefail

# 1. start daemon
ollama serve 2>&1 | tee /var/log/ollama.log &
OLLAMA_PID=$!

# 2. wait until it listens (max 30 s)
for _ in {1..30}; do
  grep -q "Listening" /var/log/ollama.log && break
  sleep 1
done

# 3. *don't* pull again if the model is already baked in
if ! ollama list | grep -q "^$1 "; then
  ollama pull "$1"
fi

# 4. launch your wrapper
exec python3 -u runpod_wrapper.py "$1"