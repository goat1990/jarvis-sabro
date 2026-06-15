#!/usr/bin/env bash
# Stop JARVIS backend + frontend.
cd "$(dirname "$0")"
[ -f .jarvis_pids ] && kill $(cat .jarvis_pids) 2>/dev/null
pkill -f "server.py" 2>/dev/null
pkill -f "vite" 2>/dev/null
rm -f .jarvis_pids
echo "JARVIS detenido."
