local main=script.Parent.Parent
local config=require(main.ConfigModule)
local gui=require(main.GuiMainModule)
local saveB,saveState

function getTrans(s,a)
	return s and .75
	or(a and 0 or.5)
end

return{
	init=function(cGui)
		saveB=cGui.Frame.Selection.SaveButton
		saveB.MouseEnter:connect(function()
			saveB.TextTransparency=getTrans(saveState,true)
			saveB.InfoHover.Screentip.Visible=not saveState end)
		saveB.MouseLeave:connect(function()
			saveB.TextTransparency=getTrans(saveState,false)
			saveB.InfoHover.Screentip.Visible=false end)
		saveB.MouseButton1Click:connect(config.saveToPerm)
		saveB.TextTransparency=getTrans(saveState)
		return saveB
	end,
	config=function(_,_,_,allSaved)
		saveB.TextTransparency=getTrans(allSaved)
		saveB.Active=false
		saveState=allSaved
	end,
	shortcuts=function(fKeys)
		--saveB.TextLabel.Text=fKeys.activeTick1
	end,
}