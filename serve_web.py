#!/usr/bin/env python3
import http.server
import socketserver
import webbrowser
import os
import sys

# Change to the web build directory
web_dir = os.path.join(os.path.dirname(__file__), 'build', 'web')

if not os.path.exists(web_dir):
    print("❌ Web build not found!")
    print("Please run: flutter build web")
    input("Press Enter to exit...")
    sys.exit(1)

os.chdir(web_dir)

PORT = 8080

class MyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Cross-Origin-Embedder-Policy', 'require-corp')
        self.send_header('Cross-Origin-Opener-Policy', 'same-origin')
        super().end_headers()

print("🚀 Starting Aab-e-Pak Web Server...")
print(f"📱 Your app will be available at: http://localhost:{PORT}")
print("🌐 Opening browser automatically...")
print("⏹️  Press Ctrl+C to stop the server")
print()

try:
    with socketserver.TCPServer(("", PORT), MyHTTPRequestHandler) as httpd:
        print(f"✅ Server running on port {PORT}")
        
        # Open browser automatically
        webbrowser.open(f'http://localhost:{PORT}')
        
        httpd.serve_forever()
        
except KeyboardInterrupt:
    print("\n🛑 Server stopped by user")
except OSError as e:
    if e.errno == 10048:  # Port already in use
        print(f"❌ Port {PORT} is already in use!")
        print("Try closing other applications or use a different port")
    else:
        print(f"❌ Error starting server: {e}")
    
    input("Press Enter to exit...")
