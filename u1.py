#U1 
import socketserver
import threading
class Handler_TCPServer(socketserver.BaseRequestHandler):
    """
    The TCP Server class for demonstration.

    Note: We need to implement the Handle method to exchange data
    with TCP client.

    """

    def handle(self):
        # self.request - TCP socket connected to the client
        self.data = self.request.recv(1024).strip()
        print("{} sent:".format(self.client_address[0]))
        print(self.data)
        # just send back ACK for data arrival confirmation
        self.request.sendall("ACK from TCP Server".encode())

if __name__ == "__main__":
    threads = []
    
    U1_ADDR = "127.2.0.1" #/32
    U1_HTTP_PORT = 20433
    U1_SSH_PORT = 20022
    # Init the TCP server object, bind it to the localhost on 9999 port
    tcp_http_server = socketserver.TCPServer((U1_ADDR,U1_HTTP_PORT), Handler_TCPServer)
    tcp_ssh_server = socketserver.TCPServer((U1_ADDR,U1_SSH_PORT), Handler_TCPServer)

    # Activate the TCP server.
    # To abort the TCP server, press Ctrl-C.
    threads.append(threading.Thread(target=tcp_http_server.serve_forever))
    threads.append(threading.Thread(target=tcp_ssh_server.serve_forever))
    # Start all threads
    for x in threads:
         x.start()

    # Wait for all of them to finish
    for x in threads:
         x.join()
