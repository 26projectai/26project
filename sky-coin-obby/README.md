# Sky Coin Obby

A Roblox obby with:

- **Checkpoints**: progress saves, and you respawn on your last stage
- **Coins**: spinning collectibles, plus bonus coins for each new stage
- **Cosmetic shop**: 3 trails and 3 auras, bought with coins and saved forever
- **Sample course**: a 10-stage course builds itself so you can play right away
- **Artwork** from Higgsfield: game icon, thumbnail, UI icons and shop icons (see [`art/`](art/README.md))

```
src/
  shared/   -> ReplicatedStorage > Shared            (ModuleScripts)
    Config          settings: prices, coin values, image ids
    ShopCatalog     the shop items
    Remotes         client/server communication
  server/   -> ServerScriptService > Server
    PlayerData      ModuleScript: saving/loading coins, stage, cosmetics
    Checkpoints     Script
    Coins           Script
    Obstacles       Script: kill bricks + spinners
    Shop            Script: buy/equip + applies trails/auras
    CourseBuilder   Script: builds the sample course (optional)
  client/   -> StarterPlayer > StarterPlayerScripts > Client
    Interface       LocalScript: coin/stage HUD, shop window, pop-ups
    Coins           LocalScript: coin spin + hide-after-collect
```

---

## Step 1: Create and publish the place

1. Open **Roblox Studio**, click **New**, then **Baseplate**.
2. Go to **File → Publish to Roblox**, create a new experience, and name it *Sky Coin Obby*.
3. Go to **Home → Game Settings → Security**, turn on **Enable Studio Access to API Services**,
   and click **Save**. Without this, progress won't save while you test in Studio.
4. Open **View → Explorer** and **View → Properties** if they aren't open already.

## Step 2: Add the scripts

Pick **one** of these.

### Option A: Copy and paste (no extra tools)

The names have to match **exactly**, including capital letters, because the scripts find each other by name.

**ReplicatedStorage**
1. Hover **ReplicatedStorage** in Explorer, click **+**, and add a **Folder**. Rename it `Shared`.
2. Inside `Shared`, add 3 **ModuleScripts** named `Config`, `ShopCatalog` and `Remotes`.
3. Open each one, delete the default code, and paste in the matching file from `src/shared/`.

**ServerScriptService**
1. Add a **Folder** and name it `Server`.
2. Inside `Server`, add a **ModuleScript** named `PlayerData` and paste in `src/server/PlayerData.luau`.
3. Inside `Server`, add 5 **Scripts** (regular Scripts, not LocalScripts) named `Checkpoints`, `Coins`,
   `Obstacles`, `Shop` and `CourseBuilder`. Paste in the matching `*.server.luau` files.

**StarterPlayer → StarterPlayerScripts**
1. Add a **Folder** and name it `Client`.
2. Inside `Client`, add 2 **LocalScripts** named `Interface` and `Coins`. Paste in the matching
   `*.client.luau` files.

Your Explorer should look like this:

```
ReplicatedStorage
  Shared
    Config        (ModuleScript)
    Remotes       (ModuleScript)
    ShopCatalog   (ModuleScript)
ServerScriptService
  Server
    PlayerData    (ModuleScript)
    Checkpoints   (Script)
    Coins         (Script)
    CourseBuilder (Script)
    Obstacles     (Script)
    Shop          (Script)
StarterPlayer
  StarterPlayerScripts
    Client
      Coins       (LocalScript)
      Interface   (LocalScript)
```

### Option B: Rojo (keeps the code synced with this repo)

