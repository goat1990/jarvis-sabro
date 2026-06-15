#!/usr/bin/env bash
# Launch JARVIS backend + frontend detached, so they survive terminal/session close.
# Usage: ./start.sh   (logs in logs/, PIDs in .jarvis_pids)
cd "$(dirname "$0")"
mkdir -p logs

# Stop anything already running first
[ -f .jarvis_pids ] && kill $(cat .jarvis_pids) 2>/dev/null
pkill -f "server.py" 2>/dev/null
pkill -f "vite" 2>/dev/null
sleep 1

# Backend (FastAPI) — detached, ignores SIGHUP
nohup ./.venv/bin/python server.py > logs/backend.log 2>&1 &
BACK=$!
disown $BACK 2>/dev/null

# Frontend (Vite) — detached
( cd frontend && nohup npm run dev > ../logs/frontend.log 2>&1 & echo $! > ../.jarvis_front_pid )
sleep 1
FRONT=$(cat .jarvis_front_pid 2>/dev/null)
rm -f .jarvis_front_pid

echo "$BACK $FRONT" > .jarvis_pids

# Wait for both to listen
for i in $(seq 1 25); do
  grep -qiE "Uvicorn running" logs/backend.log 2>/dev/null && grep -qiE "Local:|ready in" logs/frontend.log 2>/dev/null && break
  sleep 1
done

echo "Backend  PID $BACK  -> http://127.0.0.1:8340  (logs/backend.log)"
echo "Frontend PID $FRONT -> http://localhost:5173    (logs/frontend.log)"
lsof -nP -iTCP:8340 -sTCP:LISTEN >/dev/null 2>&1 && echo "  8340 OK" || echo "  8340 NO ESCUCHA — revisa logs/backend.log"
lsof -nP -iTCP:5173 -sTCP:LISTEN >/dev/null 2>&1 && echo "  5173 OK" || echo "  5173 NO ESCUCHA — revisa logs/frontend.log"
