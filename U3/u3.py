#TCP-Server
import socket
import os
import subprocess, os, sys
import datetime
import time

class Tee(object):
    def __init__(self, name, mode):
        # self.file = open(name, mode)
        self.stdout = sys.stdout
        # sys.stdout = self
        self.start_time = time.perf_counter() 
    def __del__(self):
        sys.stdout = self.stdout
        # self.file.close()
    def write(self, data):
        # self.file.write(data +"|-->" + str(time.perf_counter() - self.start_time) +"\n")
        self.stdout.write(data +"|-->" + str(time.perf_counter() - self.start_time) +"\n")
    def flush(self):
        self.file.flush()


F1_ADDR = os.environ['F1_ADDR'] if os.environ.get('F1_ADDR') is not None else "127.0.0.1"
F1_HTTP_PORT =int( os.environ['F1_HTTP_PORT']) if os.environ.get('F1_HTTP_PORT') is not None else 2433
F1_SSH_PORT = int(os.environ['F1_SSH_PORT']) if os.environ.get('F1_SSH_PORT') is not None else 2434

U1_ADDR = os.environ['U1_ADDR'] if os.environ.get('U1_ADDR') is not None else "127.0.0.1"
U1_HTTP_PORT = int(os.environ['U1_HTTP_PORT']) if os.environ.get('U1_HTTP_PORT') is not None else 20433

def requestBypassFirewall(tee : Tee):
    tcp_client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        data = "[U3-RBFW] Message bypass to  HTTP PORT"
        tee.write(data)
        # Establish connection to TCP server and exchange data
        tcp_client.connect((U1_ADDR,U1_HTTP_PORT))
        tcp_client.sendall(data.encode())
        tee.write("[U3-RBFW] RequesBypassFireWall : Sent !")
        # Read data from the TCP server and close the connection
        received = tcp_client.recv(1024).strip()
        tee.write("[U3-RBFW] {} sent".format(received.decode('UTF-8')))
        tee.write("[U3-RBFW] RequestBypassFireWall : END !")
    except Exception as e :
        print(e)
    finally:
        tcp_client.close()

def requestSimple(tee:Tee):
    tcp_http_client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        data = "[U3-RS] First Message to HTTP PORT"
        tee.write(data)
        # Establish connection to TCP server and exchange data
        tcp_http_client.connect((F1_ADDR,F1_HTTP_PORT))
        tcp_http_client.sendall(data.encode())
        tee.write("[U3-RS] RequestSimple : Sent !")

        # Read data from the TCP server and close the connection
        received = tcp_http_client.recv(1024).strip()
        tee.write("[U3-RS] {} received:".format(received.decode('UTF-8')))
        tee.write("[U3-RS] Request Simple : END !")
    except Exception as e :
        print(e)
    finally:
        tcp_http_client.close()

def requestWithRedirection(tee:Tee):
    tcp_ssh_client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        data = "[U3-RWR] Second Message to SSH PORT"
        tee.write(data)
        # Establish connection to TCP server and exchange data
        tcp_ssh_client.connect((F1_ADDR,F1_SSH_PORT))
        tcp_ssh_client.sendall(data.encode())
        tee.write("[U3-RWR] RequestWithRedirection : Sent !")
        # Read data from the TCP server and close the connection
        received = tcp_ssh_client.recv(1024).strip()
        tee.write("[U3-RWR] {} received".format(received.decode('UTF-8')))
        tee.write("[U3-RWR] RequestWithRedirection : END !")
    except Exception as e :
        print(e)
    finally:
        tcp_ssh_client.close()

def requestEnd(tee:Tee):
    tcp_ssh_client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        data = "[U3-END] END TEST"
        tee.write(data)
        # Establish connection to TCP server and exchange data
        tcp_ssh_client.connect((F1_ADDR,F1_HTTP_PORT))
        tcp_ssh_client.sendall(data.encode())
        tee.write("[U3-END] END TEST : Sent !")
        # Read data from the TCP server and close the connection
        received = tcp_ssh_client.recv(1024).strip()
        tee.write("[U3-END] {} received".format(received.decode('UTF-8')))
        tee.write("[U3-END] END TEST : END !")
    except Exception as e :
        print(e)
    finally:
        tcp_ssh_client.close()
if __name__ == "__main__":
    timestamp = str(datetime.datetime.now().strftime("%Y%m%d_%H-%M-%S"))
    tee = Tee("U3.log","w")
    tee.write("U3 UP!")
    # requestBypassFirewall(tee)
    requestSimple(tee)
    requestWithRedirection(tee)
    requestEnd(tee)
    # tee.flush()
    tee.write("U3 END !")
