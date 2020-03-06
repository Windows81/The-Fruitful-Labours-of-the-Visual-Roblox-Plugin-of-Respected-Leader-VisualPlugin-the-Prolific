local main=script.Parent
local enumM=require(main.EnumModeModule)
local drpd=require(main.DropdownModule)
local srts=require(main.ShortcutModule)
local mode=require(main.ModeModule)
local locked=0

function bind(v)
	if locked>0 then return end
	mode.set(v)
end

--Directly alters sub-mode.
function subBind(v)
	if locked>0 then return end
	local currList=drpd.get()
	
	--Overrides the keybind in the event a dropdown is showing.
	if currList then if currList[0+v] then drpd.exec(currList[0+v])end
	
	--Sets the submode using numerical index.
	else mode.set(nil,mode.getSubs()[0+v])end
end

--Binds to named shortcut; as defined elsewhere.
for i,k in next,enumM do srts.bind(k[1],bind)end

--Binds to numbered shortcuts.
for i=0,9 do srts.bind(''..i,subBind)end

return{
	lock=function()locked=locked+1 end,
	unlock=function()locked=locked-1 end,
}