# TrackSales
Lightweight Classic WoW addon for tracking profession sales

Tracks Sales from AH, COD Payments, and Trades. Also tracks tips from summons (warlock), portals and water (mage).

If the sale involves a "profession item" (ore for mining, bags for tailoring, etc) it automatically adds the sale to your total 
for that profession. Run `/ts` or `/tracksales` to see the report. Run `/ts help` for more options.

![Thumbnail](https://github.com/JoeGannon/TrackSales/blob/master/TrackSalesThumb.png)

Features
 - manually adjust profession totals
 - hide/show and reorder items in the report
 - add/remove tracked professions (Current character professions are automatically added on first load or when a new profession is learned)
 
 
 Quirks
 - COD Payments: use the item name from the subject of the mail (The wow client automatically adds the first item added to the subject line) 
 - Trades: If a trade includes multiple profession items, the first one found will be used to track the entire trade
 - Tips: any gold traded to the player without any items included will be counted as a portal or summon (configurable threshold)
 
 
