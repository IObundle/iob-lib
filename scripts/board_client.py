#!/usr/bin/env python3

import sys
import socket
import os

def perror():
    print('Usage: client.py [grab|release] [timeout (seconds)]')
    sys.exit(1)

# Define the server's IP and port
HOST = 'localhost'  # Use the loopback interface
PORT = 50007  # Use the same port as the server

timeout = ''

# Check the command line arguments before making connection
if len(sys.argv) > 1:
    request = sys.argv[1]
    if sys.argv[1] == 'grab':
        if len(sys.argv) == 3:
            timeout = sys.argv[2]
        elif len(sys.argv) != 2:
            perror()
    elif sys.argv[1] != 'release':
        perror()
else:
    request = 'query'

user = os.environ['USER']

# Send the request to the server
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    try:
        s.connect((HOST, PORT))
    except:
        print('Could not connect to server')
        sys.exit()

    if request == 'grab':
        request += f'{request} {user} {timeout}'
    elif request == 'release':
        request += f'{request} {user}'
    s.sendall(request.encode())
    data = s.recv(1024)
    print("Board "+data.decode())
