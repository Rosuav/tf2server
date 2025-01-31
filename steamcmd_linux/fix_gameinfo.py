# Ensure that gameinfo.gi references the metamod directory
fn = "csgo/game/csgo/gameinfo.gi"
with open(fn, "rb") as f: data = f.read()
if b"csgo/addons/metamod" not in data:
	before, after = data.split(b"Game_LowViolence", 1)
	before += b"Game csgo/addons/metamod\r\n\t\t\t"
	data = before + b"Game_LowViolence" + after
	with open(fn, "wb") as f: f.write(data)
	print("\nUpdated gameinfo.gi")
