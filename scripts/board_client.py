#!/usr/bin/env python3

import sys
import socket
import os

# Define the server's IP and port
HOST = 'localhost'  # Use the loopback interface
PORT = 50007  # Use the same port as the server
DEFAULT_DURATION = 300  # 5 minutes
USER = os.environ['USER']

SOCKET_TIMEOUT = 10  # 1 second for socket blocking operations
VERSION = '0.1'


def perror():
    print('Usage: client.py [grab [duration in seconds] | release]')
    sys.exit(1)


# Check the command line arguments
if len(sys.argv) == 1:
    request = 'query'
else:
    request = sys.argv[1]
    if sys.argv[1] == 'grab':
        if len(sys.argv) == 3:
            duration = sys.argv[2]
        else
            duration = DEFAULT_DURATION
    elif sys.argv[1] == 'release':
        request = 'query'
    else:
        perror()

# Form the request
if request == 'grab':
    request += f'{request} {USER} {duration} {VERSION}'
elif request == 'release':
    request += f'{request} {USER} {VERSION}'
elif request == 'query':
    request += f'{request} {VERSION}'


# Create a socket
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.settimeout(SOCKET_TIMEOUT) 

# Send the request to the server
try:
    s.connect((HOST, PORT))
except:
    print('Could not connect to server')
    sys.exit()

try:
    s.sendall(request.encode())
except:
    print('Could not send request to server')
    sys.exit()

# Receive the response from the server
try:
    data = s.recv(1024)
except:
    print('Could not receive response from server')
    sys.exit()
    
print("Board "+data.decode())
