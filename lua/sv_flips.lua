CXFLIPS.activeFlips = {}

-- Networking
util.AddNetworkString("openFlips") -- Menu for creating and joining flips
util.AddNetworkString("createFlip")
util.AddNetworkString("deleteFlip")
util.AddNetworkString("finishFlip") -- Give money to winning player
util.AddNetworkString("openFlip") -- Open specific flip game
util.AddNetworkString("forceCloseMenu")

net.Receive("createFlip", function()
    local creator = net.ReadEntity()
    local amount = net.ReadUInt(32)

    if (CXFLIPS.activeFlips[creator:SteamID64()] ~= nil or creator:getDarkRPVar("money") < amount) then
        return
    else
        creator:addMoney(-amount)

        CXFLIPS.activeFlips[creator:SteamID64()] = {
            creator = creator,
            amount = amount,
            winner = 0,
            ongoing = false,
            joiner = nil
        }
    end
end)

net.Receive("deleteFlip", function()
    local forcedDelete = net.ReadBool()
    local ply = net.ReadEntity()
    local betAmount = CXFLIPS.activeFlips[ply:SteamID64()]["amount"]

    if (CXFLIPS.activeFlips[ply:SteamID64()]["ongoing"]) then
        return
    end

    CXFLIPS.activeFlips[ply:SteamID64()] = nil

    if (forcedDelete) then
        ply:addMoney(betAmount)
        net.Start("openFlips")
        net.WriteTable(CXFLIPS.activeFlips)
        net.Send(ply)
    end
end)

net.Receive("openFlip", function()
    local joiner = net.ReadEntity()
    local creator = net.ReadEntity()

    if (joiner == creator or joiner:getDarkRPVar("money") < CXFLIPS.activeFlips[creator:SteamID64()]["amount"] or CXFLIPS.activeFlips[creator:SteamID64()] == nil) then
        return
    end

    if (CXFLIPS.activeFlips[creator:SteamID64()]["ongoing"]) then
        return
    else
        CXFLIPS.activeFlips[creator:SteamID64()]["ongoing"] = true
    end

    -- Check for joiner in other games
    for key, value in ipairs(CXFLIPS.activeFlips) do
        if (key == joiner:SteamID64()) then
            CXFLIPS.activeFlips[joiner:SteamID64()] = nil
        end
        if (joiner == value["joiner"]) then
            return
        end
    end

    math.randomseed(os.time())
    CXFLIPS.activeFlips[creator:SteamID64()]["joiner"] = joiner
    CXFLIPS.activeFlips[creator:SteamID64()]["winner"] = math.Round(math.random(0, 1))

    net.Start("openFlip")
        net.WriteEntity(joiner)
        net.WriteEntity(creator)
        net.WriteTable(CXFLIPS.activeFlips[creator:SteamID64()])
        net.WriteInt(CXFLIPS.activeFlips[creator:SteamID64()]["winner"], 8) -- Winner
    net.Send({joiner, creator})
end)

net.Receive("finishFlip", function()
    local creator = net.ReadEntity()
    local joiner = net.ReadEntity()
    local winner = CXFLIPS.activeFlips[creator:SteamID64()]["winner"]

    if (not CXFLIPS.activeFlips[creator:SteamID64()]["ongoing"]) then
        return
    end

    if (winner < 0.5) then
        -- Joiner won
        joiner:addMoney(CXFLIPS.activeFlips[creator:SteamID64()]["amount"] * 2)
    else
        -- Creator won
        creator:addMoney(CXFLIPS.activeFlips[creator:SteamID64()]["amount"] * 2)
    end

    timer.Simple(5, function()
        net.Start("forceCloseMenu")
        net.Send({joiner, creator})
        CXFLIPS.activeFlips[creator:SteamID64()] = nil
    end)
end)

-- Hooks
hook.Add("PlayerSay", "CxFlips.PlayerSay", function(ply, text, team)
    if (string.lower(text) == "!flips") then
        net.Start("openFlips")
        if (CXFLIPS.activeFlips == nil) then
            CXFLIPS.activeFlips = {}
        end
        net.WriteTable(CXFLIPS.activeFlips)
        net.Send(ply)
    end
end)

hook.Add("PlayerDisconnected", "CxFlips.PlayerLeave", function(ply)
    if (CXFLIPS.activeFlips == nil) then return end

    -- Clear flip
    if (CXFLIPS.activeFlips[ply:SteamID64()] ~= nil) then
        ply:addMoney(CXFLIPS.activeFlips[ply:SteamID64()]["amount"])
        net.Start("forceCloseMenu")
        net.Send({CXFLIPS.activeFlips[ply:SteamID64()]["joiner"], ply})
        if (CXFLIPS.activeFlips[ply:SteamID64()]["joiner"] ~= nil) then
            CXFLIPS.activeFlips[ply:SteamID64()]["joiner"]:addMoney(CXFLIPS.activeFlips[ply:SteamID64()]["amount"])
        end
        CXFLIPS.activeFlips[ply:SteamID64()] = nil
    end
end)

hook.Add("PostGamemodeLoaded", "CxFlips.GamemodeLoaded", function()
    if (DarkRP.resetLaws ~= nil) then
        print("[CxFlips] DarkRP found!")
    end
end)