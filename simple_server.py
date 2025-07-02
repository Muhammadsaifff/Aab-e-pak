#!/usr/bin/env python3
"""
Simple HTTP Server for Aab-e-Pak Flutter Web App
This fixes the white screen issue by serving the app properly
"""

import http.server
import socketserver
import webbrowser
import os
import sys
import threading
import time

def main():
    # Configuration
    PORT = 8080
    
    # Get the directory where this script is located
    script_dir = os.path.dirname(os.path.abspath(__file__))
    web_dir = os.path.join(script_dir, 'build', 'web')
    
    print("🚀 Aab-e-Pak Web Server Starting...")
    print("=" * 50)
    
    # Check if web build exists
    if not os.path.exists(web_dir):
        print("❌ Error: Web build not found!")
        print(f"Expected location: {web_dir}")
        print("\nPlease run: flutter build web")
        input("\nPress Enter to exit...")
        return
    
    # Change to web directory
    os.chdir(web_dir)
    
    # Custom HTTP handler with proper headers
    class CustomHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
        def end_headers(self):
            # Add headers to fix CORS and other issues
            self.send_header('Cross-Origin-Embedder-Policy', 'require-corp')
            self.send_header('Cross-Origin-Opener-Policy', 'same-origin')
            self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
            self.send_header('Pragma', 'no-cache')
            self.send_header('Expires', '0')
            super().end_headers()
        
        def log_message(self, format, *args):
            # Suppress log messages for cleaner output
            pass
    
    try:
        # Create server
        with socketserver.TCPServer(("", PORT), CustomHTTPRequestHandler) as httpd:
            server_url = f"http://localhost:{PORT}"
            
            print(f"✅ Server started successfully!")
            print(f"📱 Your Aab-e-Pak app is running at: {server_url}")
            print(f"📁 Serving from: {web_dir}")
            print("\n🌐 Opening browser automatically...")
            print("⏹️  Press Ctrl+C to stop the server")
            print("=" * 50)
            
            # Open browser after a short delay
            def open_browser():
                time.sleep(2)
                try:
                    webbrowser.open(server_url)
                    print("✅ Browser opened successfully!")
                except Exception as e:
                    print(f"⚠️  Could not open browser automatically: {e}")
                    print(f"Please open your browser and go to: {server_url}")
            
            # Start browser opening in a separate thread
            browser_thread = threading.Thread(target=open_browser)
            browser_thread.daemon = True
            browser_thread.start()
            
            # Start serving
            httpd.serve_forever()
            
    except KeyboardInterrupt:
        print("\n\n🛑 Server stopped by user")
        print("Thank you for using Aab-e-Pak!")
        
    except OSError as e:
        if e.errno == 10048:  # Port already in use (Windows)
            print(f"❌ Error: Port {PORT} is already in use!")
            print("Please close other applications using this port or try a different port.")
        elif e.errno == 48:  # Port already in use (Unix)
            print(f"❌ Error: Port {PORT} is already in use!")
            print("Please close other applications using this port or try a different port.")
        else:
            print(f"❌ Error starting server: {e}")
        
        input("\nPress Enter to exit...")
        
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        input("\nPress Enter to exit...")

if __name__ == "__main__":
    main()
