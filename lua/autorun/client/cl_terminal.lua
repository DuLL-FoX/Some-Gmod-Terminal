-- Color Presets
local ColorCyan = Color(4, 217, 255, 255)
local ColorRed = Color(255, 4, 4, 255)
-- Get the screen size
local screenHeight = ScrH()
local screenWidth = ScrW()
local handTerminalText = ""

local function SwitchVisibleElements(visible)
    TerminalTextFrame:SetVisible(visible)
    TerminalTextButton:SetVisible(visible)
    TerminalSettingsButton:SetVisible(visible)
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
    TerminalPasswordChange = vgui.Create("DLabel", TerminalFrame)
    TerminalPasswordChange:SetPos(TerminalFrame:GetWide() / 2 - TerminalPasswordW / 2, TerminalFrame:GetTall() / 2 - TerminalPasswordH / 2 + TerminalPasswordH)
    TerminalPasswordChange:SetSize(TerminalPasswordW, TerminalPasswordH)
    TerminalPasswordChange:SetText("Change Password")
    TerminalPasswordChange:SetTextColor(Color(0, 255, 0))
    TerminalPassword:SetVisible(true)

    TerminalPassword.OnChange = function(self)
        ValidateLength(self, 8)
    end

    TerminalPassword.OnEnter = function(self)
        local password = self:GetValue()
        UpdateConsolePassword(console, password)
        SwitchVisibleElements(true)

        if LocalPlayer():HasWeapon("hand_terminal") then
            TerminalDownloadButton:SetVisible(true)
        end

        TerminalPassword:SetVisible(false)
        TerminalPasswordChange:SetVisible(false)
    end
end

local function CreatePassword(console)
    local TerminalPasswordCreate = vgui.Create("DLabel", TerminalFrame)
    TerminalPasswordCreate:SetPos(TerminalFrame:GetWide() / 2 - TerminalPasswordW / 2, TerminalFrame:GetTall() / 2 - TerminalPasswordH / 2 + TerminalPasswordH)
    TerminalPasswordCreate:SetSize(TerminalPasswordW, TerminalPasswordH)
    TerminalPasswordCreate:SetText("Create Password")
    TerminalPasswordCreate:SetTextColor(Color(0, 255, 0))

    TerminalPassword.OnChange = function(self)
        ValidateLength(self, 8)
    end

    TerminalPassword.OnEnter = function(self)
        local password = self:GetValue()
        UpdateConsolePassword(console, password)
        SwitchVisibleElements(true)

        if LocalPlayer():HasWeapon("hand_terminal") then
            TerminalDownloadButton:SetVisible(true)
        end

        TerminalPasswordCreate:Remove()
        TerminalPassword:SetVisible(false)
    end
end

