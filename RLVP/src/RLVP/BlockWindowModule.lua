local main=script.Parent
local gui=require(main.GuiMainModule)
local actv=require(main.ActiveModule)
local mode=require(main.ModeModule)

local bl=gui.get'block'
local fr=bl.Frame
bl.Visible=true
bl.Parent=nil
local shown

function show(s,w)
	fr.Size=UDim2.fromOffset(w or 300,50)
	fr.TextLabel.Text=s:upper()
	if shown then return end
	shown=true mode.lock()
	actv.lock()gui.add(bl)
end
function hide()
	if not shown then return end
	mode.unlock()actv.unlock()
	gui.remove(bl)shown=false
end

return{
	show=show,
	hide=hide,
}