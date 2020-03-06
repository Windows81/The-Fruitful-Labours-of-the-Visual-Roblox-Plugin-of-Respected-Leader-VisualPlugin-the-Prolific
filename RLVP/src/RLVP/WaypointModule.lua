require(script.Parent.DebugModule)()
local chs=game.ChangeHistoryService
return{
	set=function(...)
		chs:SetWaypoint(...)
		warn('Waypoint set:',...)
	end,
	reset=function()
		chs:ResetWaypoints()
		warn('Waypoint reset.')
	end,
	onUndo=chs.OnUndo,
	onRedo=chs.OnRedo,
	nextWp=function(...)chs:GetCanRedo()end,
	prevWp=function(...)chs:GetCanUndo()end,
}