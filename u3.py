#TCP-Server
import socket

WAN_ADDR = "127.1.0.1" #/32
WAN_HTTP_PORT = 2433
WAN_SSH_PORT = 2434

def requestSimple():
    tcp_http_client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        data = "First Message to HTTP PORT"
        print(data)
        # Establish connection to TCP server and exchange data
        tcp_http_client.connect((WAN_ADDR,WAN_HTTP_PORT))
        tcp_http_client.sendall(data.encode())

        # Read data from the TCP server and close the connection
        received = tcp_http_client.recv(1024)
        print("{} sent:".format(received))
    except Exception as e :
        print(e)
    finally:
        tcp_http_client.close()

def requestWithRedirection():
    tcp_ssh_client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        data = "Second Message to SSH PORT"
        print(data)
        # Establish connection to TCP server and exchange data
        tcp_ssh_client.connect((WAN_ADDR,WAN_SSH_PORT))
        tcp_ssh_client.sendall(data.encode())
        print("Message sent")
        # Read data from the TCP server and close the connection
        received = tcp_ssh_client.recv(1024)
        print("{} sent:".format(received))
    except Exception as e :
        print(e)
    finally:
        tcp_ssh_client.close()

if __name__ == "__main__":
    requestSimple()
    requestWithRedirection()

