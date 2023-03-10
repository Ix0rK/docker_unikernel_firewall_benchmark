#U1 
import socketserver
import threading
import os
import sys
import datetime
import time

hasToStop = [False]

class Handler_TCPServer(socketserver.BaseRequestHandler):
    def handle(self):
        self.data = self.request.recv(1024).strip()
        if "[U3-END]" in self.data.strip().decode('UTF-8'):
            try :
                print("[U1-E] End Signal Received")
                self.request.sendall("RAS".encode())
                hasToStop[0] = True
            except Exception as e:
                print(e)
            finally:
                return
        print("[U1-H]'{}' received from {}".format(self.data.decode('UTF-8'),self.client_address[0]))
        self.request.sendall("ACK from TCP Server".encode())


U1_ADDR = os.environ['U1_LIST_ADDR'] if os.environ.get('U1_LIST_ADDR') is not None else "127.0.0.1"
U1_HTTP_PORT = int(os.environ['U1_HTTP_PORT']) if os.environ.get('U1_HTTP_PORT') is not None else 20433
U1_SSH_PORT = int(os.environ['U2_SSH_PORT']) if os.environ.get('U2_SSH_PORT') is not None else 20022

if __name__ == "__main__":
    threads = []
    # Init the TCP server object, bind it to the localhost on 9999 port
    tcp_http_server = socketserver.TCPServer((U1_ADDR,U1_HTTP_PORT), Handler_TCPServer)
    tcp_ssh_server = socketserver.TCPServer((U1_ADDR,U1_SSH_PORT), Handler_TCPServer)

    # Activate the TCP server.
    threads.append(threading.Thread(target=tcp_http_server.serve_forever))
    threads.append(threading.Thread(target=tcp_ssh_server.serve_forever))
    # Start all threads
    for x in threads:
         x.start()
    print("U1 UP") 
    while not hasToStop[0]:
        continue
    tcp_http_server.shutdown()
    tcp_ssh_server.shutdown()
    for x in threads:
        x.join()
    print("U1 END")
