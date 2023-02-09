-- Color Presets
local ColorCyan = Color(4, 217, 255, 255)
local ColorRed = Color(255, 4, 4, 255)
-- Get the screen size
local screenHeight = ScrH()
local screenWidth = ScrW()
local handTerminalText
local TerminalTextButton, TerminalSettingsButton, TerminalTextFrame, TerminalDownloadButton
local TerminalPasswordCreate, TerminalPassword, TerminalPasswordError, TerminalPasswordChange, TerminalHackButton

local function PasswordCreateScreen(visibleState)
    -- Label for creating the password
    TerminalPasswordCreate = vgui.Create("DLabel", TerminalFrame)
    TerminalPasswordCreate:SetPos(TerminalFrame:GetWide() / 2 - TerminalPasswordW / 2, TerminalFrame:GetTall() / 2 - TerminalPasswordH / 2 + TerminalPasswordH)
    TerminalPasswordCreate:SetSize(TerminalPasswordW, TerminalPasswordH)
    TerminalPasswordCreate:SetText("Create Password")
    TerminalPasswordCreate:SetTextColor(Color(0, 255, 0))
    TerminalPasswordCreate:SetVisible(false)

    if visibleState then
        TerminalPasswordCreate:SetVisible(true)
        TerminalPassword:SetVisible(true)
    else
        TerminalPasswordCreate:SetVisible(false)
        TerminalPassword:SetVisible(false)
    end
end

local function SwitchBetweenDataAndSettingsScreen(visibleState)
    if visibleState then
        -- Label for changing the password
        TerminalPasswordChange = vgui.Create("DLabel", TerminalFrame)
        TerminalPasswordChange:SetPos(TerminalFrame:GetWide() / 2 - TerminalPasswordW / 2, TerminalFrame:GetTall() / 2 - TerminalPasswordH / 2 + TerminalPasswordH)
        TerminalPasswordChange:SetSize(TerminalPasswordW, TerminalPasswordH)
        TerminalPasswordChange:SetText("Change Password")
        TerminalPasswordChange:SetTextColor(Color(0, 255, 0))
        TerminalPasswordChange:SetVisible(false)
        -- Text entry box for password
        TerminalTextFrame:SetVisible(false)
        TerminalPasswordChange:SetVisible(true)
        TerminalPassword:SetVisible(true)
    else
        if LocalPlayer():HasWeapon("hand_terminal" or "hand_hack_terminal") then
            TerminalDownloadButton:SetVisible(true)
        end

        TerminalTextFrame:SetVisible(true)
        TerminalPasswordChange:SetVisible(false)
        TerminalPassword:SetVisible(false)
    end
end

local function ValidateLength(textEntry, maxCharacters)
    -- Of course, it’s not so important for us if the client kills himself with a text, but it’s better not to give him such an opportunity
    if #textEntry:GetValue() >= maxCharacters then
        textEntry.AllowInput = function(stringValue)
            return true
        end

        textEntry:SetText(string.sub(textEntry:GetValue(), 1, maxCharacters))
    else
        textEntry.AllowInput = function(stringValue)
            return false
        end
    end
end

local function UpdateConsoleText(ent, newValue)
    net.Start("ConsoleUpdateText")
    net.WriteEntity(ent)
    net.WriteString(newValue)
    net.SendToServer()
end

local function UpdateConsolePassword(ent, newValue)
    net.Start("ConsoleUpdatePassword")
    net.WriteEntity(ent)
    net.WriteString(newValue)
    net.SendToServer()
end

local function ChangePassword(console)
    SwitchBetweenDataAndSettingsScreen(true)

    TerminalPassword.OnChange = function(self)
        ValidateLength(self, 8)
    end

    TerminalPassword.OnEnter = function(self)
        local password = self:GetValue()
        UpdateConsolePassword(console, password)
        SwitchBetweenDataAndSettingsScreen(false)
    end
end

local function CreatePassword(console)
    PasswordCreateScreen(true)

    TerminalPassword.OnChange = function(self)
        ValidateLength(self, 8)
    end

    TerminalPassword.OnEnter = function(self)
        local password = self:GetValue()
        UpdateConsolePassword(console, password)
        MainScreen(true)
        TerminalPasswordCreate:Remove()
        TerminalPassword:SetVisible(false)
    end
end

function EnterPassword(password)
    PasswordEnterScreen(1)

    TerminalPassword.OnChange = function(self)
        ValidateLength(self, 8)
    end

    TerminalPassword.OnEnter = function(self)
        -- If the password is correct, display the text
        if self:GetValue() == password then
            PasswordEnterScreen(2)
            MainScreen(true)
            -- If the password is incorrect, display an error
        else
            PasswordEnterScreen(3)
        end
    end
end

