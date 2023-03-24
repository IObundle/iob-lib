#!/usr/bin/env python3

import sys
import socket
import os

# Define the server's IP and port
HOST = 'localhost'  # Use the loopback interface
PORT = 50007  # Use the same port as the server

# Check the command line arguments before making connection
if len(sys.argv) < 2:
    print('Usage: client.py <query|grab|release> [timeout (seconds)]')
    sys.exit()

request = sys.argv[1]
user = os.environ['USER']
timeout = ''
try:
    timeout = sys.argv[2] # only used for grab
except IndexError:
    timeout = ''

# Send the request to the server
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.connect((HOST, PORT))
    if request == 'grab':
        request += f'{request} {user} {timeout}'
    elif request == 'release':
        request += f'{request} {user}'
    s.sendall(request.encode())
    data = s.recv(1024)
    print("Board "+data.decode())
