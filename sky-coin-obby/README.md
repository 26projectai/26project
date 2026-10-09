# Escape Greedy Gary's Obby (Sky Coin Obby)

**Greedy Gary stole all the Sky Coins.** Escape his **100-stage story obby**, then climb his **1000-stage OP
difficulty-chart tower**. It's built to keep players coming back and bringing friends.

## Feature checklist

| Requirement | Where it is in the game |
|---|---|
| **Core obstacles** | Checkpoints, lava/laser kill bricks, fading platforms, sliders (moving blocks), conveyors, jump pads, spinners, truss climbs, trap doors |
| **Stage counter UI** | HUD at the top (story `Stage x/100` or `OP x/1000`), plus the live race bar |
| **Fast reset** | **R key / RESET button**, 1.5 second respawn |
| **DataStores** | Everything saves: stages, OP stage, coins, wins, rebirths, jump power, cosmetics, streaks |
| **Theme, skybox, lighting** | 3 worlds with **custom skyboxes** (`skybox/`), atmosphere haze, colour grading, ClockTime per world |
| **Audio** | Checkpoint/coin/win/death sound effects, a **calm** looping track, a **phonk** track, and per-world music (MUSIC button = radio) |
| **Badges for worlds** | Candy Land, Space, first win, 10 wins, OP 100/500/1000 |
| **Unlockable cosmetics** | **Champion Halo** (finish the story), **OP Halo** (OP 100), **Rebirth Trail**, **Comet Trail** (stage 20) |
| **Developer Products / passes** | Skip Stage (product), plus Speed Coil, Gravity Coil, Rocket, Double/Triple Jump, 2x Coins and VIP (passes) |
| **Icon, thumbnails, title, tags** | `art/README.md` and [PUBLISHING.md](PUBLISHING.md) |
| **Unique movement** | **Grappling Hook** for everyone (grapple-gap stages), rocket launcher, moon gravity, jump pads |
| **Escape narrative** | Villain **Greedy Gary**: giant models with live taunts, a 3-second intro, jumpscares |
| **Co-op** | **Team-up tether** (x1.5 coins together) and the **Teamwork Vault** (needs 2 players on the plates) |
| **Audio themes** | Calm (ASMR-style) and Phonk radio stations |
| **Tower / difficulty chart** | **1000-stage OP tower**: 20 tiers from EFFORTLESS to OP, each higher than the last |
| **First 60 seconds** | Welcome badge + **50 coins on spawn**, coins within the first few seconds of the course, no tutorial |
| **Rebirth / prestige** | REWARDS → Rebirth: permanent x2, x3… coins, Rebirth Trail, `[Rebirth N]` chat title |
| **"+1" idle stat** | **Jump Power +1 every second** (toggle in the HUD). The Jump Power Tower in the hub needs it |
| **Social hooks** | Invite = **3x coins for both players** (verified with Roblox referrals), co-op, Slap Hand in the lobby and hub |
| **Daily engagement** | Login streak (escalating), free **Daily Draw** (Common/Rare/Legendary, odds shown) |
| **Juice** | Landing screen-shake, checkpoint bursts + flash, confetti, coin combo pitch, pop-ups |
| **Forgiving failure** | After 3 and 6 deaths: +10% / +20% speed and jump on that stage; after 8, a cheap **coin skip** |
| **Clip-worthy traps** | Trap-door floors, Gary jumpscares, the "DO NOT TOUCH" yeet pad |
| **Boost Stations** | Every **15 stages** (story and OP): x2 coin orb + mini live dashboard |

**Gameplay**
- **100 stages across 4 worlds**, each with its own music, sky, haze and scenery:
  - **Sky Islands** (1–10): lava sea, tree islands, rainbow.
  - **Candy Land** (11–20): vanishing platforms, jump pads, sliders, gumdrop hills, lollipop forest.
  - **Outer Space** (21–40, the biggest world): **low gravity moon jumps**, laser gates, long leaps, planets, asteroid belt.
- **Central hub** at stage 20: a big island with a giant **dashboard** showing the live race (who's furthest in
  this server), global Most Wins and Fastest Run. There's also a fountain, and luxury NPCs walk around.
- **Luxury NPCs** (Sir Goldsworth, Lady Diamond, …) stroll the lobby and hub. **Touch one for 2x coins for 60 seconds.**
- **Live race bar** at the top shows every player's avatar on the track. **Stage select**: click the stage counter
  to replay any stage you've reached.
