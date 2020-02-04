# Introduction
Consume power to teleport items.

# Usage
This mod adds four entities: Logistics Center, Collector Chest, Requester Chest, Logistics Center Controller.

* Step 1, place a `logistics center`.  Before that, you need to make sure that you have enough power supply to get the logistics center charged, 1GJ for the first charge, 2MJ per second by default, and much more power for items teleportation depending on the distance and items count.  
  
* Step 2, place a `collector chest`, put some items in it. And if everything goes right, the items will be teleported to the logistics center. Open the logistics center, and you will see the item signals. Though you can't take them out directly from the logistics center like a container.
  
* Step 3, place a `requester chest`, set the request items to what you just put into at step 2, and the requester chest will request from the logistics center, gets items teleported into it. 

* Moreover, build a `logistics center controller` to limit the max number the logistics center can store for each item. And rearrange signal positions.

It works like the robots logistics, some kind of.

# Mod Settings
* Logistics Center Quick Start
* Tech Cost
* Item Type Limitation
* Requester Chest Logistics Slots Count
* Logistics Center Signal Slot Count
* Collector Chest Power Consumption Per Item Per Distance
* Requester Chest Power Consumption Per Item Per Distance
* Check Collector Chest On Nth Tick (One Round)
* Check Requester Chest On Nth Tick (One Round)
* Check Collector Chest Percentages Per Round
* Check Requester Chest Percentages Per Round

Setting `Item Type Limitation` has three options: "all", "ores only", "except ores" which will give you quite different gaming experience.

# Known Issues
* This mod do not support multi-surfaces right now. Which means you should NOT use `Logistics Center`, `Collector Chest`, `Requester Chest` in other surfaces, use them only in the main world. For example, do NOT use them in Factorissimo2 buildings.
* This mod do not support multi-forces with multi-players. That means if you and your friends are in different forces, your items will be teleported together.

# Announcement
The images of entities are copied from other mods, including `BlackMarket` and `BobGreenHouse`. So if you have proper images, contact me on (Github)[https://mods.factorio.com/mod/ab_logisticscenter] or the mod (Discussion Board)[https://mods.factorio.com/mod/ab_logisticscenter/discussion].
