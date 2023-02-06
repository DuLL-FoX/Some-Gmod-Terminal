include("autorun/sh_terminal.lua")
-- Color Presets
local ColorCyan = Color(4, 217, 255, 255)
local ColorRed = Color(255, 4, 4, 255)
-- Get the screen size
local screenHeight = ScrH()
local screenWidth = ScrW()

function OpenHandTerminal()
    -- Create the terminal frame
    local HandFrame = vgui.Create("DFrame")
    HandFrame:SetSize(500, 500)
    HandFrame:Center()
    HandFrame:SetTitle("Terminal Interface")
    HandFrame:MakePopup()
    -- Text of the terminal
    local HandText = vgui.Create("DTextEntry", HandFrame)
    HandText:SetPos(HandFrame:GetWide() * 0.05, HandFrame:GetTall() * 0.15)
    HandText:SetSize(HandFrame:GetWide() * 0.90, HandFrame:GetTall() * 0.8)
    HandText:SetMultiline(true)
    HandText:SetUpdateOnType(true)
    HandText:SetText(handTerminalText)

    HandText.OnChange = function(self)
        local text = self:GetValue()
        handTerminal:SetHandTerminalText(text)
    end
end

function OpenConsoleTerminal()
    local text = console:GetConsoleText()
    -- Create the terminal frame
    TerminalFrame = vgui.Create("DFrame")
    TerminalFrame:SetSize(screenWidth / 2, screenHeight / 2)
    TerminalFrame:Center()
    TerminalFrame:MakePopup()
    TerminalFrame:SetTitle("Terminal")

    TerminalFrame.Paint = function(self, w, h)
        surface.SetDrawColor(0, 0, 0, 200)
    end

    -- Image of frame
    ImageFrame = vgui.Create("DImage", TerminalFrame)
    ImageFrame:SetSize(TerminalFrame:GetSize())
    ImageFrame:SetImage("materials/vgui/frame.png")
    ImageFrame:SetImageColor(ColorCyan)
    -- Text button
    TerminalTextButton = vgui.Create("DButton", TerminalFrame)
    TerminalTextButton:SetText("Data")
    TerminalTextButton:SetPos(TerminalFrame:GetWide() * 0.05, TerminalFrame:GetTall() * 0.05)
    TerminalTextButton:SetSize(TerminalFrame:GetWide() * 0.45, TerminalFrame:GetTall() * 0.10)
    -- Settings button
    TerminalSettingsButton = vgui.Create("DButton", TerminalFrame)
    TerminalSettingsButton:SetText("Settings")
    TerminalSettingsButton:SetPos(TerminalFrame:GetWide() * 0.5, TerminalFrame:GetTall() * 0.05)
    TerminalSettingsButton:SetSize(TerminalFrame:GetWide() * 0.45, TerminalFrame:GetTall() * 0.10)
    -- Text entry box
    TerminalText = vgui.Create("DTextEntry", TerminalFrame)
    TerminalText:SetPos(TerminalFrame:GetWide() * 0.05, TerminalFrame:GetTall() * 0.15)
    TerminalText:SetSize(TerminalFrame:GetWide() * 0.90, TerminalFrame:GetTall() * 0.8)
    TerminalText:SetMultiline(true)
    TerminalText:SetUpdateOnType(true)
    TerminalText:SetText(text)
    -- Button to download the text to the hand terminal
    TerminalDownloadButton = vgui.Create("DButton", TerminalFrame)
    TerminalDownloadButton:SetText("Download")
    TerminalDownloadButton:SetPos(TerminalFrame:GetWide() * 0.05, TerminalFrame:GetTall() * 0.95 - TerminalDownloadButton:GetTall())
    TerminalDownloadButton:SetSize(TerminalFrame:GetWide() * 0.45, TerminalFrame:GetTall() * 0.10)
    --Invisible until the correct password is entered
    TerminalText:SetVisible(false)
    TerminalTextButton:SetVisible(false)
    TerminalSettingsButton:SetVisible(false)
    TerminalDownloadButton:SetVisible(false)
    -- Text entry box for password
    TerminalPassword = vgui.Create("DTextEntry", TerminalFrame)
    TerminalPasswordW = TerminalFrame:GetWide() * 0.1
    TerminalPasswordH = TerminalFrame:GetTall() * 0.05
    TerminalPassword:SetPos(TerminalFrame:GetWide() / 2 - TerminalPasswordW / 2, TerminalFrame:GetTall() / 2 - TerminalPasswordH / 2)
    TerminalPassword:SetSize(TerminalPasswordW, TerminalPasswordH)

    if console:GetConsolePassword() == "" then
        -- If there is no password, create one
        CreatePassword()
    else
        -- If there is a password, enter it
        EnterPassword()
    end

    -- When the text is changed, update the console text
    TerminalText.OnChange = function(self)
        text = self:GetValue()
    end

    -- When the terminal is closed, update the text variable
    TerminalFrame.OnClose = function(self)
        net.Start("ConsoleUpdateText")
        net.WriteEntity(console)
        net.WriteString(text)
        net.SendToServer()
    end

    TerminalDownloadButton.DoClick = function()
        handTerminal:SetHandTerminalText(console:GetConsoleText())
    end

    -- Change the elements to be visible for the settings
    TerminalSettingsButton.DoClick = function()
        TerminalText:SetVisible(false)
        TerminalDownloadButton:SetVisible(false)
        ChangePassword()
    end

    -- Change the elements to be visible for the text
    TerminalTextButton.DoClick = function()
        if TerminalPasswordChange.IsVisible then
            TerminalPasswordChange:SetVisible(false)
            TerminalPassword:SetVisible(false)
        end
        TerminalText:SetVisible(true)
        TerminalDownloadButton:SetVisible(true)
    end