- **Optional 3D landmarks** made with Higgsfield: a sky castle, a candy castle and a space station.

**Progress and rewards**
- **Milestones:**
  - Stage 10 unlocks **Spring Boots**, a free double jump.
  - Stage 20 unlocks the **Comet Trail**.
- **Wins loop:** finish the course for +1 win and 100 coins, then restart. Each win adds +25% coins, up to ×5.
- **Daily Draw** (free, every 24 hours, odds shown):
  - **Common 70%:** Jump Boots ×1.5, small smoke aura, silver name tag.
  - **Rare 25%:** Jump Boots ×2.5, swirling aura, gold name tag + **custom nickname** (filtered).
  - **Legendary 5%:** Jump Boots ×5, super aura + sparkles + glow, rainbow name tag + nickname, **+50% coins**, flame trail.
- **Daily login streak**, **promo codes**, **Roblox group bonus**, all in the **REWARDS** window.
- **Speedrun timer**, plus global **leaderboards**. Runs that use passes or boosts still earn wins but aren't ranked.
- **Cosmetic shop:** trails and auras, plus a VIP-only trail and the milestone Comet Trail.
- **Friend invites:** +50 coins each.

**Robux**
- **Game passes:** Rocket Launcher, Double Jump, Triple Jump, Speed Coil, Gravity Coil, 2x Coins, VIP. They're sold in
  an in-game **PASSES** store.
- **Skip Stage** developer product.

**Polish and analytics**
- **Original music and sound effects**, all copyright-free.
- **Higgsfield artwork** for every icon, card, pass and landmark (see [`art/`](art/README.md)).
- **Roblox Analytics:** stages 1–10 are logged as the onboarding funnel, and every stage and win as custom events.

How to get players: **[LAUNCH_PLAYBOOK.md](LAUNCH_PLAYBOOK.md)** and **[GROWTH_RESEARCH.md](GROWTH_RESEARCH.md)**.

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

### New audio and skyboxes (this update)
- Upload `audio/music_calm.mp3` and `audio/music_phonk.mp3`, then put their IDs in `Assets.Music.Calm` / `Assets.Music.Phonk`.
- Upload the 18 images in `skybox/` (`Sky_Bk.png` … `Space_Up.png`), then put their IDs in `Assets.Skyboxes`.
  Each world has 6 faces: Bk, Dn, Ft, Lf, Rt, Up.

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
| Pass: **Rocket Launcher** | 299 R$ | `pass-rocket-launcher.png` | `Assets.GamePasses.RocketLauncher` |
| Pass: **Triple Jump** | 99 R$ | `pass-triple-jump.png` | `Assets.GamePasses.TripleJump` |
| Pass: **Double Jump** | 49 R$ | `pass-double-jump.png` | `Assets.GamePasses.DoubleJump` |
| Pass: **Speed Coil** | 79 R$ | `pass-speed-coil.png` | `Assets.GamePasses.SpeedCoil` |
| Pass: **Gravity Coil** | 79 R$ | `pass-gravity-coil.png` | `Assets.GamePasses.GravityCoil` |
| Developer Product: **Skip Stage** | 15 R$ | `product-skip-stage.png` | `Assets.Products.SkipStage` |

Passes appear in the in-game **PASSES** store automatically once an ID is set, with their real icon and price.
Runs that use Rocket / Jump / Coil passes still earn wins and coins but don't count for the Fastest Run board. **Badges** (under **Engagement → Badges**)
go into `Assets.Badges` the same way.

## Part E: Turn on saving and go public

1. **File → Experience Settings → Security** → turn on **Enable Studio Access to API Services**.
2. **File → Publish to Roblox**.
3. **Experience Settings → Permissions** → **Public**.

---

## Optional: 3D landmarks (Higgsfield)

1. Download the three `.glb` models from the links in [`art/README.md`](art/README.md).
2. In Studio, go to **File → Import 3D**, pick a `.glb`, and import it.
3. In **ServerStorage**, create a **Folder** named `Landmarks`. Drag each imported model into it, and rename
   them `Sky`, `Candy` and `Space`.
4. Press Play. The game places and sizes them automatically: a castle in Sky, a candy castle in Candy Land,
   and a space station in Space.

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
