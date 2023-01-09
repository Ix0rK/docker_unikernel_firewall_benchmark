#U2
##Subnet 127.0.1.0/32
import socketserver
import threading
class Handler_U2_IN(socketserver.BaseRequestHandler):
    """
    The TCP Server class for demonstration.

    Note: We need to implement the Handle method to exchange data
    with TCP client.

    """

    def handle(self):
        print("Receive Request On IN handler")
        # self.request - TCP socket connected to the client
        self.data = self.request.recv(1024)
        print("{} sent:".format(self.client_address[0]))
        self.data = self.data.strip() +"(EVE IN)".encode('utf-8')
        print(self.data)
        # just send back ACK for data arrival confirmation
        self.request.sendall(self.data)

class Handler_U2_OUT(socketserver.BaseRequestHandler):
    """
    The TCP Server class for demonstration.

    Note: We need to implement the Handle method to exchange data
    with TCP client.

    """

    def handle(self):
        print("Receive Request On OUT handler")
        # self.request - TCP socket connected to the client
        self.data = self.request.recv(1024)
        print("{} sent:".format(self.client_address[0]))
        self.data = self.data.strip() + "(EVE OUT)".encode('utf-8')
        print(self.data)
        # just send back ACK for data arrival confirmation
        self.request.sendall(self.data)

U2_ADDR = "127.2.0.2"
U2_IN_PORT = 22221
U2_OUT_PORT = 22223

if __name__ == "__main__":
    threads = []
    tcp_u2_in_server = socketserver.TCPServer((U2_ADDR,U2_IN_PORT), Handler_U2_IN)
    tcp_u2_out_server = socketserver.TCPServer((U2_ADDR,U2_OUT_PORT), Handler_U2_OUT)
    threads.append(threading.Thread(target=tcp_u2_in_server.serve_forever))
    threads.append(threading.Thread(target=tcp_u2_out_server.serve_forever))
    # Start all threads
    for x in threads:
         x.start()

    # Wait for all of them to finish
    for x in threads:
         x.join()


