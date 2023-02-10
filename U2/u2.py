#U2
import socketserver
import threading
import os
import sys
import datetime
import time

hasToStop = [False]

class Handler_U2_IN(socketserver.BaseRequestHandler):
    def handle(self):
        self.data = self.request.recv(1024)
        if "[U3-END]" in self.data.strip().decode('UTF-8'):
            try :
                self.request.sendall("RAS".encode())
                hasToStop[0] = True
            except Exception as e:
                print(e)
            finally:
                return
        print("[U2-IN-RF]'{}' received from {}".format(self.data.decode('UTF-8'),self.client_address[0]))
        self.data = self.data.strip() +"(EVE IN)".encode('utf-8')
        print("[U2-IN-ST]'{}' send to {}".format(self.data.decode('UTF-8'),self.client_address[0]))
        self.request.sendall(self.data)

class Handler_U2_OUT(socketserver.BaseRequestHandler):
    def handle(self):
        self.data = self.request.recv(1024)
        print("[U2-OUT-RF]'{}' received from {}".format(self.data.decode('UTF-8'),self.client_address[0]))
        self.data = self.data.strip() + "(EVE OUT)".encode('utf-8')
        print("[U2-OUT-ST]'{}' send to {}".format(self.data.decode('UTF-8'),self.client_address[0]))
        # just send back ACK for data arrival confirmation
        self.request.sendall(self.data)


U2_ADDR = os.environ['U2_LIST_ADDR'] if os.environ.get('U2_LIST_ADDR') is not None else "127.0.0.1"
U2_IN_PORT = int(os.environ['U2_IN_PORT']) if os.environ.get('U2_IN_PORT') is not None else 22221
U2_OUT_PORT = int(os.environ['U2_OUT_PORT']) if os.environ.get('U2_OUT_PORT') is not None else 22223

if __name__ == "__main__":
    threads = []
    tcp_u2_in_server = socketserver.TCPServer((U2_ADDR,U2_IN_PORT), Handler_U2_IN)
    tcp_u2_out_server = socketserver.TCPServer((U2_ADDR,U2_OUT_PORT), Handler_U2_OUT)
    threads.append(threading.Thread(target=tcp_u2_in_server.serve_forever))
    threads.append(threading.Thread(target=tcp_u2_out_server.serve_forever))
    # Start all threads
    for x in threads:
         x.start()
    print("U2 UP !")
    while not hasToStop[0]:
        continue
    tcp_u2_in_server.shutdown()
    tcp_u2_out_server.shutdown()
    for x in threads:
        x.join()
    print("U2 END !")


