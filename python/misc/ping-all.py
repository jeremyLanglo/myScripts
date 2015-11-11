#!/usr/bin/python

import sys
import threading
import os
from time import sleep
lock = threading.Lock();

class Thread1( threading.Thread):
	def __init__(self,addr): 
		super(Thread1, self).__init__()
		self.addr=addr
		self.cmd="ping -c 2 -w 2 "+addr+" 1>/dev/null 2>/dev/null"

	def run(self):
		if os.system(self.cmd)==0:
			with lock:
				print self.addr


if len(sys.argv)!=2:
	print "One parameter please, as 192.168.1."
else:
	for i in range(1,254):
		addr=sys.argv[1]+str(i)
		th=Thread1(addr)
		th.start()
