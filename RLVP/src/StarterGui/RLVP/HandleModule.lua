local main=script.Parent
local tool=require(main.ToolModule)
local ogMod=require(main.OriginModule)
local incr=require(main.IncrementModule)
local sel=require(main.SelectionModule)
local mouse=require(main.MouseModule)
local actv=require(main.ActiveModule)
local gui=require(main.GuiElemModule)
local mode=require(main.ModeModule)
local cgui=game.CoreGui
local currH,currP,currN
local cMode,mBind
local binds={}
local adornee
local specOrig
local isPrev

local incrT={
	move='lat',
	resize='lat',
	rotate='rot',
}

local magn=0
local locked
local parts={}

function dn()magn=0
	if locked then return end
	locked=true parts=sel.get()
	tool.set(cMode)
	locked=false
end

function up()
	if locked then return end
	locked=true
	tool.unset()
	locked=false
end

function drag(which,m)
	m=incr.calc(incrT[currN],m)
	if magn==m then return end
	gui.action('value','display',m)
	tool.exec(which,m-magn)magn=m
end

function lockM()return mouse.bind(127)end
function unlockM()return mouse.unbind(127)end

--Procedure for changing the mode.
function setHMode(argM,tempM)
	
	--Ensures tool is deactivated.
	up()
	
	--Hides the old handle.
	if currH then
		currH.Parent=script
		adorn(nil)currN=nil
	end
	
	--Removes the old handle's binds.
	if binds then
		for i=#binds,1,-1 do
			if binds[i] then
				binds[i]:disconnect()
				binds[i]=nil
			end
		end
	end
	
	--Sets the global mode variables.
	cMode=tempM or argM or cMode
	mBind=tool.getBind(cMode)
	
	--Searches for and sets a new handle-set.
	local h=script:findFirstChild(cMode[1])
	currH=h if not h then return end
	currN=h.Name
	
	if not tempM then magn=0
		
		--Processes the selection's origin for the given mode.
		if not isPrev then specOrig=ogMod.process(currP,mBind.origin)end
		
		adorn(specOrig or currP)
		h.Parent=cgui
		
		--Connects functions to each handle event.
		binds[1]=h.MouseDrag:connect(drag)
		binds[2]=h.MouseButton1Down:connect(dn)
		binds[3]=h.MouseButton1Up:connect(up)
		--binds[4]=h.MouseEnter:connect(lockM)
		--binds[5]=h.MouseLeave:connect(unlockM)
	end
	
	--Stores for next pass.
	isPrev=not not tempM
end

--Binds to mode change.
mode.bind(setHMode)

--Binds to selection change.
sel.bind(function(parts)
	
	--Sets the adornee if processing event.
	if locked then setPart(parts[1])
	
	--Otherwise, prevents memory leaks.
	else up()setPart(parts[1])end
end)

--Change handles' adornee.
function adorn(a)
	
	--Sets adornee to argument.
	adornee,currH.Adornee=a,a
end

--Wrapper-function for adorning parts.
function setPart(p)currP=p
	
	--Supresses the function call if deactivated.
	if not actv.isActive()then return end
	
	--Sets handle mode if not yet configured.
	if not cMode then setHMode(mode.get())
	
	--Otherwise, manually processes the origin from its config.
	elseif currH then specOrig=ogMod.process(currP,mBind.origin)
		
		--Adorns the new origin or the selected part.
		adorn(specOrig or p)
	end
end

--Automatically shows when plugin is activated and hides when deactivated.
actv.bind(function(a)if currH then adorn(a and currP or nil)end end)

return{
	setHandleMode=setHMode,
	getCFrame=function()
		return adornee.CFrame
	end,
	setPart=setPart,
}