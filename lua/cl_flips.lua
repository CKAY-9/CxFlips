local scrw, scrh = ScrW(), ScrH()
local pw, ph = scrw * 0.5, scrh * 0.4

-- Generate Fonts
surface.CreateFont("CxRegular", {
    font = "Inter Regular",
    extended = false,
    size = ScrW() * 0.01,
    antialias = true
})

surface.CreateFont("CxLight", {
    font = "Inter Light",
    extended = false,
    size = ScrW() * 0.01,
    antialias = true
})

surface.CreateFont("CxBlack", {
    font = "Inter Black",
    extended = false,
    size = ScrW() * 0.01,
    antialias = true
})

surface.CreateFont("CxBold", {
    font = "Inter Bold",
    extended = false,
    size = ScrW() * 0.01,
    antialias = true
})

surface.CreateFont("CxMedium", {
    font = "Inter Black",
    extended = false,
    size = ScrW() * 0.015,
    antialias = true
})

surface.CreateFont("CxLarge", {
    font = "Inter Black",
    extended = false,
    size = ScrW() * 0.02,
    antialias = true
})

-- Flip menu
CXFLIPS.OpenFlip = function()
    local ply = LocalPlayer()

    local joiner = net.ReadEntity()
    local creator = net.ReadEntity()
    local flipInfo = net.ReadTable()
    local playing = true
    local winner = net.ReadInt(8)

    if (IsValid(CXFLIPS.Menu)) then
        CXFLIPS.Menu:Remove()
    end

    surface.PlaySound("tools/ifm/beep.wav")

    -- this is mainly just for popup and other background things
    CXFLIPS.Menu = vgui.Create("DFrame")
    CXFLIPS.Menu:SetSize(pw, ph)
    CXFLIPS.Menu:Center()
    CXFLIPS.Menu:MakePopup(true)
    CXFLIPS.Menu:SetTitle("")
    CXFLIPS.Menu:ShowCloseButton(false)

    CXFLIPS.Menu.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 0))
    end

    -- visual panel
    CXFLIPS.PrimaryPanel = vgui.Create("DPanel", CXFLIPS.Menu)
    CXFLIPS.PrimaryPanel:SetSize(pw, ph)
    CXFLIPS.PrimaryPanel:SetPos(0, 0)

    CXFLIPS.PrimaryPanel.Paint = function(self, w, h)
        draw.RoundedBox(15, 0, 0, w, h, CXFLIPS.backgroundColor)
    end

    -- Header
    CXFLIPS.Header = vgui.Create("DPanel", CXFLIPS.PrimaryPanel)
    CXFLIPS.Header:SetSize(pw, ph * 0.1)
    CXFLIPS.Header:Dock(TOP)
    CXFLIPS.Header:DockMargin(0, 0, 0, ph * 0.05)

    CXFLIPS.Header.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, CXFLIPS.foregroundColor)
        draw.SimpleText("CxFlips - " .. creator:GetName() .. "'s Flip", "CxBold", 10, h * 0.5, CXFLIPS.textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    CXFLIPS.HeaderClose = vgui.Create("DButton", CXFLIPS.Header)
    CXFLIPS.HeaderClose:SetSize(pw * 0.05, ph * 0.1)
    CXFLIPS.HeaderClose:Dock(RIGHT)
    CXFLIPS.HeaderClose:SetText("")

    CXFLIPS.HeaderClose.Paint = function(self, w, h)
        draw.SimpleText("X", "CxBlack", 10, h * 0.5, CXFLIPS.textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local Title = vgui.Create("DPanel", CXFLIPS.PrimaryPanel)
    Title:SetSize(pw, ph * 0.1)
    Title:Dock(TOP)
    Title:DockMargin(pw * 0.125, 10, pw * 0.125, 0)
    Title.Paint = function(self, w, h)
        draw.SimpleText("Flipping...", "CxLarge", w * 0.5, h * 0.5, CXFLIPS.textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local JoinerAvatar = vgui.Create("AvatarImage", CXFLIPS.PrimaryPanel)
    JoinerAvatar:SetSize(ph * 0.5, ph * 0.5)
    JoinerAvatar:Dock(LEFT)
    JoinerAvatar:DockMargin(25, 0, 25, ph * 0.25)
    JoinerAvatar:SetPlayer( joiner, 256 )

    local CreatorAvatar = vgui.Create("AvatarImage", CXFLIPS.PrimaryPanel)
    CreatorAvatar:SetSize(ph * 0.5, ph * 0.5)
    CreatorAvatar:Dock(RIGHT)
    CreatorAvatar:DockMargin(25, 0, 25, ph * 0.25)
    CreatorAvatar:SetPlayer( creator, 256 )

    local Amount = vgui.Create("DPanel", CXFLIPS.PrimaryPanel)
    Amount:SetSize(pw, ph * 0.1)
    Amount:SetPos(0, ph * 0.85)
    Amount.Paint = function(self, w, h)
        draw.SimpleText("Bet Amount: $" .. flipInfo["amount"], "CxLarge", w * 0.5, h * 0.5, CXFLIPS.textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    timer.Simple(7, function()
        playing = false
        local playerWinner = nil
        if (winner < 0.5) then
            -- Joiner won
            if (ply == joiner) then
                chat.AddText(Color(100, 255, 100), "[CxFlips] You won the flip!")
                surface.PlaySound("buttons/button15.wav")
            else
                chat.AddText(CXFLIPS.dangerousColor, "[CxFlips] You lost the flip!")
                surface.PlaySound("buttons/button10.wav")
            end
            playerWinner = joiner
        else
            -- Creator won
            if (ply == creator) then
                chat.AddText(Color(100, 255, 100), "[CxFlips] You won the flip!")
                surface.PlaySound("buttons/button15.wav")
            else
                chat.AddText(CXFLIPS.dangerousColor, "[CxFlips] You lost the flip!")
                surface.PlaySound("buttons/button10.wav")
            end
            playerWinner = creator
        end

        local WinnerLabel = vgui.Create("DPanel", CXFLIPS.PrimaryPanel)
        WinnerLabel:SetSize(pw, ph * 0.2)
        WinnerLabel:SetPos(0, (ph * 0.5) - (ph * 0.2 / 2))
        WinnerLabel.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, 0, 0, Color(0, 0, 0, 0))
            draw.SimpleText("Winner: " .. playerWinner:GetName(), "CxMedium", w * 0.5, h * 0.5, CXFLIPS.textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        net.Start("finishFlip")
            net.WriteEntity(creator)
            net.WriteEntity(joiner)
        net.SendToServer()

        timer.Simple(5, function()
            if (IsValid(CXFLIPS.Menu)) then
                CXFLIPS.Menu:Remove()
            end
        end)
    end)

    CXFLIPS.HeaderClose.DoClick = function()
        if (IsValid(CXFLIPS.Menu) and !playing) then
            surface.PlaySound("buttons/lightswitch2.wav")
            CXFLIPS.Menu:Remove()
        end
    end
end

CXFLIPS.OpenFlips = function()
    local ply = LocalPlayer()
    local flips = net.ReadTable()

    if (IsValid(CXFLIPS.Menu)) then
        CXFLIPS.Menu:Remove()
    end

    -- this is mainly just for popup and other background things
    CXFLIPS.Menu = vgui.Create("DFrame")
    CXFLIPS.Menu:SetSize(pw, ph)
    CXFLIPS.Menu:Center()
    CXFLIPS.Menu:MakePopup(true)
    CXFLIPS.Menu:SetTitle("")
    CXFLIPS.Menu:ShowCloseButton(false)

    CXFLIPS.Menu.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 0))
    end

    -- visual panel
    CXFLIPS.PrimaryPanel = vgui.Create("DPanel", CXFLIPS.Menu)
    CXFLIPS.PrimaryPanel:SetSize(pw, ph)
    CXFLIPS.PrimaryPanel:SetPos(0, 0)

    CXFLIPS.PrimaryPanel.Paint = function(self, w, h)
        draw.RoundedBox(15, 0, 0, w, h, CXFLIPS.backgroundColor)
    end

    -- Header
    CXFLIPS.Header = vgui.Create("DPanel", CXFLIPS.PrimaryPanel)
    CXFLIPS.Header:SetSize(pw, ph * 0.1)
    CXFLIPS.Header:Dock(TOP)
    CXFLIPS.Header:DockMargin(0, 0, 0, ph * 0.05)

    CXFLIPS.Header.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, CXFLIPS.foregroundColor)
        draw.SimpleText("CxFlips", "CxBold", 10, h * 0.5, CXFLIPS.textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    CXFLIPS.HeaderClose = vgui.Create("DButton", CXFLIPS.Header)
    CXFLIPS.HeaderClose:SetSize(pw * 0.05, ph * 0.1)
    CXFLIPS.HeaderClose:Dock(RIGHT)
    CXFLIPS.HeaderClose:SetText("")

    CXFLIPS.HeaderClose.Paint = function(self, w, h)
        draw.SimpleText("X", "CxBlack", 10, h * 0.5, CXFLIPS.textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    CXFLIPS.HeaderClose.DoClick = function()
        if (IsValid(CXFLIPS.Menu)) then
            surface.PlaySound("buttons/lightswitch2.wav")
            CXFLIPS.Menu:Remove()
        end
    end

    -- Create
    CXFLIPS.CreatePanel = vgui.Create("DPanel", CXFLIPS.PrimaryPanel)
    CXFLIPS.CreatePanel:SetSize(pw, ph)
    CXFLIPS.CreatePanel:Hide()
    CXFLIPS.CreatePanel:SetPos(0, ph * 0.1)

    CXFLIPS.CreatePanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, 0, 0, Color(0, 0, 0, 0))
    end

    CXFLIPS.ReturnButton = vgui.Create("DButton", CXFLIPS.CreatePanel)
    CXFLIPS.ReturnButton:Dock(TOP)
    CXFLIPS.ReturnButton:SetText("")
    CXFLIPS.ReturnButton:DockMargin(pw * 0.33, 20, pw * 0.33, 10)
    CXFLIPS.ReturnButton:SetSize(pw * 0.33, ph * 0.1)

    CXFLIPS.ReturnButton.Paint = function(self, w, h)
        draw.RoundedBox(10, 0, 0, w, h, CXFLIPS.foregroundColor)
        draw.SimpleText("Cancel Creation", "CxBold", w / 2, h / 2, CXFLIPS.textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    CXFLIPS.ReturnButton.DoClick = function()
        surface.PlaySound("buttons/lightswitch2.wav")
        CXFLIPS.HomePanel:Show()
        CXFLIPS.CreatePanel:Hide()
    end

    local cashAmount = 1
    CXFLIPS.CreateAmount = vgui.Create("DNumberWang", CXFLIPS.CreatePanel)
    CXFLIPS.CreateAmount:Dock(TOP)
    CXFLIPS.CreateAmount:DockMargin(pw * 0.33, 30, pw * 0.33, 30)
    CXFLIPS.CreateAmount:SetSize(pw * 0.33, ph * 0.1)
    CXFLIPS.CreateAmount:SetMin(1)
    CXFLIPS.CreateAmount:SetMax(ply:getDarkRPVar("money"))

    CXFLIPS.CreateAmount.Paint = function(self, w, h)
        draw.RoundedBox(10, 0, 0, w, h, CXFLIPS.foregroundColor)
        draw.SimpleText("$" .. cashAmount, "CxBold", w / 2, h / 2, CXFLIPS.textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    CXFLIPS.CreateAmount.OnValueChanged = function(self)
        cashAmount = self:GetValue()
    end

    CXFLIPS.CreateFlipButton = vgui.Create("DButton", CXFLIPS.CreatePanel)
    CXFLIPS.CreateFlipButton:Dock(TOP)
    CXFLIPS.CreateFlipButton:SetText("")
    CXFLIPS.CreateFlipButton:DockMargin(pw * 0.33, 10, pw * 0.33, 10 + (ph * 0.1))
    CXFLIPS.CreateFlipButton:SetSize(pw * 0.33, ph * 0.1)

    CXFLIPS.CreateFlipButton.Paint = function(self, w, h)
        draw.RoundedBox(10, 0, 0, w, h, CXFLIPS.foregroundColor)
        draw.SimpleText("Create Flip", "CxBlack", w / 2, h / 2, CXFLIPS.textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    CXFLIPS.CreateFlipButton.DoClick = function(self, w, h)
        if (cashAmount > ply:getDarkRPVar("money")) then
            cashAmount = ply:getDarkRPVar("money")
        end
        if (cashAmount <= 0) then
            cashAmount = 1
        end

        if (ply:getDarkRPVar("money") <= 0) then
            surface.PlaySound("buttons/button10.wav")
            chat.AddText(CXFLIPS.dangerousColor, "[CxFlips] You need to have atleast $1")
            return
        end

        net.Start("createFlip")
            net.WriteEntity(ply)
            net.WriteUInt(cashAmount, 32)
        net.SendToServer()

        if (IsValid(CXFLIPS.Menu)) then
            CXFLIPS.Menu:Remove()
        end

        surface.PlaySound("buttons/button24.wav")
        chat.AddText(Color(100, 255, 100), "[CxFlips] Created Flip!")
    end

    CXFLIPS.CreateInfo = vgui.Create("DLabel", CXFLIPS.CreatePanel)
    CXFLIPS.CreateInfo:Dock(TOP)
    CXFLIPS.CreateInfo:DockMargin(pw * 0.175, 10, pw * 0.125, 30)
    CXFLIPS.CreateInfo:SetFont("CxRegular")
    CXFLIPS.CreateInfo:SetColor(CXFLIPS.textColor)
    CXFLIPS.CreateInfo:SetText("Joining another flip will delete this one. Bet amount will be taken upon flip creation!")


    -- Homepage
    CXFLIPS.HomePanel = vgui.Create("DPanel", CXFLIPS.PrimaryPanel)
    CXFLIPS.HomePanel:SetSize(pw, ph)
    CXFLIPS.HomePanel:SetPos(0, ph * 0.1)

    CXFLIPS.HomePanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, 0, 0, Color(0, 0, 0, 0))
    end

    if (flips[ply:SteamID64()] ~= nil) then
        CXFLIPS.DeleteExistingGameButton = vgui.Create("DButton", CXFLIPS.HomePanel)
        CXFLIPS.DeleteExistingGameButton:Dock(TOP)
        CXFLIPS.DeleteExistingGameButton:SetText("")
        CXFLIPS.DeleteExistingGameButton:DockMargin(pw * 0.33, 20, pw * 0.33, 10)
        CXFLIPS.DeleteExistingGameButton:SetSize(pw * 0.33, ph * 0.1)

        CXFLIPS.DeleteExistingGameButton.Paint = function(self, w, h)
            draw.RoundedBox(10, 0, 0, w, h, CXFLIPS.dangerousColor)
            draw.SimpleText("Delete Flip", "CxBold", w / 2, h / 2, CXFLIPS.textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        CXFLIPS.DeleteExistingGameButton.DoClick = function()
            surface.PlaySound("buttons/button14.wav")
            net.Start("deleteFlip")
                net.WriteBool(true)
                net.WriteEntity(ply)
            net.SendToServer()
            if (IsValid(CXFLIPS.Menu)) then
                surface.PlaySound("buttons/button24.wav")
                chat.AddText(Color(100, 255, 100), "[CxFlips] Deleted Flip!")
                CXFLIPS.Menu:Remove()
            end
        end
    else
        CXFLIPS.CreateButton = vgui.Create("DButton", CXFLIPS.HomePanel)
        CXFLIPS.CreateButton:Dock(TOP)
        CXFLIPS.CreateButton:SetText("")
        CXFLIPS.CreateButton:DockMargin(pw * 0.33, 20, pw * 0.33, 10)
        CXFLIPS.CreateButton:SetSize(pw * 0.33, ph * 0.1)

        CXFLIPS.CreateButton.Paint = function(self, w, h)
            draw.RoundedBox(10, 0, 0, w, h, CXFLIPS.foregroundColor)
            draw.SimpleText("Create Flip", "CxBold", w / 2, h / 2, CXFLIPS.textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        CXFLIPS.CreateButton.DoClick = function()
            surface.PlaySound("buttons/lightswitch2.wav")
            CXFLIPS.HomePanel:Hide()
            CXFLIPS.CreatePanel:Show()
        end
    end

    if (#table.GetKeys(flips) >= 1) then
        CXFLIPS.ActiveFlips = vgui.Create("DScrollPanel", CXFLIPS.HomePanel)
        CXFLIPS.ActiveFlips:Dock(FILL)
        CXFLIPS.ActiveFlips:DockMargin(pw * 0.15, 10, pw * 0.15, 30)

        -- Show all table 
        for key, value in pairs(flips) do
            if (key ~= ply:SteamID64() and !value["ongoing"]) then
                local Flip = CXFLIPS.ActiveFlips:Add("DButton")
                Flip:SetText("")
                Flip:Dock(TOP)
                Flip:DockMargin(0, 5, 0, 5)
                Flip:SetSize(pw * 0.7, ph * 0.2)

                Flip.Paint = function(self, w, h)
                    draw.RoundedBox(5, 0, 0, w, h, CXFLIPS.foregroundColor)
                    draw.SimpleText(value["creator"]:GetName() .. "'s Flip", "CxBlack", w * 0.33, h * 0.33, CXFLIPS.textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    draw.SimpleText("Bet Amount: $" .. value["amount"], "CxBlack", w * 0.33, h * 0.67, CXFLIPS.textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end

                Flip.DoClick = function()
                    net.Start("openFlip")
                        net.WriteEntity(ply) -- Local player
                        net.WriteEntity(value["creator"]) -- Creator
                    net.SendToServer()
                end

                local Avatar = vgui.Create( "AvatarImage", Flip )
                Avatar:SetSize( ph * 0.15, ph * 0.15 )
                Avatar:Dock(RIGHT)
                Avatar:DockMargin(0, ph * 0.025, pw * 0.3 * 0.67, ph * 0.025)
                Avatar:SetPlayer( value["creator"], 64 )

            end
        end
    else
        CXFLIPS.NoFlipInfo = vgui.Create("DLabel", CXFLIPS.HomePanel)
        CXFLIPS.NoFlipInfo:Dock(FILL)
        CXFLIPS.NoFlipInfo:DockMargin(pw * 0.3, 0, 10, 40)
        CXFLIPS.NoFlipInfo:SetFont("CxLarge")
        CXFLIPS.NoFlipInfo:SetColor(CXFLIPS.dangerousColor)
        CXFLIPS.NoFlipInfo:SetText("There are no active flips!")
    end
end

-- Recieve network
net.Receive("openFlips", CXFLIPS.OpenFlips) -- Menu for creating and joining
net.Receive("openFlip", CXFLIPS.OpenFlip) -- Actual game
net.Receive("forceCloseMenu", function()
    if (IsValid(CXFLIPS.Menu)) then
        CXFLIPS.Menu:Remove()
    end
end)