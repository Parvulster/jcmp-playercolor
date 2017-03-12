class "PlayerColor"

function PlayerColor:__init()
	-- Changes if window opens on load or not
	self.windowOpen = false
	-- Creates window
	self:CreateWindow()
	-- I hope you "like" this "comment" about "subscribing"
	-- I'm sorry for that "joke" about "YouTube"
	Network:Subscribe("FetchColor", self, self.FetchColor)
	Events:Subscribe("KeyUp", self, self.KeyUp)
	Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput)
	Events:Subscribe("ResolutionChange", self, self.ResolutionChange)
end
function PlayerColor:CreateWindow() -- Self Explanatory
	-- Create Main Window
	self.window = Window.Create()
	self.window:SetSize(Vector2(500, 300))
	self:ResolutionChange()
	self.window:SetTitle("Color Changer")
	self.window:SetVisible(self.windowOpen)
	self.window:Subscribe("WindowClosed", function() self:SetState(false) end)
	-- Create Color Picker
	self.colorpicker = HSVColorPicker.Create(self.window)
	self.colorpicker:SetDock(GwenPosition.Fill)
	-- Create Button
	self.button = Button.Create(self.window)
	self.button:SetDock(GwenPosition.Bottom)
	self.button:SetText("Apply")
	self.button:Subscribe("Press", function() self:ApplyColor() end)
end

function PlayerColor:ApplyColor() -- Fires when "Apply" button pressed, sends color to server in order to add to player
	self:SetState(false)
	local color = self.colorpicker:GetColor()
	Chat:Print("Color Updated", color)
	Network:Send("ChangeColor", color)
end

function PlayerColor:FetchColor(color) -- Loads last saved color
	self.colorpicker:SetColor(color)
end

function PlayerColor:SetState(state) -- Opens/Closes window
	self.windowOpen = state
	self.window:SetVisible(state)
	Mouse:SetVisible(state)
end

function PlayerColor:KeyUp(args) -- Check to see if F8 is pressed to open window
	if args.key == VirtualKey.F8 then
		local state = not self.windowOpen
		self:SetState(state)
	end
end

function PlayerColor:LocalPlayerInput() -- Disables input when window is open
	if self.windowOpen == true then return false end
end

function PlayerColor:ResolutionChange() -- Resizes window
	self.window:SetPositionRel(Vector2(0.5, 0.5) - self.window:GetSizeRel() / 2)
end

local player_color = PlayerColor() -- Calls class