local function OpenConsoleTerminal(console, consoleText, consolePassword)
    -- Create the terminal frame
    TerminalFrame = vgui.Create("DFrame")
    TerminalFrame:SetSize(screenWidth / 2, screenHeight / 2)
    TerminalFrame:Center()
    TerminalFrame:MakePopup()
    TerminalFrame:SetTitle("Terminal")

    TerminalFrame.Paint = function(self, w, h)
        surface.SetDrawColor(0, 0, 0, 200)
    end

    -- Text entry box for password
    TerminalPassword = vgui.Create("DTextEntry", TerminalFrame)
    -- Terminal password text entry size
    TerminalPasswordW = TerminalFrame:GetWide() * 0.1
    TerminalPasswordH = TerminalFrame:GetTall() * 0.05
    TerminalPassword:SetPos(TerminalFrame:GetWide() / 2 - TerminalPasswordW / 2, TerminalFrame:GetTall() / 2 - TerminalPasswordH / 2)
    TerminalPassword:SetSize(TerminalPasswordW, TerminalPasswordH)
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
    TerminalTextButton:SetVisible(false)
    -- Settings button
    TerminalSettingsButton = vgui.Create("DButton", TerminalFrame)
    TerminalSettingsButton:SetText("Settings")
    TerminalSettingsButton:SetPos(TerminalFrame:GetWide() * 0.5, TerminalFrame:GetTall() * 0.05)
    TerminalSettingsButton:SetSize(TerminalFrame:GetWide() * 0.45, TerminalFrame:GetTall() * 0.10)
    TerminalSettingsButton:SetVisible(false)
    -- Text entry box
    TerminalTextFrame = vgui.Create("DTextEntry", TerminalFrame)
    TerminalTextFrame:SetPos(TerminalFrame:GetWide() * 0.05, TerminalFrame:GetTall() * 0.15)
    TerminalTextFrame:SetSize(TerminalFrame:GetWide() * 0.90, TerminalFrame:GetTall() * 0.8)
    TerminalTextFrame:SetMultiline(true)
    TerminalTextFrame:SetUpdateOnType(true)
    TerminalTextFrame:SetText(consoleText)
    TerminalTextFrame:SetVisible(false)
    -- Button to download the text to the hand terminal
    TerminalDownloadButton = vgui.Create("DButton", TerminalFrame)
    TerminalDownloadButton:SetText("Download")
    TerminalDownloadButton:SetPos(TerminalFrame:GetWide() * 0.05, TerminalFrame:GetTall() * 0.95 - TerminalDownloadButton:GetTall())
    TerminalDownloadButton:SetSize(TerminalFrame:GetWide() * 0.45, TerminalFrame:GetTall() * 0.10)
    TerminalDownloadButton:SetVisible(false)
    -- Button to hack the terminal
    TerminalHackButton = vgui.Create("DButton", TerminalFrame)
    TerminalHackButton:SetText("Hack")
    TerminalHackButton:SetPos(TerminalFrame:GetWide() * 0.5, TerminalFrame:GetTall() * 0.95 - TerminalDownloadButton:GetTall())
    TerminalHackButton:SetSize(TerminalFrame:GetWide() * 0.45, TerminalFrame:GetTall() * 0.10)
    TerminalHackButton:SetVisible(false)

    TerminalHackButton.DoClick = function()
        startHack()
    end

    if consolePassword == "" then
        -- If there is no password, create one
        CreatePassword(console)
    else
        -- If there is a password, enter it
        EnterPassword(consolePassword)
    end

    -- When the text is changed, update the console text
    TerminalTextFrame.OnChange = function(self)
        ValidateLength(self, 20000)
        consoleText = self:GetValue()
    end

    -- When the terminal is closed, update the text variable
    TerminalFrame.OnClose = function(self)
        if consoleText ~= nil then
            UpdateConsoleText(console, consoleText)
        end
    end

    TerminalDownloadButton.DoClick = function()
        handTerminalText = consoleText
    end

    -- Change the elements to be visible for the settings
    TerminalSettingsButton.DoClick = function()
        ChangePassword(console)
    end

    -- Change the elements to be visible for the text
    TerminalTextButton.DoClick = function()
        SwitchBetweenDataAndSettingsScreen(false)
    end
end

function PasswordEnterScreen(visibleState)
    if visibleState == 1 then
        TerminalPassword:SetVisible(true)

        if LocalPlayer():HasWeapon("hand_hack_terminal") then
            TerminalHackButton:SetVisible(true)
        end
    elseif visibleState == 2 then
        TerminalPassword:SetVisible(false)
        TerminalHackButton:SetVisible(false)
    else
        -- Label for incorrect password
        TerminalPasswordError = vgui.Create("DLabel", TerminalFrame)
        TerminalPasswordError:SetPos(TerminalFrame:GetWide() / 2 - TerminalPasswordW / 2, TerminalFrame:GetTall() / 2 - TerminalPasswordH / 2 + TerminalPasswordH)
        TerminalPasswordError:SetSize(TerminalPasswordW, TerminalPasswordH)
        TerminalPasswordError:SetText("Incorrect Password")
        TerminalPasswordError:SetTextColor(Color(255, 0, 0))
        TerminalPasswordError:SetVisible(true)
        ImageFrame:SetImageColor(ColorRed)

        timer.Simple(1, function()
            TerminalPasswordError:Remove()
            ImageFrame:SetImageColor(ColorCyan)
        end)
    end
end

function MainScreen(visibleState)
    if visibleState then
        TerminalTextButton:SetVisible(true)
        TerminalSettingsButton:SetVisible(true)
        TerminalTextFrame:SetVisible(true)

        if LocalPlayer():HasWeapon("hand_terminal" or "hand_hack_terminal") then
            TerminalDownloadButton:SetVisible(true)
        end
    else
        TerminalTextButton:SetVisible(false)
        TerminalSettingsButton:SetVisible(false)
        TerminalTextFrame:SetVisible(false)
        TerminalDownloadButton:SetVisible(false)
    end
end

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
    HandText:SetText(handTerminalText or "")

    HandText.OnChange = function(self)
        ValidateLength(self, 20000)
        handTerminalText = self:GetText()
    end
end

net.Receive("SendConsole", function(len, ply)
    local consoleEntity = net.ReadEntity()
    local consoleText = net.ReadString()
    local consolePassword = net.ReadString()
    OpenConsoleTerminal(consoleEntity, consoleText, consolePassword)
end)