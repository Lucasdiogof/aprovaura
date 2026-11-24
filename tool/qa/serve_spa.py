"""Servidor estático com fallback para index.html (F5 em rotas profundas), só para QA local."""
import http.server, os, sys
root, port = sys.argv[1], int(sys.argv[2])
os.chdir(root)
class H(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        p = self.translate_path(self.path.split('?')[0])
        if not os.path.exists(p) or os.path.isdir(p) and not os.path.exists(os.path.join(p, 'index.html')):
            self.path = '/index.html'
        return super().do_GET()
    def log_message(self, *a): pass
http.server.ThreadingHTTPServer(('127.0.0.1', port), H).serve_forever()
