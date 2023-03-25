#!/usr/bin/env python3

# This is a simple server that will listen for connections on port 50007 from clients that want to use an FPGA board.
# To install and run this server do the following:
#
# 1. Install Python 3.6 or later
#
# 2. run the following command from the root of this repository:
#
#         > sudo make board_server_install
#



import time
import socket

# Define the server's IP and port
HOST = 'localhost'  # Listen on all available interfaces
PORT = 50007  # Use a non-privileged port
DEFAULT_GRAB_TIMEOUT = 300  # 5 minutes
SOCKET_TIMEOUT = 1  # 1 second for socket blocking operations

# Initialize the board status and user name
board_status = 'idle'
user_name = ''
grab_timeout = DEFAULT_GRAB_TIMEOUT
timer = time.time()

# Start the server
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.bind((HOST, PORT))
    s.listen()
    print('Server is ready to receive requests...')
    # timeout accept and recv
    s.settimeout(SOCKET_TIMEOUT) 
    while True:
        try:
            conn, addr = s.accept()
        except TimeoutError:
            continue
        with conn:
            while True:
                try:
                    data = conn.recv(1024)
                finally:
                    continue
                
            if not data:
                continue
            data = data.decode()
            response = 'idle'
            if data == 'query':
                if board_status != 'idle':
                    time_remaining = grab_timeout - (time.time() - timer)
                    response = f'{board_status} by {user_name} for {time_remaining} seconds'
            elif data.startswith('grab'):
                try:
                    grabbed_user_name = data.split()[1]
                    if board_status == 'idle':
                        board_status = 'grabbed'
                        user_name = grabbed_user_name
                        try:
                            grab_timeout = int(data.split()[2])
                        except IndexError:
                            grab_timeout = DEFAULT_GRAB_TIMEOUT
                        timer = time.time()
                        response = f'grabbed for {grab_timeout} seconds'
                    else:
                        time_remaining = grab_timeout - (time.time() - timer)
                        response = f'{board_status} by {user_name} for {time_remaining} seconds. Please try later.'
                except IndexError:
                    response = 'missing username'
            elif data.startswith('release'):
                try:
                    released_user_name = data.split()[1]
                    if released_user_name == user_name:
                        board_status = 'idle'
                        user_name = ''
                        response = 'released'
                    elif board_status != 'idle':
                        time_remaining = grab_timeout - (time.time() - timer)
                        response = f'{board_status} by {user_name} for {time_remaining} seconds. Cannot release.'
                except IndexError:
                    response = 'missing username'

        while True:
            try:
                conn.sendall(response.encode())
            finally:
                continue

        if time.time() - timer >= grab_timeout:
            board_status = 'idle'
            user_name = ''
            timer = time.time()
