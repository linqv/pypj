import json
from http.server import BaseHTTPRequestHandler, HTTPServer

from main import build_assistant, extract_code_block  # 不修改 main.py

assistant = build_assistant()


class Handler(BaseHTTPRequestHandler):
    def _set_headers(self, status=200, content_type="application/json"):
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        # ✅ CORS：让你直接打开静态 html 也能访问本地接口
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()

    def do_OPTIONS(self):
        self._set_headers(200)

    def do_GET(self):
        if self.path == "/health":
            self._set_headers(200)
            self.wfile.write(b'{"ok":true}')
        else:
            self._set_headers(404)
            self.wfile.write(b'{"ok":false,"error":"Not Found"}')

    def do_POST(self):
        if self.path != "/api/chat":
            self._set_headers(404)
            self.wfile.write(b'{"ok":false,"error":"Not Found"}')
            return

        length = int(self.headers.get("Content-Length", 0))
        raw = self.rfile.read(length).decode("utf-8")

        try:
            payload = json.loads(raw)
        except Exception:
            self._set_headers(400)
            self.wfile.write(b'{"ok":false,"error":"Invalid JSON"}')
            return

        question = (payload.get("question") or "").strip()
        session_id = (payload.get("session_id") or "default").strip()
        pure_mode = bool(payload.get("pure_mode", False))

        if not question:
            self._set_headers(400)
            self.wfile.write(b'{"ok":false,"error":"Missing question"}')
            return

        try:
            res = assistant.invoke(
                {"question": question},
                config={"configurable": {"session_id": session_id}},
            )
            text = res.content
            if pure_mode:
                text = extract_code_block(text)

            out = {"ok": True, "answer": text}
            self._set_headers(200)
            self.wfile.write(json.dumps(out, ensure_ascii=False).encode("utf-8"))
        except Exception as e:
            out = {"ok": False, "error": str(e)}
            self._set_headers(500)
            self.wfile.write(json.dumps(out, ensure_ascii=False).encode("utf-8"))


def main():
    host = "127.0.0.1"
    port = 8765
    print(f"✅ local_server running: http://{host}:{port}")
    print("✅ POST /api/chat  GET /health")
    HTTPServer((host, port), Handler).serve_forever()


if __name__ == "__main__":
    main()
