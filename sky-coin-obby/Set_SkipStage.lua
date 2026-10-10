-- Paste into the Studio command bar (bottom box) and press Enter.
local a = game.ReplicatedStorage.Shared.Assets
local s = a.Source
local n
s, n = s:gsub("(SkipStage%s*=%s*)%d+", function(prefix) return prefix .. "3717552827" end, 1)
if n == 0 then
	s, n = s:gsub("\nreturn Assets", "\nAssets.Products = Assets.Products or {}\nAssets.Products.SkipStage = 3717552827\nreturn Assets", 1)
end
a.Source = s
print(n > 0 and "Skip Stage ID saved: 3717552827" or "Could not find Assets - tell Claude")
