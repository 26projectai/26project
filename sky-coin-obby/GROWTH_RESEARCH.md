# How to run Sky Coin Obby well and grow it

This is based on Roblox's own Creator Analytics guidance and a few 2026 developer sources (listed at the
bottom). The numbers from third parties are rough guides, not official benchmarks.

## The order that matters

Roblox's own docs give a clear priority order:

1. **First fix D1 retention and average session time.** These show whether new players enjoy the game
   enough to come back the next day.
2. **Then D7 and D30 retention.** These show long-term progression.
3. **Then monetization:** how many players pay, and how much each payer spends.
4. **Only then buy traffic (ads).** Roblox recommends getting your metrics at least as good as
   similar games before paying for visitors. Ads that send players into a game they quickly leave
   just waste Robux.

## What to watch (Creator Hub → your game → Analytics)

| Metric | What it tells you | Rough target |
|---|---|---|
| **D1 retention** | % of new players who come back the next day | Under 20% is a problem. Obbies are a competitive genre, so aim higher |
| **Average session length** | Minutes per visit | 8+ minutes |
| **Onboarding funnel** | Where new players quit, stage by stage | Look for one stage with a big drop |
| **Custom events** | `StageReached` (every stage) and `Win` | See how far players really get |
| **Payer conversion** | % of players who buy anything | Grows once passes are set up |

**The game already logs these for you:** stages 1–10 are sent as Roblox's **onboarding funnel**, and every
stage plus every win is logged as a custom event. Once players arrive, look at
**Analytics → Onboarding funnel**. If, say, 40% quit at stage 4, make stage 4 easier.

Benchmark scorecards (how you compare to similar games) only appear once you have **100+ daily players**.

## The first-session test (do this before any ads)

Watch 3–5 people who've never seen the game play it, without helping them. Check:
- Do they understand what to do in the first 10 seconds?
- Do they get their first reward (coins, then a checkpoint) within 30 seconds?
- When they die, do they understand why, and try again?
- Do they find the SHOP, REWARDS and PASSES buttons by themselves?

Anything they struggle with is the next thing to fix.

## Getting players

### Free

1. **Codes on social media.** The game has promo codes (`LAUNCH`, `SKYCOIN`, `MOONJUMP` in `Config.Codes`).
   Post a new code with every TikTok, YouTube Short or Reel ("code in the video!"). Add new codes for each
   update and milestone, like `1KVISITS`.
2. **Short videos.** The best formats for obbies:
   - Speedruns showing the timer
   - Moon-jump launches in Space
   - A Legendary draw reveal
   - "Rating your nicknames"
   - "I made a Roblox game" devlogs
3. **Invites.** Built in: +50 coins for both players, and the "race you" invite on the win screen. Roblox's
   Friend Referral Program also lets referral links come from the invite menu.
4. **A Roblox group.** Create one, put its ID in `Config.GroupId`, and members get +200 coins. Group members
   get notified about updates, which gives you a free channel back to your players.
5. **Weekly updates.** Change the title tag (e.g. `[🆕 LAVA WORLD]`), add a code, and post a video. Updates
   bring old players back, and that return rate is what the algorithm rewards.
6. **Events.** Weekend 2x coins (temporarily raise `WinMultiplierStep`), holiday trails, and race nights
   where you play with your community.

### Paid (only once D1 and session length look healthy)

- **Sponsored listings** put your game in search results and on the home page. That's the most direct
  option for a new game.
- **Do the break-even maths first.** One 2026 analysis estimates roughly **4–12 Robux per visit**,
  depending on targeting and thumbnail quality. If an average visitor spends less than that, ads lose money.
- **Start small.** Spend a few hundred Robux a day, compare 2–3 thumbnails, and keep the winner. The
  thumbnail is the biggest factor in click-through rate.

## Running it well

- **Keep the game safe and within the rules.**
  - The Daily Draw is **free**, with no Robux and no paid currency, and its **odds are shown** in-game.
    Roblox's paid random items policy covers items bought with Robux; it requires showing every outcome
    with odds that add up to 100%. Don't add paid draws or paid spins without reading that policy.
  - Nicknames go through Roblox's text filter before anyone can see them.
  - Don't reward players for liking or favouriting the game.
- **Watch server health.** Set the server size to 20–30 so races feel busy. If Studio's MicroProfiler
  shows lag, the scenery part count is the first thing to reduce. Those settings are in `Scenery.luau`.
- **Back up before big changes.** Before testing new features, use **File → Save to Roblox As** to make a
  test copy. Change `Config.DataStoreName` only when you really mean to reset everyone's progress.
- **Listen to players.** Read your game's comments and group wall. Rewards from new codes and events
  get people talking.

## Ideas for future updates (in rough priority order)

1. **A new world every 2–4 weeks**, such as Lava Factory, Ice Kingdom or Haunted Mansion, with 10 stages
   each. More content keeps people returning.
2. **Pets that follow you** and give small coin boosts. This is the most popular progression system on
   Roblox.
3. **Rebirths:** reset your wins for a permanent bigger multiplier and a badge. This adds long-term goals.
4. **Weekly global race events,** where the fastest time this week wins a unique trail.
5. **Private servers** for friend groups, plus a race-mode countdown.
6. **Seasonal pass** (free and premium tiers) with cosmetics. Plan this carefully around Roblox's rules.

## Sources

- [Roblox Creator Docs: Analytics](https://create.roblox.com/docs/en-us/production/analytics)
- [Roblox Creator Docs: Retention dashboard](https://create.roblox.com/docs/en-us/production/analytics/retention.md)
- [Roblox Creator Docs: Growth strategies](https://create.roblox.com/docs/en-us/get-started/strategies.md)
- [Roblox Creator Docs: Paid random items policy](https://create.roblox.com/docs/en-us/production/monetization/paid-random-items)
- [RoLearn: First-week retention optimization](https://rolearn.dev/guidance/first-week-retention-optimization)
- [RoWatcher: The Roblox analytics stack in 2026](https://rowatcher.com/news/the-roblox-analytics-stack-how-studios-win-with-data-in-2026)
- [RoWatcher: Roblox ads in 2026, the break-even math](https://rowatcher.com/news/roblox-ads-in-2026-the-break-even-math-small-devs-ignore)
- [obby.fun: Roblox analytics guide](https://www.obby.fun/blog/roblox-analytics-guide)
- [Roblox: Expanding the advertising platform (2026)](https://about.roblox.com/vi/newsroom/2026/01/roblox-expands-advertising-platform)
