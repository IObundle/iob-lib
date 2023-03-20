#!/usr/bin/env python3

import time
import socket

# Define the server's IP and port
HOST = 'localhost'  # Listen on all available interfaces
PORT = 50007  # Use a non-privileged port

# Initialize the board status and user name
board_status = 'idle'
user_name = ''

# Start the server
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.bind((HOST, PORT))
    s.listen()
    print('Server is ready to receive requests...')
    while True:
        conn, addr = s.accept()
        with conn:
            print('Connected by', addr)
            timer = time.time()
            data = conn.recv(1024)
            if not data:
                break
            data = data.decode()
            if data == 'query':
                if board_status == 'idle':
                    response = 'idle'
                else:
                    response = f'{board_status} {user_name}'
                conn.sendall(response.encode())
            elif data.startswith('grab'):
                grabbed_user_name = data.split()[1]
                if board_status == 'idle':
                    board_status = 'grabbed'
                    user_name = grabbed_user_name
                    response = 'grabbed'
                    timer = time.time()
                else:
                    response = 'Board is busy; please wait.'
                conn.sendall(response.encode())
            elif data.startswith('release'):
                released_user_name = data.split()[1]
                if released_user_name == user_name:
                    board_status = 'idle'
                    user_name = ''
                    response = 'released'
                else:
                    response = 'Access denied'
                conn.sendall(response.encode())
            if time.time() - timer >= 300:
                board_status = 'idle'
                user_name = ''
                timer = time.time()