local function EnterPassword(password)
    TerminalPassword.OnChange = function(self)
        ValidateLength(self, 8)
    end

    TerminalPassword.OnEnter = function(self)
        -- If the password is correct, display the text
        if self:GetValue() == password then
            SwitchVisibleElements(true)

            if LocalPlayer():HasWeapon("hand_terminal") then
                TerminalDownloadButton:SetVisible(true)
            end

            self:SetVisible(false)
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
  TerminalTextFrame = vgui.Create("DTextEntry", TerminalFrame)
  TerminalTextFrame:SetPos(TerminalFrame:GetWide() * 0.05, TerminalFrame:GetTall() * 0.15)
  TerminalTextFrame:SetSize(TerminalFrame:GetWide() * 0.90, TerminalFrame:GetTall() * 0.8)
  TerminalTextFrame:SetMultiline(true)
  TerminalTextFrame:SetUpdateOnType(true)
  TerminalTextFrame:SetText(consoleText)
  -- Button to download the text to the hand terminal
  TerminalDownloadButton = vgui.Create("DButton", TerminalFrame)
  TerminalDownloadButton:SetText("Download")
  TerminalDownloadButton:SetPos(TerminalFrame:GetWide() * 0.05, TerminalFrame:GetTall() * 0.95 - TerminalDownloadButton:GetTall())
  TerminalDownloadButton:SetSize(TerminalFrame:GetWide() * 0.45, TerminalFrame:GetTall() * 0.10)
  --Invisible until the correct password is entered
  TerminalDownloadButton:SetVisible(false)
  SwitchVisibleElements(false)
  -- Text entry box for password
  TerminalPassword = vgui.Create("DTextEntry", TerminalFrame)
  TerminalPasswordW = TerminalFrame:GetWide() * 0.1
  TerminalPasswordH = TerminalFrame:GetTall() * 0.05
  TerminalPassword:SetPos(TerminalFrame:GetWide() / 2 - TerminalPasswordW / 2, TerminalFrame:GetTall() / 2 - TerminalPasswordH / 2)
  TerminalPassword:SetSize(TerminalPasswordW, TerminalPasswordH)

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
      TerminalTextFrame:SetVisible(false)
      TerminalDownloadButton:SetVisible(false)
      ChangePassword(console)
  end

  -- Change the elements to be visible for the text
  TerminalTextButton.DoClick = function()
      if TerminalPasswordChange.IsVisible then
          TerminalPasswordChange:SetVisible(false)
          TerminalPassword:SetVisible(false)
      end

      TerminalTextFrame:SetVisible(true)
      TerminalDownloadButton:SetVisible(true)
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
  HandText:SetText(handTerminalText)

  HandText.OnChange = function(self)
      ValidateLength(self, 20000)
      handTerminalText = inputText
  end
end

net.Receive("SendConsole", function(len, ply)
    local consoleEntity = net.ReadEntity()
    local consoleText = net.ReadString()
    local consolePassword = net.ReadString()
    OpenConsoleTerminal(consoleEntity, consoleText, consolePassword)
end)

-- Initialize the numbers
numbers = {1, 2, 3, 4, 5}

-- Create the rows with numbers
function createRows()
    rows = {}

    for i = 1, #numbers do
        row = {}

        for j = 1, 10 do
            table.insert(row, math.random(100))
        end

        table.insert(row, numbers[i])
        table.insert(rows, row)
    end
end

-- Move the rows down
function moveRows()
    for i = 1, #rows do
        for j = 1, #rows[i] - 1 do
            rows[i][j] = rows[i][j + 1]
        end

        if i < currentRow then
            rows[i][#rows[i]] = rows[i][#rows[i]]
        else
            rows[i][#rows[i]] = math.random(50)
        end
    end
end

-- Draw the rows on the screen
function drawRows()
    for i = 1, #rows do
        rowString = ""

        for j = 1, #rows[i] do
            if rows[i][j] == currentNumber then
                rowString = rowString .. " " .. string.format("%02d", rows[i][j])
            else
                rowString = rowString .. " " .. string.format("%02d", rows[i][j])
            end
        end

        if i == currentRow then
            draw.SimpleText(rowString, "Default", ScrW() / 2, i * 20, Color(255, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
            draw.SimpleText(rowString, "Default", ScrW() / 2, i * 20, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
end

-- Catch the specified number
function catchNumber()
    if rows[currentRow][#rows[currentRow]] == currentNumber then
        -- You caught the number!
        -- print("You caught number " .. currentNumber .. "!")
        if #numbers == 0 then
            -- All numbers have been caught
            print("You caught all numbers!")
            hook.Remove("HUDPaint", "DrawRows")
            hook.Remove("Think", "MoveRows")
            hook.Remove("Think", "CatchNumber")
        else
            currentRow = currentRow % #rows + 1
            currentNumber = numbers[currentRow]
        end
    end
end

-- Main loop
speed = 0.1
currentRow = 1
currentNumber = numbers[1]
lastMoveTime = 0
createRows()

hook.Add("HUDPaint", "DrawRows", function()
    drawRows()
end)

hook.Add("Think", "MoveRows", function()
    if (CurTime() - lastMoveTime) > speed then
        moveRows()
        lastMoveTime = CurTime()
    end
end)

hook.Add("Think", "CatchNumber", function()
    if input.IsKeyDown(KEY_SPACE) then
        catchNumber()
    end

    catchNumber()
end)