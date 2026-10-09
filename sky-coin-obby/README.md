# Sky Coin Obby

A 30-stage Roblox obby built to keep players coming back and bringing friends.

**Gameplay**
- **3 worlds** with their own music, sky colours and obstacles:
  - **Sky Islands** (stages 1–10): shrinking platforms, kill strips, spinners, narrow beams.
  - **Candy Land** (stages 11–20): vanishing platforms, a backwards conveyor, jump pads, sliding blocks.
  - **Outer Space** (stages 21–30): **low gravity moon jumps**, asteroid hops, double spinners, a jump pad launch across a huge gap.
- **Checkpoints** that save, and you respawn on your last one.
- **Coins** with a rising-pitch combo sound, a "+N" pop-up, and coins that come back after 45 seconds.

**Progress and rewards**
- **Wins loop:** finish the course for +1 win and 100 coins, then restart for another run. Each win permanently adds +25% coins, up to ×5.
- **Speedrun timer** on screen, with your personal best.
- **Global leaderboards** beside the start: *Most Wins* and *Fastest Run*, across all servers.
- **Cosmetic shop:** 8 trails and auras, plus a VIP-only Diamond Trail.

**Coming back and bringing friends**
- **Daily login rewards:** a 7-day streak, from 25 up to 250 coins.
- **Friend invites:** when a friend joins through your invite, you **both get +50 coins**.

**Robux**
- **2x Coins** game pass and **VIP** game pass (1.5× coins, VIP trail, `[VIP]` chat tag).
- **Skip Stage** developer product.

**Extras**
- **Badges:** Welcome, Reached Candy Land, Reached Space, First Win, 10 Wins.
- **Original music and sound effects:** 3 chiptune tracks and 8 effects, all generated from scratch, so they're copyright-free.
- **Artwork** from Higgsfield for every icon, game pass and thumbnail (see [`art/`](art/README.md)).

How to get players is covered in **[LAUNCH_PLAYBOOK.md](LAUNCH_PLAYBOOK.md)**.

---

## Part A: Install or update the game (one paste)

1. Open your place in Roblox Studio.
2. Open the installer and copy all of it with **Cmd+A**, then **Cmd+C**:
   https://raw.githubusercontent.com/26projectai/26project/claude/epic-ride-aazicr/sky-coin-obby/Installer.lua
3. In Studio, click the **command bar** at the bottom. If it's hidden, use **Script tab → Command**.
   Press **Cmd+A**, then **Delete**, then **Cmd+V**, and click **▶ Run**.
4. **Output** should say *installed!* or *updated!*. Press **▶ Play**.

The installer **keeps your `Assets` script** (the one with your Roblox IDs), so you can safely re-run it for future updates.

> Paste it into the **command bar**, never into a Script. A Script can't create other scripts.

## Part B: Add the music and sound effects

1. Download the 11 `.mp3` files from the [`audio/`](audio) folder. Click a file, then the download button.
2. In Studio, open **Window → Asset Manager**, then **Audio → Bulk Import**, and select all 11 files.
3. Right-click each one, choose **Copy Asset ID**, and paste it into **ReplicatedStorage → Shared → Assets**.
   The file names are written next to each line, for example:
   ```lua
   Coin = "rbxassetid://1234567890", -- audio/sfx_coin.mp3
   ```
4. Press Play. The music changes when you reach Candy Land and Space, and there's a **MUSIC** button to mute it.

## Part C: Add the artwork

1. Download the images from [`art/README.md`](art/README.md).
2. **Game icon and thumbnail:** go to **File → Experience Settings → Basic Info**, upload `game-icon.png` and `thumbnail.png`, and click **Save**.
3. **Asset Manager → Images → Bulk Import**: select the `ui-*.png` and `item-*.png` files.
4. Copy each ID into `Assets`, under `Images` and `ItemIcons`. Each line says which file it's for.

## Part D: Robux items and badges (optional, but this is how the game earns)

Go to the [Creator Hub](https://create.roblox.com) → **Creations** → your experience → **Monetization**.

| Create | Suggested price | Icon | Paste the ID into |
|---|---|---|---|
| Pass: **2x Coins** | 99 R$ | `pass-2x-coins.png` | `Assets.GamePasses.DoubleCoins` |
| Pass: **VIP** | 199 R$ | `pass-vip.png` | `Assets.GamePasses.VIP` |
| Developer Product: **Skip Stage** | 15 R$ | `product-skip-stage.png` | `Assets.Products.SkipStage` |

The buttons appear in-game automatically once an ID is set. **Badges** (under **Engagement → Badges**)
go into `Assets.Badges` the same way.

## Part E: Turn on saving and go public

1. **File → Experience Settings → Security** → turn on **Enable Studio Access to API Services**.
2. **File → Publish to Roblox**.
3. **Experience Settings → Permissions** → **Public**.

---

## Build your own stages

The scripts work with any course that follows these rules:

| Thing | How |
|---|---|
| Checkpoints | Parts in a `Workspace.Checkpoints` folder, named `1`, `2`, `3`, ... The last one is the finish. |
| Coins | Parts in a `Workspace.Coins` folder. Optional Number attribute `Value`. |
| Kill bricks | Parts in a `Workspace.KillParts` folder, or tagged `KillPart`. |
| Spinner | Tag `Spinner`. Attribute `SpinSpeed` in degrees per second. |
| Slider | Tag `Slider`. Attributes `Distance`, `Speed` and `Phase`. |
| Vanishing platform | Tag `Fade`. Attributes `FadeTime` and `ReturnTime`. |
| Conveyor | Tag `Conveyor`. Attribute `ConveyorSpeed`; it pushes toward the part's front face. |
| Jump pad | Tag `JumpPad`. Attribute `Power`. |
| Zones | Edit `Config.Zones` to set where each world starts, and its music, time of day and gravity. |

Tags and attributes are at the bottom of the **Properties** panel. Once a `Checkpoints` folder exists,
the sample course builder skips itself.

## Tuning (`Config` script)

- **Rewards:** `CheckpointReward`, `WinReward`, `DailyRewards`, `InviteReward`, `CoinRespawnSeconds`.
- **Wins bonus:** `WinMultiplierStep` and `MaxWinMultiplier`.
- **Volume:** `MusicVolume` and `SfxVolume`.
- **Resets:** change `DataStoreName` to reset everyone's progress, or `LeaderboardVersion` to reset the leaderboards.

## Developer notes

- `src/` is the source code, and it uses a [Rojo](https://rojo.space) layout (`default.project.json`).
- `python3 build_installer.py` rebuilds `Installer.lua` from `src/`.
- `python3 tools/make_audio.py` regenerates the music and sound effects. It needs numpy and ffmpeg.
- Coins, stages, wins, purchases and rewards are all decided on the server, so exploiters can't award them to themselves.
