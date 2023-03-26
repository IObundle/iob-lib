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
SOCKET_TIMEOUT = 1  # 1 second for socket blocking operations

def get_remaining_time():
    return duration - (time.time() - start_time)

def form_response(request)
    if data.startswith('grab'):
        grabbed_user_name = data.split()[1]
        if board_status == 'idle':
            board_status = 'grabbed'
            user_name = grabbed_user_name
            grab_timeout = int(data.split()[2])
                except IndexError:
                    grab_timeout = DEFAULT_GRAB_TIMEOUT
                    current_time = time.time()
                    response = f'grabbed for {grab_timeout} seconds'
                else:
                    time_remaining = grab_timeout - (time.time() - current_time)
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
                        time_remaining = grab_timeout - (time.time() - current_time)
                        response = f'{board_status} by {user_name} for {time_remaining} seconds. Cannot release.'
        except IndexError:
            response = 'missing username'
        

        
    return response


# Init
board_status = 'idle'
current_time = time.time()

# Start the server

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind((HOST, PORT))
s.listen()
s.settimeout(SOCKET_TIMEOUT) 

# Loop forever

while True:
    conn, addr = s.accept()
    request = conn.recv(1024).decode()

    if board_status == 'idle':
        response = f'{board_status}'
    else:
        time_remaining = grab_timeout - (time.time() - current_time)        
        response = f'{board_status} by {user_name} for {time_remaining} seconds'

    
            while True:
                try:
                    conn.sendall(response.encode())
                finally:
                continue
            
            if time.time() - current_time >= grab_timeout:
            board_status = 'idle'
            user_name = ''
            current_time = time.time()
