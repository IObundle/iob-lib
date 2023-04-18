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
VERSION = "V0.2"

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
    if len(sys.argv) > 2:
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

def exit_program(exit_code):
    # Release the board if -p is given
    if fpga_prog_command:
        release_board()

    sys.exit(exit_code)


# List of processes to kill when terminating board_client
proc_list = []
# Function to kill all processes from proc_list and exit with error.
def kill_processes(sig=None, frame=None):
    for proc in proc_list:
        # Gracefully terminate process group (the process and its children)
        os.killpg(os.getpgid(proc.pid), signal.SIGTERM)
        try:
            # Wait for process to terminate gracefully
            proc.wait(2)
        except subprocess.TimeoutExpired:
            # Process did not terminate gracefully, kill it
            os.killpg(os.getpgid(proc.pid), signal.SIGKILL)
    exit_program(1)

signal.signal(signal.SIGINT, kill_processes)
signal.signal(signal.SIGTERM, kill_processes)

# Launch simulator in parallel if -s was given
sim_proc=None
if simulator_run_command:
    print(f'{iob_colors.INFO}Running simulator{iob_colors.ENDC}')
    sim_proc = subprocess.Popen(simulator_run_command, stdout=sys.stdout, stderr=sys.stderr, shell=True, start_new_session=True)
    # Add the simulator process to the list of processes to kill
    proc_list.append(sim_proc)

# Function to wait for a process to finish
# If the process times out, kill all other processes
def proc_wait(proc, timeout):
    try:
        proc.wait(timeout=timeout)
    except subprocess.TimeoutExpired:
        print(f'{iob_colors.FAIL}Board grab duration expired!{iob_colors.ENDC}')
        kill_processes()

# Start counting time since start of FPGA programming
start_time = time.time()

# Program the FPGA if -p is given
if fpga_prog_command:
    print(f'{iob_colors.INFO}Programming FPGA{iob_colors.ENDC}')
    fpga_prog_proc = subprocess.Popen(fpga_prog_command, stdout=sys.stdout, stderr=sys.stderr, shell=True, start_new_session=True)
    proc_list.append(fpga_prog_proc)
    proc_wait(fpga_prog_proc, DURATION)

# Update time passed
remaining_duration = int(DURATION) - (time.time()-start_time)

# Choose whether to run console or just wait for simulator to finish
if console_command:
    # Run console and wait for completion/timeout.
    print(f'{iob_colors.INFO}Running console{iob_colors.ENDC}')
    console_proc = subprocess.Popen(console_command, stdout=sys.stdout, stderr=sys.stderr, shell=True, start_new_session=True)
    proc_list.append(console_proc)
    proc_wait(console_proc, remaining_duration)

    # Update time passed
    remaining_duration = int(DURATION) - (time.time()-remaining_duration)

print(f'{iob_colors.INFO}Waiting for simulator to finish{iob_colors.ENDC}')
proc_wait(sim_proc, remaining_duration)

exit_program(0)
