#SimpleFireWall 
#TCP-Server
import socketserver
import socket
import threading 
WAN_ADDR = "127.1.0.1" #/32
WAN_HTTP_PORT = 2433
WAN_SSH_PORT = 2434

U1_ADDR = "127.2.0.1" #/32
U1_HTTP_PORT = 20433
U1_SSH_PORT = 20022

U2_ADDR = "127.2.0.2"
U2_IN_PORT = 22221
U2_OUT_PORT = 22223

class Handler_Wan_HTTP(socketserver.BaseRequestHandler):
    def handle(self):
        self.data = self.request.recv(1024)
        # just send back ACK for data arrival confirmation
        tcp_client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        try:
            # Establish connection to TCP server and exchange data
            tcp_client.connect((U1_ADDR,U1_HTTP_PORT))
            print("{} sent:".format(self.client_address[0]))
            print(self.data)
            tcp_client.sendall(self.data)
            # Read data from the TCP server and close the connection
            received = tcp_client.recv(1024)
            print("Received : " + str(received))
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

    # Wait for all of them to finish
    for x in threads:
         x.join()
if __name__ == "__main__":
    main()
