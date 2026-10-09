# Your setup checklist (things only you can do in Roblox)

Work through these in order. Each one takes a few minutes.

## 1. Install the latest version
If you see **"Stage 1/30"** or **"Stage 1/40"** in the game, you're on an old version.
Run the newest installer: paste it in the **command bar** and click **Run**. Your Assets IDs are kept.

## 2. Sounds and music (Creator Hub → Development Items → Audio → Upload)
- [x] The 10 original sounds and music tracks (already done)
- [ ] `music_calm.mp3` and `music_phonk.mp3` (send Claude the 2 IDs)

## 3. Images (Creator Hub → Development Items → Images → Upload)
- [ ] Skyboxes: the 24 files in `skybox/`. Send Claude the IDs and you'll get a one-paste command.
- [ ] UI icons, shop icons and Daily Draw cards (`art/README.md`). Optional: the game works without them.

## 4. Game icon and thumbnails (Studio → File → Experience Settings → Basic Info)
- [ ] Icon: `game-icon-gary.png`
- [ ] Thumbnails: `thumbnail-gary.png`, `thumbnail-op-tower.png`, `thumbnail.png`
- [ ] Title and description from `PUBLISHING.md`

## 5. Game passes (Creator Hub → your game → Monetization → Passes → Create)
Upload the icon, set a price, turn on **Item for Sale**, then copy the pass ID.

| Pass | Price | Icon |
|---|---|---|
| Rocket Launcher | 299 R$ | `pass-rocket-launcher.png` |
| VIP | 199 R$ | `pass-vip.png` |
| Triple Jump | 99 R$ | `pass-triple-jump.png` |
| 2x Coins | 99 R$ | `pass-2x-coins.png` |
| Speed Coil | 79 R$ | `pass-speed-coil.png` |
| Gravity Coil | 79 R$ | `pass-gravity-coil.png` |
| Double Jump | 49 R$ | `pass-double-jump.png` |

## 6. Developer product (Monetization → Developer Products → Create)
- [ ] **Skip Stage**: 15 R$, icon `product-skip-stage.png`

## 7. Badges (Creator Hub → your game → Engagement → Badges)
- [ ] Welcome, Reached Candy Land, Reached Outer Space, Reached Gary's Lair, Escaped Gary (first win),
      10 Wins, OP 100, OP 500, OP 1000

**Then send Claude every ID in one message**, for example `Rocket: 123, VIP: 456, ...`.
You'll get one command that writes them all into the game.

## 8. Optional extras
- [ ] A Roblox group: send Claude its ID for the group-join coin bonus
- [ ] The 3D landmarks: import the `.glb` files into ServerStorage → `Landmarks`

## 9. Go live
- [ ] **File → Experience Settings → Security** → Enable Studio Access to API Services
- [ ] **File → Publish to Roblox**
- [ ] **Experience Settings → Permissions → Public**
