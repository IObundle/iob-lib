#!/usr/bin/python

# The UNIX OS Terminal has to modes of receiving user input. The first being the Canonical mode witch is the one we are normarly acostumed to.
import sys
import termios

stdin = sys.stdin
fd = stdin.fileno()

old = termios.tcgetattr(fd)
new = termios.tcgetattr(fd)
new[3] &= ~termios.ECHO
new[3] &= ~termios.ICANON

termios.tcsetattr(fd, termios.TCSAFLUSH, new)
#print('Enter a letter: ')
#char = stdin.read(1)
print()
#termios.tcsetattr(fd, termios.TCSAFLUSH, old)
#print('You entered: '+char)