end

function ChangePassword()
    TerminalPasswordChange = vgui.Create("DLabel", TerminalFrame)
    TerminalPasswordChange:SetPos(TerminalFrame:GetWide() / 2 - TerminalPasswordW / 2, TerminalFrame:GetTall() / 2 - TerminalPasswordH / 2 + TerminalPasswordH)
    TerminalPasswordChange:SetSize(TerminalPasswordW, TerminalPasswordH)
    TerminalPasswordChange:SetText("Change Password")
    TerminalPasswordChange:SetTextColor(Color(0, 255, 0))
    TerminalPassword:SetVisible(true)

    TerminalPassword.OnEnter = function(self)
        local password = self:GetValue()
        net.Start("ConsoleUpdatePassword")
        net.WriteEntity(console)
        net.WriteString(password)
        net.SendToServer()
        TerminalText:SetVisible(true)
        TerminalTextButton:SetVisible(true)
        TerminalSettingsButton:SetVisible(true)
        TerminalPassword:SetVisible(false)
        TerminalPasswordChange:SetVisible(false)
    end
end

function CreatePassword()
    local TerminalPasswordCreate = vgui.Create("DLabel", TerminalFrame)
    TerminalPasswordCreate:SetPos(TerminalFrame:GetWide() / 2 - TerminalPasswordW / 2, TerminalFrame:GetTall() / 2 - TerminalPasswordH / 2 + TerminalPasswordH)
    TerminalPasswordCreate:SetSize(TerminalPasswordW, TerminalPasswordH)
    TerminalPasswordCreate:SetText("Create Password")
    TerminalPasswordCreate:SetTextColor(Color(0, 255, 0))

    TerminalPassword.OnEnter = function(self)
        local password = self:GetValue()
        net.Start("ConsoleUpdatePassword")
        net.WriteEntity(console)
        net.WriteString(password)
        net.SendToServer()
        TerminalText:SetVisible(true)
        TerminalTextButton:SetVisible(true)
        TerminalSettingsButton:SetVisible(true)
        TerminalPasswordCreate:Remove()
        TerminalPassword:Remove()

        if LocalPlayer():HasWeapon("hand_terminal") then
            TerminalDownloadButton:SetVisible(true)
        end
    end
end

function EnterPassword()
    TerminalPassword.OnEnter = function(self)
        -- If the password is correct, display the text
        print(console:GetConsolePassword())

        if self:GetValue() == console:GetConsolePassword() then
            TerminalText:SetVisible(true)
            TerminalTextButton:SetVisible(true)
            TerminalSettingsButton:SetVisible(true)
            self:SetVisible(false)

            if LocalPlayer():HasWeapon("hand_terminal") then
                TerminalDownloadButton:SetVisible(true)
            end
            -- If the password is incorrect, display an error
        else
            local TerminalPasswordError = vgui.Create("DLabel", TerminalFrame)
            TerminalPasswordError:SetPos(TerminalFrame:GetWide() / 2 - TerminalPasswordW / 2, TerminalFrame:GetTall() / 2 - TerminalPasswordH / 2 + TerminalPasswordH)
            TerminalPasswordError:SetSize(TerminalPasswordW, TerminalPasswordH)
            TerminalPasswordError:SetText("Incorrect Password")
            TerminalPasswordError:SetTextColor(Color(255, 0, 0))
            ImageFrame:SetImageColor(ColorRed)

            timer.Simple(1, function()
                TerminalPasswordError:Remove()
                ImageFrame:SetImageColor(ColorCyan)
            end)
        end
    end
end

net.Receive("ConsoleOpen", function(len, ply)
    -- Get the entity and text and password
    console = net.ReadEntity()
    OpenConsoleTerminal()
end)

net.Receive("OpenHandTerminalText", function(len, ply)
    handTerminal = net.ReadEntity()
    handTerminalText = handTerminal:GetHandTerminalText() or handTerminal:SetHandTerminalText("")
    OpenHandTerminal()
end)