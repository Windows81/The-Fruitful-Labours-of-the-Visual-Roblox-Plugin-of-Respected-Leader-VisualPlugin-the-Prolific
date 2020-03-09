--Why this weird setup?  Blame Accessible Plugins.
local t={Start=function(plugin)

--Sneaky hack to disable RLVP when in edit mode (exclusive to RLVP.rbxlx).
if game.Workspace.DistributedGameTime==-127 then script:destroy()return end

script.Plugin.Value=plugin
while not script.Plugin
.Value do wait(1/2)end

require(script.SetupModule)
require(script.SelectionEventModule)
require(script.ActiveModule)
require(script.HandleModule)
require(script.ModeBindModule)
require(script.ConfigGuiModule)
require(script.GuiElemModule)
require(script.CommandModule)

end}
plugin=plugin
if plugin then
t.Start(plugin)
end

return t