#!/usr/bin/env bash
set -e

# ==============================
# AI Assistant Launcher (Linux/macOS)
# ==============================

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

VENV_DIR=".venv"
SERVER_HOST="127.0.0.1"
API_PORT="8765"
WEB_PORT="5500"

echo "=============================="
echo "AI Assistant Launcher"
echo "=============================="
echo "Project: $PROJECT_DIR"
echo "venv   : $VENV_DIR"
echo "API    : http://$SERVER_HOST:$API_PORT"
echo "Web    : http://$SERVER_HOST:$WEB_PORT/static/index.html"
echo

# ------------------------------
# Check Python
# ------------------------------
PYTHON_CMD=""

if command -v python3 >/dev/null 2>&1; then
  PYTHON_CMD="python3"
elif command -v python >/dev/null 2>&1; then
  PYTHON_CMD="python"
else
  echo "ERROR: Python not found. Please install Python 3."
  exit 1
fi

echo "Using Python: $PYTHON_CMD"
echo

# ------------------------------
# Check requirements.txt
# ------------------------------
if [ ! -f "requirements.txt" ]; then
  echo "ERROR: Missing requirements.txt"
  exit 1
fi

# ------------------------------
# Create virtual environment
# ------------------------------
if [ ! -f "$VENV_DIR/bin/python" ]; then
  echo "Creating venv: $VENV_DIR ..."
  $PYTHON_CMD -m venv "$VENV_DIR"
  echo "venv created."
else
  echo "venv exists."
fi
echo

# ------------------------------
# Activate venv
# ------------------------------
# shellcheck disable=SC1091
source "$VENV_DIR/bin/activate"

echo "Activated venv: $VENV_DIR"
python --version
echo

# ------------------------------
# Install dependencies
# ------------------------------
echo "Installing requirements..."
python -m pip install -U pip >/dev/null 2>&1
python -m pip install -U -r requirements.txt
echo "Requirements OK."
echo

# ------------------------------
# Check required files
# ------------------------------
if [ ! -f "local_server.py" ]; then
  echo "ERROR: Missing local_server.py"
  exit 1
fi

if [ ! -f "static/index.html" ]; then
  echo "WARNING: static/index.html not found"
fi

# ------------------------------
# Start servers (background)
# ------------------------------
cleanup() {
  echo
  echo "Stopping services..."
  [ -n "${API_PID:-}" ] && kill "$API_PID" 2>/dev/null || true
  [ -n "${WEB_PID:-}" ] && kill "$WEB_PID" 2>/dev/null || true
  echo "Done."
}
trap cleanup EXIT INT TERM

echo "Starting local_server.py ..."
python local_server.py &
API_PID=$!
sleep 2

echo "Starting static web server ..."
python -m http.server "$WEB_PORT" --bind "$SERVER_HOST" &
WEB_PID=$!
sleep 1

# ------------------------------
# Open browser
# ------------------------------
URL="http://$SERVER_HOST:$WEB_PORT/static/index.html"
echo "Opening browser: $URL"

if command -v xdg-open >/dev/null 2>&1; then
  xdg-open "$URL" >/dev/null 2>&1 || true
elif command -v open >/dev/null 2>&1; then
  open "$URL" >/dev/null 2>&1 || true
else
  echo "INFO: No browser opener found (xdg-open/open). Please open manually."
fi

echo
echo "Done!"
echo "- API: http://$SERVER_HOST:$API_PORT"
echo "- Web: $URL"
echo
echo "Press Ctrl+C to stop services."
echo

# Keep running until killed
wait
