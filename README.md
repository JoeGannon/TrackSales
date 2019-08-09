# Track Sales
Tracks Sales from AH, COD Payments, and Trades.

If the sale involves a "profession item" (ore for mining, bags for tailoring, etc) it automatically adds the sale to your total 
for that profession. Run `/ts` or `/tracksales` to see the report. Run `/ts help` for more options.

![Thumbnail](https://github.com/JoeGannon/TrackSales/blob/master/Preview.png)

Features
 - automatically track AH, COD Payments, and Trades
 - manually adjust profession totals
 - hide/show and reorder items in the report
 - add/remove tracked professions (Current character professions are added automatically on first load or when a new profession is learned)
 
 
 Known limitations
 - COD Payments: use the item name from the subject of the mail (the client automatically adds this) 
 - Trades: If a trade includes multiple profession items, the first one found will be used to track the trade. 
 - Trades: Multiple trades with the same character, for the same gold amount, within 2.5 minutes will only be tracked once, see [client limitations](https://github.com/JoeGannon/TrackSales/blob/master/TrackSales/TrackSales.lua#L71-L73) 
