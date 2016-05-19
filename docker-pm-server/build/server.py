#!/usr/local/bin/python

import socket, sys, signal
from thread import *

def handler(signum = None, frame = None):
    global s
    global log
    log.write( 'Signal handler called with signal\n' );
    log.write( ">> PM server stopping\n");
    log.close()
    s.close()
    sys.exit(0)

def clientthread(conn):
    #Sending message to connected client
    fconf = open("/srv/conf/canUpgrade")
    conf=fconf.readline().rstrip()
    conn.send(conf + '\n')
    conn.close()
    fconf.close()

for sig in [signal.SIGTERM, signal.SIGINT, signal.SIGHUP, signal.SIGQUIT]:
    signal.signal(sig, handler)

HOST = ''
PORT = 23

log = open("/var/log/pm_server.log", "a")
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

log.write( ">> PM server starting\n");
log.write( 'Socket created\n' );

try:
    s.bind((HOST, PORT))
except socket.error as msg:
    log.write( 'Bind failed. Error Code : ' + str(msg[0]) + ' Message ' + msg[1] + '\n');
    sys.exit()

log.write( "Socket bind complete\n");

s.listen(10)

log.write( "Socket now listening\n");

log.write( ">> PM server started\n");

log.flush()

while True:
    #wait to accept a connection - blocking call
    conn, addr = s.accept()
    log.write ('Connected with ' + addr[0] + ':' + str(addr[1])+ '\n');
    log.flush()
     
    #start new thread takes 1st argument as a function name to be run, second is the tuple of arguments to the function.
    start_new_thread(clientthread ,(conn,))
 

log.write( ">> PM server stopping\n");
log.close()
s.close()
