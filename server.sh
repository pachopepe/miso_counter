#!/usr/bin/env python

import os
import sys
import json
import datetime
from http.server import HTTPServer, SimpleHTTPRequestHandler
import subprocess

class CORSHTTPRequestHandler(SimpleHTTPRequestHandler):
    def send_head(self):
        """Common code for GET and HEAD commands.
        This sends the response code and MIME headers.
        Return value is either a file object (which has to be copied
        to the outputfile by the caller unless the command was HEAD,
        and must be closed by the caller under all circumstances), or
        None, in which case the caller has nothing further to do.
        """
        path = self.translate_path(self.path)
        f = None
        if os.path.isdir(path):
            if not self.path.endswith('/'):
                # redirect browser - doing basically what apache does
                self.send_response(301)
                self.send_header("Location", self.path + "/")
                self.end_headers()
                return None
            for index in "index.html", "index.htm":
                index = os.path.join(path, index)
                if os.path.exists(index):
                    path = index
                    break
            else:
                dir = sorted(os.listdir(path))
                print("Directory path")
                strdir = str.encode(json.dumps(dir))
                self.send_response(200)
                self.send_header("Content-type", "application/json")
		# self.send_header("Content-Length", str(len(dir)))
		# self.send_header("Last-Modified", self.date_time_string(datetime.datetime.now()))
                self.send_header("Access-Control-Allow-Origin", "*")
                self.end_headers()
                self.wfile.write(strdir)
               	# self.wfile.flush()
               	# self.wfile.close()
                return None
        ctype = self.guess_type(path)
        try:
            # Always read in binary mode. Opening files in text mode may cause
            # newline translations, making the actual size of the content
            # transmitted *less* than the content-length!
            f = open(path, 'rb')
        except IOError:
            self.send_error(404, "File not found")
            return None
        self.send_response(200)
        if '.json' in self.path:
            self.send_header("Content-type", "application/json")
        else:
            self.send_header("Content-type", ctype)
        fs = os.fstat(f.fileno())
        self.send_header("Content-Length", str(fs[6]))
        self.send_header("Last-Modified", self.date_time_string(fs.st_mtime))
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        return f


if __name__ == "__main__":
    import socketserver

    #retcode = call(["stack","path","--local-bin"], shell=True)
    output = subprocess.getoutput("stack path --local-install-root")

    path = output + "/bin/counter.jsexe"
    print(output)
    

    PORT = 8000

    os.chdir( path )
    Handler = CORSHTTPRequestHandler

    httpd = socketserver.TCPServer(("", PORT), Handler)

    print( "serving at port", PORT )
    httpd.serve_forever()

