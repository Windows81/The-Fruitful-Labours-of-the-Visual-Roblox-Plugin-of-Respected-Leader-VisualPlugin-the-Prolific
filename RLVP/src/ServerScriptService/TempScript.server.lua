--In order for this script to work, Accessible Plugins has to be installed.
if game['Run Service']:IsRunning()then wait(1)
	if not pcall(function()game.StarterGui:FindFirstChildWhichIsA'LuaSourceContainer'.Parent=game.TestService.LocalPlugins game.workspace.Message:destroy()
	end)then error'In order to test this plugin, you need to install Accessible Plugins (https://www.roblox.com/library/2677057405) on Studio.'end
end