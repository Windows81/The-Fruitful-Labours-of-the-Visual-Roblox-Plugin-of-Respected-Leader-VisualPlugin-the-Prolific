local main=script.Parent
local mode=require(main.ModeModule)
local mouse=require(main.MouseModule)
local sel=require(main.SelectionModule)

function validMode(m)
	return mode.get()[1]~='config'
end

function execL(m)
	local t=m.Target
	if not validMode()or not t then return end
	if not sel.remove(t)then sel.add(t)end
end

function execR(m)
	local t=m.Target
	if not t then return end
	sel.shift(t)
end

mouse.bind(0,execL,execR)
return{
	executeL=execL,
	executeR=execR,	
}