net.Receive("TerminalText", function(len, ply)
    local entity = net.ReadEntity()
    local text = net.ReadString()

    local screenHeight = ScrH()
    local screenWidth = ScrW()

    local TerminalFrame = vgui.Create( "DFrame" )
    TerminalFrame:SetSize(screenWidth / 2, screenHeight / 2)
    TerminalFrame:Center()
    TerminalFrame:MakePopup()
    TerminalFrame:SetTitle("Terminal")

    local TerminalTextButton = vgui.Create("DButton", TerminalFrame)
    TerminalTextButton:SetText("Data")
    TerminalTextButton:SetPos(TerminalFrame:GetWide() * 0.05, TerminalFrame:GetTall() * 0.05)
    TerminalTextButton:SetSize(TerminalFrame:GetWide() * 0.45, TerminalFrame:GetTall() * 0.10)

    local TerminalSettingsButton = vgui.Create("DButton", TerminalFrame)
    TerminalSettingsButton:SetText("Settings")
    TerminalSettingsButton:SetPos(TerminalFrame:GetWide() * 0.5, TerminalFrame:GetTall() * 0.05)
    TerminalSettingsButton:SetSize(TerminalFrame:GetWide() * 0.45, TerminalFrame:GetTall() * 0.10)

    local TerminalText = vgui.Create( "DTextEntry", TerminalFrame )
    TerminalText:SetPos(TerminalFrame:GetWide() * 0.05, TerminalFrame:GetTall() * 0.15)
    TerminalText:SetSize(TerminalFrame:GetWide() * 0.90, TerminalFrame:GetTall() * 0.8)
    TerminalText:SetMultiline(true)
    TerminalText:SetUpdateOnType(true)
    TerminalText:SetText(text)
    TerminalText.OnChange = function(self)
        text = self:GetValue()
        net.Start("TerminalText")
        net.WriteEntity(entity)
        net.WriteString(text)
        net.SendToServer()
    end
end)
  