1. Install the [Rojo](https://rojo.space) VS Code extension or CLI, and the Rojo Studio plugin.
2. In this folder, run `rojo serve`.
3. In Studio, open the **Rojo** plugin and click **Connect**. Everything above appears automatically,
   and edits to the files show up in Studio live.

## Step 3: Play-test

1. Click **Play** (F5).
2. You'll spawn on the green **STAGE 1** pad, high in the sky. The course runs along the +X direction
   and finishes on a gold **FINISH!** pad at stage 10.
3. Check that:
   - Touching gold coins makes them burst, and the coin counter at the top left goes up.
   - Each new green pad shows a "Checkpoint!" pop-up and gives +5 coins.
   - Red bricks, the spinning bar and the orange lava kill you, and you respawn on your last pad.
   - The pink **SHOP** button on the left opens the shop. Buy the Rainbow Trail (25 coins) and run around.
   - When you stop and Play again, your coins, stage and cosmetics are still there.
4. To test with more than one player, use **Test → Clients and Servers → 2 Players → Start**.

> Note: there's probably a default `SpawnLocation` in the middle of the baseplate. Delete it.
> Stage 1 is a spawn already, and the scripts teleport everyone to their saved checkpoint anyway.

## Step 4: Add the Higgsfield artwork

Until you do this, the UI uses simple drawn placeholders, so everything already works without it.

1. Download the PNGs listed in [`art/README.md`](art/README.md).
2. **Game icon and thumbnail**: go to **Home → Game Settings → Basic Info**. Upload
   `game-icon.png` as the **Game Icon** and `thumbnail.png` under **Thumbnails**, then click **Save**.
   (You can also do this on the [Creator Hub](https://create.roblox.com) under your experience's settings.)
3. **UI and shop icons**: go to **View → Asset Manager → Images**, click **Bulk Import**, and select
   the 8 `ui-*.png` and `item-*.png` files. Wait for moderation to finish (usually under a minute).
4. Right-click each image, choose **Copy Asset ID**, and paste the ID into the scripts as
   `"rbxassetid://<the number>"`:
   - `ui-coin.png` → `Config.Images.Coin`
   - `ui-shop-button.png` → `Config.Images.ShopButton`
   - each `item-*.png` → the `Icon = ...` line of the matching item in `ShopCatalog`
5. Press **Play**. The HUD and shop now show the real art.

## Step 5: Build your own course (optional)

The scripts work with any course that follows these rules:

| Thing | How to make it |
|---|---|
| **Checkpoints** | Parts inside a Folder in Workspace called `Checkpoints`, named `1`, `2`, `3`, ... in order. Make `1` a SpawnLocation. |
| **Coins** | Any parts inside a Folder in Workspace called `Coins`. Set them **Anchored**. Optionally add a Number attribute called `Value` (for example, a 10-coin coin). |
| **Kill bricks** | Parts inside a Folder in Workspace called `KillParts`, **or** any part with the tag `KillPart` (Properties → Tags). |
| **Spinners** | Any part with the tag `Spinner`. Optionally add a Number attribute `SpinSpeed` in degrees per second (default 90). Add the `KillPart` tag as well if it should kill. |

Easiest workflow: play once, then copy the generated `Checkpoints`, `Coins`, `KillParts` and
`SampleCourse` folders out of Workspace while the game runs (select them in Explorer, **Ctrl+C**, stop the game,
then **Ctrl+V** onto Workspace). Edit them however you like. Because a `Checkpoints` folder now
exists, the builder skips itself. You can also delete `CourseBuilder`, or set
`Config.BuildSampleCourse = false`.

## Tuning

Everything is in `Config` and `ShopCatalog`:

- `CoinRespawnSeconds`: how long until a collected coin comes back for that player.
- `CheckpointReward`: bonus coins for each new stage.
- `AllowStageSkipping`: allow touching stage 5 straight from stage 2.
- `Sounds`: paste sound IDs from the Creator Store (Toolbox → Audio) for coin, checkpoint and purchase sounds.
- Shop prices, names and colors: edit `ShopCatalog`. To add an item, copy an existing entry and give it a new `Id`.
- To reset everyone's saved data, change `DataStoreName` (for example, to `SkyCoinObby_v2`).

## How it's protected against cheaters

All coins, stages and purchases are decided **on the server**:

- Coins check that the player is actually near the coin.
- Checkpoints must be reached in order.
- Purchases check the price against the saved coin balance.
- Saving never overwrites data that failed to load.
