#!/usr/bin/env python3

DEBUG = False

import sys
import socket
import os
import time
import subprocess
import signal
import iob_colors
#import ctypes

# Tell system to send a SIGTERM signal to this process if the parent process os killed
# This is needed to ensure this program is killed on remote machines when the parent `sshd` process also terminates.
# Define constants for prctl options and signals
#PR_SET_PDEATHSIG = 1
#SIGTERM = 15
## Load the libc library
#libc = ctypes.CDLL("libc.so.6")
## Call prctl with PR_SET_PDEATHSIG and SIGTERM
#libc.prctl(PR_SET_PDEATHSIG, SIGTERM)

# Define the client's IP, port and version
# Must match the server's
HOST = "localhost"  # Use the loopback interface
PORT = 50007  # Use the same port as the server
VERSION = "V0.1"

# user and duration board is needed
USER = os.environ["USER"]
DURATION = "15"  # Default duration is 5 seconds


def perror():
    print(f"Usage: client.py [grab [duration in seconds] -c [console launch command] [-p [fpga program command] | -s [simulator run command]] | release]")
    print("If -p is given then -c is required. If -s is given then -c is optional.")
    sys.exit(1)


# Check the command line arguments
if len(sys.argv) == 1:
    command = "query"
else:
    command = sys.argv[1]

if command == "grab":
    if len(sys.argv) == 3:
        try:
            DURATION = int(sys.argv[2])
        except ValueError:
            perror()
elif command != "release" and command != "query":
    perror()

# Console run command is only required with -p
console_command=None
if "-c" in sys.argv:
    console_command = sys.argv[sys.argv.index("-c")+1]

# FPGA program command is optional
fpga_prog_command=None
if "-p" in sys.argv:
    fpga_prog_command = sys.argv[sys.argv.index("-p")+1]

# Simulator run command is optional
simulator_run_command=None
if "-s" in sys.argv:
    simulator_run_command = sys.argv[sys.argv.index("-s")+1]

# Ensure either -p or -s is given with grab command
assert command != "grab" or bool(fpga_prog_command) != bool(simulator_run_command), "Either -p or -s must be present with 'grab' command. (Cannot be both)"

# Ensure -c is given with -p
assert not fpga_prog_command or console_command, "-c must be present with -p"

# Function to form the request
def form_request(command):
    request = ""
    if command == "grab":
        request += f"{command} {USER} {DURATION} {VERSION}"
    elif command == "release":
        request += f"{command} {USER} {VERSION}"
    elif command == "query":
        request += f"{command} {VERSION}"
    return request

request = form_request(command)
if DEBUG:
    print(f'{iob_colors.OKBLUE}DEBUG: Request is "{request}"{iob_colors.ENDC}')

# Function to send the request
def send_request(request):
    while True:
        # Create a socket
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(10)

        # Connect with the server
        try:
            s.connect((HOST, PORT))
        except:
            print(f"{iob_colors.FAIL}Could not connect to server{iob_colors.ENDC}")
            sys.exit(1)

        # Send the request to the server
        s.sendall(request.encode("utf-8"))

        # Receive the response from the server
        response = s.recv(1024).decode()
        s.close()
        print(response)

        # Process the response
        if "ERROR" in response:
            sys.exit(1)

        if "grab" in request and "Failure" in response:
            time_remaining = float(response.split(" ")[-2])
            print(f"{iob_colors.WARNING}Trying again in", time_remaining, f"seconds{iob_colors.ENDC}")
            time.sleep(time_remaining)
        else:
            break

# Function to release the board
def release_board(signal=None, frame=None):
    request = form_request("release")
    send_request(request)

# If we will grab the FPGA board (-p was given), then ensure we release it when terminating board_client
if command == "grab" and fpga_prog_command:
    signal.signal(signal.SIGINT, release_board)
    signal.signal(signal.SIGTERM, release_board)

# Connect to server if command is not "grab", or if the -p argument was given
if command != "grab" or fpga_prog_command:
    send_request(request)

# End program if command is not "grab"
if command != "grab": sys.exit(0)
# Lines below will only run if command=="grab" and request successful

# Launch simulator in parallel if -s was given
sim_proc=None
if simulator_run_command:
    print(f'{iob_colors.INFO}Running simulator{iob_colors.ENDC}')
    sim_proc = subprocess.Popen(simulator_run_command, stdout=sys.stdout, stderr=sys.stderr, shell=True)

    def kill_simulator(signal=None, frame=None):
        print(f'{iob_colors.INFO}Killing simulator{iob_colors.ENDC}')
        # Debug write to file
        #with open("simulator_kill.txt", "w") as f:
        #    f.write("killed")
        sim_proc.terminate()
    signal.signal(signal.SIGINT, kill_simulator)
    signal.signal(signal.SIGTERM, kill_simulator)

exit_code=0
try:
    start_time = time.time()
    # Program the FPGA if -p is given
    if fpga_prog_command:
        print(f'{iob_colors.INFO}Programming FPGA{iob_colors.ENDC}')
        subprocess.run(fpga_prog_command, stdout=sys.stdout, stderr=sys.stderr, shell=True, timeout=DURATION)
    remaining_duration = int(DURATION) - (time.time()-start_time)

    # Run the console
    if console_command:
        print(f'{iob_colors.INFO}Running console{iob_colors.ENDC}')
        subprocess.run(console_command, stdout=sys.stdout, stderr=sys.stderr, shell=True, timeout=remaining_duration)
    else:
        print(f'{iob_colors.INFO}Waiting for simulator to finish{iob_colors.ENDC}')
        sim_proc.wait(timeout=remaining_duration)

except subprocess.TimeoutExpired:
    print(f'{iob_colors.FAIL}Board grab duration expired!{iob_colors.ENDC}')
    exit_code=1
    # Kill the simulator if -s was given and console timed out
    if simulator_run_command: kill_simulator()

# Release the board if -p is given
if fpga_prog_command:
    release_board()

sys.exit(exit_code)

#TODO: Check if parent process is sshd. If parent process changes, terminate the program (it means sshd stopped).
