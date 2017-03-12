class "PlayerColor"

function PlayerColor:__init()
	-- Create SQL table to store colors
	SQL:Execute("CREATE TABLE IF NOT EXISTS player_color (steamid VARCHAR UNIQUE, r INTEGER, g INTEGER, b INTEGER)")
	-- (Your subscribing joke here)
	Network:Subscribe("ChangeColor", self, self.ChangeColor)
	Events:Subscribe("ClientModuleLoad", self, self.ClientModuleLoad)
	-- Reset colors
	-- SQL:Execute("DROP TABLE IF EXISTS player_color")
end

function PlayerColor:ChangeColor(args, sender) -- Called when player changes their color in the color picker
	local cmd = SQL:Command("INSERT OR REPLACE INTO player_color (steamid, r, g, b) values (?, ?, ?, ?)")
	cmd:Bind(1, sender:GetSteamId().id)
	cmd:Bind(2, args.r)
	cmd:Bind(3, args.g)
	cmd:Bind(4, args.b)
	cmd:Execute()
	sender:SetColor(args)
end

function PlayerColor:ClientModuleLoad(args) -- Fetches last known color, applys, and sends to player
	local query = SQL:Query("SELECT r, g, b FROM player_color WHERE steamid = ?")
	query:Bind(1, args.player:GetSteamId().id)
	local result = query:Execute()
	if #result > 0 then
		local r = tonumber(result[1].r)
		local g = tonumber(result[1].g)
		local b = tonumber(result[1].b)
		local color = Color(r, g, b)
		Network:Send(args.player, "FetchColor", color)
		args.player:SetColor(color)
	else
		local r = math.random(0, 255)
		local g = math.random(0, 255)
		local b = math.random(0, 255)
		Network:Send(args.player, "FetchColor", color)
		local color = Color(r, g, b)
		args.player:SetColor(color)
	end
end

local player_color = PlayerColor()