#!/usr/bin/env python3

import sys
import socket
import os

# Define the server's IP and port
HOST = 'localhost'  # Use the loopback interface
PORT = 50007  # Use the same port as the server

# Send the request to the server
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.connect((HOST, PORT))
    if len(sys.argv) < 2:
        print('Usage: client.py <query|grab|release>')
        sys.exit()
    request = sys.argv[1]
    user = os.environ['USER']
    if request == 'grab' and len(sys.argv) >= 3:
        request += ' ' + user
    elif request == 'release' and len(sys.argv) >= 3:
        request += ' ' + user
    s.sendall(request.encode())
    data = s.recv(1024)
    print("Board "+data.decode())
