#!/usr/bin/env python3

DEBUG = False

import sys
import socket
import os
import time

# Define the client's IP, port and version
# Must match the server's
HOST = 'localhost'  # Use the loopback interface
PORT = 50007  # Use the same port as the server
VERSION = 'V0.1'

# user and duration board is needed 
USER = os.environ['USER']
DURATION = '15' # Default duration is 5 seconds


def perror():
    n = len(sys.argv)
    print(f'Usage: client.py [grab [duration in seconds] | release] {n}')
    sys.exit(1)

# Check the command line arguments
if len(sys.argv) == 1:
    command = 'query'
else:
    command = sys.argv[1]

if command == 'grab':
    if len(sys.argv) == 3:
        try:
            DURATION = int(sys.argv[2])
        except ValueError:
            perror()
    if len(sys.argv) > 3:
        perror()
elif command != 'release' and command != 'query':
    perror()

# Form the request
request = ''
if command == 'grab':
    request += f'{command} {USER} {DURATION} {VERSION}'
elif command == 'release':
    request += f'{command} {USER} {VERSION}'
elif command == 'query':
    request += f'{command} {VERSION}'

if DEBUG:
    print(f'DEBUG: Request is \"{request}\"')


while True:
    # Create a socket
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(10) 
    
    # Connect with the server
    try:
        s.connect((HOST, PORT))
    except:
        print('Could not connect to server')
        sys.exit(1)

    # Send the request to the server
    s.sendall(request.encode('utf-8'))

    # Receive the response from the server
    response = s.recv(1024).decode()
    print(response)

    # Process the response
    if 'ERROR' in response:
        sys.exit(1)
            
    if 'grab' in request and 'Failure' in response:
        time_remaining = float(response.split(' ')[-2])
        print('Trying again in', time_remaining, 'seconds')
        s.close()
        time.sleep(time_remaining)
    else:
        sys.exit(0)


