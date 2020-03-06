local main=script.Parent.Parent
local mode=require(main.ModeModule)
local config=require(main.ConfigModule)
local enumC=require(main.EnumConfigSubModule)

--Obligatory callback structure (named 'bind' internally).
local binds={}function bind(i,f)binds[i]=f end

--Collects all config-page GUI modules.
local moduleT={}for i,n in next,enumC do
moduleT[n]=require(script.Parent[n])end

local pageT,pNameT,labelT,configT={},{},{},{}
local subNum,subCount=1,0 function init(cGui)
	
	local fr=cGui.Frame
	local textB=script.TextButton
	local selFr=fr.Selection
	local window=fr.Window
	
	--Retrieves a reference of the configs.
	configT=config.currCache()
	
	for n,mod in next,moduleT do
		local subIndex=subCount+1
		subCount=subCount+1
		local o=window[n]
		
		--Creates the labels and binds each one to mouse-based events.
		local l=textB:clone()l.Activated:connect(function()mode.set(nil,subIndex)end)
		l.MouseEnter:connect(function()l.TextTransparency=subCount==subNum and 0 or.25 end)
		l.MouseLeave:connect(function()l.TextTransparency=subCount==subNum and 0 or.5 end)
		pageT[subCount],pNameT[subCount],labelT[subCount]=o,n,l
		l.Text,l.Parent=n:upper(),selFr
		mod.init(o)
	end
end

--Called upon setting of mode.
function modeFwd(currM)subNum=currM[2]
	
	--Updates GUI elements.
	for i,l in next,labelT do
		l.TextTransparency=i
		==subNum and 0 or.5
	end
	
	--Shows the appropriate sub-page; hides the rest.
	for i=1,subCount do pageT[i].Visible=i==subNum end
	
	--Calls the page's specific method.
	local n=pNameT[subNum]
	moduleT[n].show(n,configT)
end

--Forwards updates to the pages.
function configFwd(...)
	local count=0 for i,m in next,moduleT do
		count=count+1 if m.config then
			m.config(pNameT[count],...)
		end
	end
end

--Called when shortcuts get changed.
function shortcutsFwd(fKeys)
	for i,l in next,labelT do
		l.TextLabel.Text=fKeys[tostring(i)]
	end
	
	--Forwards changes to the pages.
	local count=0 for i,m in next,moduleT do
		count=count+1 if m.shortcuts then
			m.shortcuts(pNameT[count],fKeys)
		end
	end
end

return{
	init=init,
	callback=bind,
	getSubs=function()
	return pNameT end,
	shortcuts=shortcutsFwd,
	config=configFwd,
	mode=modeFwd,
}