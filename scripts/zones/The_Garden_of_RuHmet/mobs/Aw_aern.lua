-----------------------------------
-- Area: The Garden of Ru'Hmet
--  MOB: Aw_aern PH (Ix'Aern DRK and DRG)
-----------------------------------

package.loaded["scripts/zones/The_Garden_of_RuHmet/TextIDs"] = nil;

-----------------------------------

require("scripts/zones/The_Garden_of_RuHmet/TextIDs");
require("scripts/zones/The_Garden_of_RuHmet/MobIDs");

-----------------------------------
-- onMobSpawn Action
-----------------------------------

function onMobSpawn(mob)
    local IxAernDRG_PH = GetServerVariable("[SEA]IxAernDRG_PH"); -- Should be be the ID of the mob that spawns the actual PH

    -- Pick the Ix'Aern (DRG) PH if the server doesn't have one, and the if the actual PH/NM isn't up. Then, set it.
    if (GetMobAction(IxAernDRG) == 0 and GetServerVariable("[SEA]IxAernDRG_PH") == 0) then  -- This should be cleared when the mob is killed.
        IxAernDRG_PH = AwAernDRGGroups[math.random(1, #AwAernDRGGroups)] + math.random(0, 2); -- The 4th mobid in each group is a pet. F that son
        SetServerVariable("[SEA]IxAernDRG_PH", IxAernDRG_PH);
    end;
end;

-----------------------------------
-- onMobDespawn
-----------------------------------

function onMobDespawn(mob)
    local currentMobID = mob:getID();

    -- Ix'Aern (DRG) Placeholder mobs
    local IxAernDRG_PH = GetServerVariable("[SEA]IxAernDRG_PH"); -- Should be be the ID of the mob that spawns the actual PH.

    -- If the mob killed was the randomized PH, then Ix'Aern (DRG) in the specific spot, unclaimed and not aggroed.
    if (IxAernDRG_PH == currentMobID) then
        -- Select spawn location based on ID
        if (currentMobID >= 16920777 and currentMobID < 16920781) then
            GetMobByID(IxAernDRG):setSpawn(-520, 5, -520, 225); -- Bottom Left
        elseif (currentMobID >= 16920781 and currentMobID < 16920785) then
            GetMobByID(IxAernDRG):setSpawn(-520, 5, -359, 30); -- Top Left
        elseif (currentMobID >= 16920785 and currentMobID < 16920789) then
            GetMobByID(IxAernDRG):setSpawn(-319, 5, -359, 95); -- Top Right
        elseif (currentMobID >= 16920789 and currentMobID < 16920793) then
            GetMobByID(IxAernDRG):setSpawn(-319, 5, -520, 156); -- Bottom Right
        end;
        SpawnMob(IxAernDRG);
        SetServerVariable("[SEA]IxAernDRG_PH", 0); -- Clear the variable because it is spawned!
    end;
end;


function chance(percentage)
    return math.random() < percentage / 100
    -- or equivalently, math.random() * 100 < percentage
end

function onMobDeath(mob, player)

    mob = mob:getID();

    --Ix'Aern drk PH in pos 1 Hume-Elvaan
    local Ix_aern_drk_PH_pos1 = "16920660 16920661 16920662"
    --Ix'Aern drk PH in pos 2 Elvaan-Galka
    local Ix_aern_drk_PH_pos2 = "16920665 16920666 16920667"
    --Ix'Aern drk PH in pos 3 Taru-Mithra
    local Ix_aern_drk_PH_pos3 = "16920646 16920647 16920648"
    --Ix'Aern drk PH in pos 4 Mithra-Hume
    local Ix_aern_drk_PH_pos4 = "16920651 16920652 16920653"

    local VanadielHour = VanadielHour();
    local posi_drk = GetServerVariable("[POSI]Ix_aern_drk");

    i = GetServerVariable("[PH]Ix_aern_drk");
    -- print(i)

    -- Ix'Aern DRK PH check
    -- Check if Aw_aern are in the room with the ???
    -- Set chance of gaining animosity at 50% no idea the real % of gain
    if (posi_drk == 1) then
        if string.find(Ix_aern_drk_PH_pos1, tostring(mob)) then
            -- print(mob)
            if (i == 3) then
                player:messageSpecial(SHEER_ANIMOSITY);
                if(VanadielHour % 4 == 0) then
                    SetServerVariable("[PH]Ix_aern_drk", 0);
                end
            else
                if chance(50) then -- set 50% chance of giving animosity
                    i = i + 1; -- adds 1 to the kill count.
                else
                    i = i + 0; -- adds 1 to the kill count.
                end
                SetServerVariable("[PH]Ix_aern_drk", i); -- set server variable to what i value is.
            end
        end
    elseif (posi_drk == 2) then
        if string.find(Ix_aern_drk_PH_pos2, tostring(mob)) then
            -- print(mob)
            if (i == 3) then
                player:messageSpecial(SHEER_ANIMOSITY);
                if(VanadielHour % 4 == 0) then
                    SetServerVariable("[PH]Ix_aern_drk", 0);
                end
            else
                if chance(50) then -- set 50% chance of giving animosity
                    i = i + 1; -- adds 1 to the kill count.
                else
                    i = i + 0; -- adds 1 to the kill count.
                end
                SetServerVariable("[PH]Ix_aern_drk", i); -- set server variable to what i value is.
            end
        end
    elseif (posi_drk == 3) then
        if string.find(Ix_aern_drk_PH_pos3, tostring(mob)) then
            -- print(mob)
            if (i == 3) then
                player:messageSpecial(SHEER_ANIMOSITY);
                if(VanadielHour % 4 == 0) then
                    SetServerVariable("[PH]Ix_aern_drk", 0);
                end
            else
                if chance(50) then -- set 50% chance of giving animosity
                    i = i + 1; -- adds 1 to the kill count.
                else
                    i = i + 0; -- adds 1 to the kill count.
                end
                SetServerVariable("[PH]Ix_aern_drk", i); -- set server variable to what i value is.
            end
        end
    elseif (posi_drk == 4) then
        if string.find(Ix_aern_drk_PH_pos4, tostring(mob)) then
            -- print(mob)
            if (i == 3) then
                player:messageSpecial(SHEER_ANIMOSITY);
                if(VanadielHour % 4 == 0) then
                    SetServerVariable("[PH]Ix_aern_drk", 0);
                end
            else
                if chance(50) then-- set 50% chance of giving animosity
                    i = i + 1; -- adds 1 to the kill count.
                else
                    i = i + 0; -- adds 1 to the kill count.
                end
                SetServerVariable("[PH]Ix_aern_drk", i); -- set server variable to what i value is.
            end
        end

    end
end

