#SimpleFireWall 
#TCP-Server
import socketserver
import socket
import threading
import os
import sys
import datetime
import time
class Tee(object):
    def __init__(self, name, mode):
        self.file = open(name, mode)
        self.stdout = sys.stdout
        sys.stdout = self
        self.start_time = time.perf_counter()
    def __del__(self):
        sys.stdout = self.stdout
        self.file.close()
    def write(self, data):
        self.file.write(data +"|-->" + str(time.perf_counter() - self.start_time) +"\n")
        self.stdout.write(data+"\n")
    def flush(self):
        self.file.flush()
timestamp = str(datetime.datetime.now().strftime("%Y%m%d_%H-%M-%S"))
tee = Tee("F1.log","w")

hasToStop = [False]


WAN_ADDR = os.environ['F1_ADDR'] if os.environ.get('F1_ADDR') is not None else "127.0.0.1"
WAN_HTTP_PORT = int(os.environ['F1_HTTP_PORT']) if os.environ.get('F1_HTTP_PORT') is not None else 2433
WAN_SSH_PORT = int(os.environ['F1_SSH_PORT']) if os.environ.get('F1_SSH_PORT') is not None else 2434

U1_ADDR = os.environ['U1_ADDR'] if os.environ.get('U1_ADDR') is not None else "127.0.0.1"
U1_HTTP_PORT = int(os.environ['U1_HTTP_PORT']) if os.environ.get('U1_HTTP_PORT') is not None else 20433
U1_SSH_PORT = int(os.environ['U2_SSH_PORT']) if os.environ.get('U2_SSH_PORT') is not None else 20022

U2_ADDR = os.environ['U2_ADDR'] if os.environ.get('U2_ADDR') is not None else "127.0.0.1"
U2_IN_PORT = int(os.environ['U2_IN_PORT']) if os.environ.get('U2_IN_PORT') is not None else 22221
U2_OUT_PORT = int(os.environ['U2_OUT_PORT']) if os.environ.get('U2_OUT_PORT') is not None else 22223

class Handler_Wan_HTTP(socketserver.BaseRequestHandler):
    def handle(self):
        tcp_client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.data = self.request.recv(1024)
        if "[U3-END]" in self.data.strip().decode('UTF-8'):
            try :
                tee.write("[F1-E] End Signal received")
                tcp_u1 = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                tcp_u2 = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
                tcp_u1.connect((U1_ADDR,U1_HTTP_PORT))
                tcp_u2.connect((U2_ADDR,U2_IN_PORT))
                # buff_u2 = ''+ self.data.strip()
                tcp_u1.sendall(self.data)
                tcp_u2.sendall(self.data)
                self.request.sendall("RAS".encode())
                hasToStop[0] = True
            except Exception as e:
                tee.write(e)
            finally:
                return
        try:
            # Establish connection to TCP server and exchange data
            tcp_client.connect((U1_ADDR,U1_HTTP_PORT))
            tee.write("[F2-HTTP-ST]'{}' sent to {}".format(self.data.decode('UTF-8'),self.client_address[0]))
            tcp_client.sendall(self.data)
            # Read data from the TCP server and close the connection
            received = tcp_client.recv(1024)
            tee.write("[F2-HTT-RF]'{}' send to {}".format(self.data.decode('UTF-8'),self.client_address[0]))
            self.request.sendall(received)
        except Exception as e:
            print(e)
            self.request.sendall("Error on redirection".encode())

class Handler_Wan_SSH(socketserver.BaseRequestHandler):
    def handle(self):
        self.data = self.request.recv(1024)
        print("{} sent:".format(self.client_address[0]))
        print(self.data)
        # just send back ACK for data arrival confirmation
        tcp_u2_in = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        tcp_u2_out = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        tcp_u1 = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        try:
            #-- Send To U2
            tcp_u2_in.connect((U2_ADDR,U2_IN_PORT))
            tcp_u2_in.sendall(self.data)
            #-- Send U2 Response to U1
            tcp_u1.connect((U1_ADDR,U1_SSH_PORT))
            received_u2_in = tcp_u2_in.recv(1024)
            tcp_u1.sendall(received_u2_in)
            #-- Send U1 Response to U2
            tcp_u2_out.connect((U2_ADDR,U2_OUT_PORT))
            received_u1 = tcp_u1.recv(1024)
            tcp_u2_out.sendall(received_u1)
            #-- Send to U2 Response to U3
            self.request.sendall(tcp_u2_out.recv(1024))
        except Exception as e:
            print(e)
            self.request.sendall("Error on redirection".encode())

def main ():
    threads = []

    wan_http_socket = socketserver.TCPServer((WAN_ADDR,WAN_HTTP_PORT),Handler_Wan_HTTP)
    wan_ssh_socket = socketserver.TCPServer((WAN_ADDR,WAN_SSH_PORT),Handler_Wan_SSH)

    threads.append(threading.Thread(target=wan_http_socket.serve_forever))
    threads.append(threading.Thread(target=wan_ssh_socket.serve_forever))
    # Start all threads
    for x in threads:
         x.start()

    tee.write("F1 UP !")
    # Wait for all of them to finish
    while not hasToStop[0]:
        continue
    wan_http_socket.shutdown()
    wan_ssh_socket.shutdown()
    for x in threads:
        x.join()
    tee.flush()
    tee.write("F1 END !")

if __name__ == "__main__":
    main()
