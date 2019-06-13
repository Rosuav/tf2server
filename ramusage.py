import os
import sys
import time
pid = 29182
print("%9s %8s %8s %8s %8s %8s" % ("time", "size", "rss", "shared", "text", "data"))
lastinfo = None
while True:
	try: exe = os.readlink("/proc/%s/exe" % pid)
	except PermissionError: exe = ""
	if exe != "/home/rosuav/tf2server/steamcmd_linux/tf2/srcds_linux":
		# TODO: Find the new PID by scanning for this executable
		print("Bad PID, halting")
		sys.exit()
	with open("/proc/%s/statm" % pid) as f:
		size, rss, shared, text, _, data, _ = f.read().strip().split()
	info = "%8s %8s %8s %8s %8s" % (size, rss, shared, text, data)
	if info != lastinfo:
		lastinfo = info
		print("%9s %s" % (time.strftime("%a %H:%M"), info))
	time.sleep(1800)
