local main=script.Parent
local svB=require(script.SaveButtonModule)
local enumM=require(main.EnumModeModule)
local spM=require(script.SubpageModule)
local config=require(main.ConfigModule)
local srts=require(main.ShortcutModule)
local gui=require(main.GuiMainModule)
local mouse=require(main.MouseModule)
local mode=require(main.ModeModule)
local cGui=gui.get'config'
local frame=cGui.Frame

function send(name,...)
	spM[name](...)
	svB[name](...)
end

--Obligatory callback implementation; transfers to sub-modules.
local callbackT={}function bindCB(i,f)spM.callback(i,f)callbackT[i]=f end

--Visibility functions.
local shown=2
function hide()
	if shown==0 then
	return end shown=0
	cGui.Visible,frame.
	Visible=false,false
	mouse.unlock()
end
function ovly()
	if shown==1 then
	return end shown=1
	cGui.Visible,frame.
	Visible=true,false
end
function show()
	if shown==2 then
	return end shown=2
	cGui.Visible,frame
	.Visible=true,true
	mouse.lock()
end

--Function for the mode-change event, stores previous mode.
local prevM mode.bind(function(currM,tempM)
	
	--Set to last used mode other than 'config'.
	if'config'~=currM[1]then prevM=currM end
	
	--Determines which state the GUI should be set to.
	if tempM and('config'==tempM[1])~=('config'==currM[1])then ovly()
	elseif'config'~=currM[1]then hide()else show()spM.mode(currM)end
end)

--Initialises GUI in external functions.
send('init',cGui)gui.add(cGui)hide()

--Config modification event.
config.bindAll(function(
...)send('config',...)end)

--Shortcut modification event.
srts.bindSet(function(...)
	send('shortcuts',...)
	
	--Transposes each of the modes onto the close button.
	local b,s=nil,''for i,m in next,enumM do if m[1]~='config'
	then s,b=s..(b and', 'or'')..srts.get(m[1]),true end end
	frame.Close.TextLabel.Text=s
end,true)

--Binds to the close button; previous mode set.
frame.Close.Activated:connect(function()mode.set(prevM)end)

return{
	overlay=ovly,
	callback=bindCB,
	show=show,hide=hide,
	getSubs=spM.getSubs,
	isShown=function()
	return shown==2 end,
}