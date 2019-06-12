import os
import sys
import time
pid = 29182
print("%5s %8s %8s %8s %8s %8s" % ("time", "size", "rss", "shared", "text", "data"))
while True:
	try: exe = os.readlink("/proc/%s/exe" % pid)
	except PermissionError: exe = ""
	if exe != "/home/rosuav/tf2server/steamcmd_linux/tf2/srcds_linux":
		# TODO: Find the new PID by scanning for this executable
		print("Bad PID, halting")
		sys.exit()
	with open("/proc/%s/statm" % pid) as f:
		size, rss, shared, text, _, data, _ = f.read().strip().split()
	print("%5s %8s %8s %8s %8s %8s" % (time.strftime("%H:%M"), size, rss, shared, text, data))
	time.sleep(1800)
