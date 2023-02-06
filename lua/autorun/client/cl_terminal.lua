net.Receive("TerminalText", function(len, ply)
    -- Get the entity and text and password
    local entity = net.ReadEntity()
    local text = net.ReadString()
    local password = net.ReadString()

    -- Get the screen size
    local screenHeight = ScrH()
    local screenWidth = ScrW()
	
	-- Color Presets
	local ColorCyan = Color(4, 217, 255, 255)
	local ColorRed = Color(255, 4, 4, 255)

    -- Create the terminal frame
    local TerminalFrame = vgui.Create( "DFrame" )
    TerminalFrame:SetSize(screenWidth / 2, screenHeight / 2)
    TerminalFrame:Center()
    TerminalFrame:MakePopup()
    TerminalFrame:SetTitle("Terminal")
	TerminalFrame.Paint = function(self, w, h)
		surface.SetDrawColor(0, 0, 0, 200)
	end
	
	-- Image of frame
	local ImageFrame = vgui.Create("DImage", TerminalFrame)
	ImageFrame:SetSize(TerminalFrame:GetSize())		
	ImageFrame:SetImage("materials/vgui/frame.png")
	ImageFrame:SetImageColor(ColorCyan)

    -- Text button
    local TerminalTextButton = vgui.Create("DButton", TerminalFrame)
    TerminalTextButton:SetText("Data")
    TerminalTextButton:SetPos(TerminalFrame:GetWide() * 0.05, TerminalFrame:GetTall() * 0.05)
    TerminalTextButton:SetSize(TerminalFrame:GetWide() * 0.45, TerminalFrame:GetTall() * 0.10)

    -- Settings button
    local TerminalSettingsButton = vgui.Create("DButton", TerminalFrame)
    TerminalSettingsButton:SetText("Settings")
    TerminalSettingsButton:SetPos(TerminalFrame:GetWide() * 0.5, TerminalFrame:GetTall() * 0.05)
    TerminalSettingsButton:SetSize(TerminalFrame:GetWide() * 0.45, TerminalFrame:GetTall() * 0.10)

    -- Text entry box
    local TerminalText = vgui.Create( "DTextEntry", TerminalFrame )
    TerminalText:SetPos(TerminalFrame:GetWide() * 0.05, TerminalFrame:GetTall() * 0.15)
    TerminalText:SetSize(TerminalFrame:GetWide() * 0.90, TerminalFrame:GetTall() * 0.8)
    TerminalText:SetMultiline(true)
    TerminalText:SetUpdateOnType(true)
    TerminalText:SetText(text)

    --Invisible until the correct password is entered
    TerminalText:SetVisible(false)
    TerminalTextButton:SetVisible(false)
    TerminalSettingsButton:SetVisible(false)

    -- When the text button is pressed, display the text
    local TerminalPassword = vgui.Create( "DTextEntry", TerminalFrame )
    TerminalPasswordW = TerminalFrame:GetWide() * 0.1
    TerminalPasswordH = TerminalFrame:GetTall() * 0.05
    TerminalPassword:SetPos(TerminalFrame:GetWide() / 2 - TerminalPasswordW / 2, TerminalFrame:GetTall() / 2 - TerminalPasswordH / 2)
    TerminalPassword:SetSize(TerminalPasswordW, TerminalPasswordH)

    -- If there is no password, create one
    if password == "" then
        local TerminalPasswordCreate = vgui.Create("DLabel", TerminalFrame)
        TerminalPasswordCreate:SetPos(TerminalFrame:GetWide() / 2 - TerminalPasswordW / 2, TerminalFrame:GetTall() / 2 - TerminalPasswordH / 2 + TerminalPasswordH)
        TerminalPasswordCreate:SetSize(TerminalPasswordW, TerminalPasswordH)
        TerminalPasswordCreate:SetText("Create Password")
        TerminalPasswordCreate:SetTextColor(Color(0, 255, 0))
        TerminalPassword.OnEnter = function(self)
            password = self:GetValue()
            net.Start("TerminalPassword")
            net.WriteEntity(entity)
            net.WriteString(password)
            net.SendToServer()
            TerminalText:SetVisible(true)
            TerminalTextButton:SetVisible(true)
            TerminalSettingsButton:SetVisible(true)
            self:SetVisible(false)
            TerminalPasswordCreate:Remove()
        end

    -- If there is a password, enter it
    else
        TerminalPassword.OnEnter = function(self)
            -- If the password is correct, display the text
            if self:GetValue() == password then
                TerminalText:SetVisible(true)
                TerminalTextButton:SetVisible(true)
                TerminalSettingsButton:SetVisible(true)
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

    -- When the text is changed, send it to the server
    TerminalText.OnChange = function(self)
        text = self:GetValue()
        net.Start("TerminalText")
        net.WriteEntity(entity)
        net.WriteString(text)
        net.SendToServer()
    end
end)
  