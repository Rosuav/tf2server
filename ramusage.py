import os.path
import sys
import time
pid = 0
binary = os.path.abspath(__file__ + "/../steamcmd_linux/tf2/srcds_linux")
print("%9s %8s %8s %8s %8s %8s" % ("time", "size", "rss", "shared", "text", "data"))
lastinfo, count = None, 0

def exe(pid):
	try: return os.readlink("/proc/%s/exe" % pid)
	except (PermissionError, FileNotFoundError, NotADirectoryError): return ""

while True:
	if not pid or exe(pid) != binary:
		# PID has changed. Find the new PID by scanning for this executable.
		for pid in os.listdir("/proc"):
			if exe(pid) == binary: break
		else:
			print("Cannot find server, waiting...")
			pid = 0
			time.sleep(60)
			continue
	with open("/proc/%s/statm" % pid) as f:
		size, rss, shared, text, _, data, _ = f.read().strip().split()
	info = "%8s %8s %8s %8s %8s" % (size, rss, shared, text, data)
	if info != lastinfo:
		if count > 10: print("(+%d)" % count)
		lastinfo, count = info, 0
		print("%9s %s" % (time.strftime("%a %H:%M"), info))
	else:
		count += 1
	time.sleep(1800)
