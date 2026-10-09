# Regenerates Installer.lua (one-paste Studio command bar installer) from src/.
import os

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "src")
TARGETS = [
    ("shared", 'game:GetService("ReplicatedStorage")', "Shared"),
    ("server", 'game:GetService("ServerScriptService")', "Server"),
    ("client", 'game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")', "Client"),
]

out = [
    "-- Sky Coin Obby installer: paste into the Studio command bar and press Run.",
    "-- Creates every folder and script. Safe to run again (it replaces the old copies).",
    "local function folder(parent, name)",
    "\tlocal old = parent:FindFirstChild(name)",
    "\tif old then old:Destroy() end",
    '\tlocal f = Instance.new("Folder")',
    "\tf.Name = name",
    "\tf.Parent = parent",
    "\treturn f",
    "end",
    "local function add(parent, className, name, source)",
    "\tlocal s = Instance.new(className)",
    "\ts.Name = name",
    "\ts.Source = source",
    "\ts.Parent = parent",
    "end",
    'local spawn = workspace:FindFirstChild("SpawnLocation")',
    "if spawn then spawn:Destroy() end",
]
for sub, service, name in TARGETS:
    var = "f_" + sub
    out.append(f'local {var} = folder({service}, "{name}")')
    for fn in sorted(os.listdir(os.path.join(ROOT, sub))):
        src = open(os.path.join(ROOT, sub, fn)).read()
        assert "]==]" not in src, fn
        if fn.endswith(".server.luau"):
            cls, n = "Script", fn[: -len(".server.luau")]
        elif fn.endswith(".client.luau"):
            cls, n = "LocalScript", fn[: -len(".client.luau")]
        else:
            cls, n = "ModuleScript", fn[: -len(".luau")]
        out.append(f'add({var}, "{cls}", "{n}", [==[\n{src}]==])')
out.append('print("Sky Coin Obby installed! Press Play to test.")')

with open(os.path.join(os.path.dirname(ROOT), "Installer.lua"), "w") as f:
    f.write("\n".join(out) + "\n")
