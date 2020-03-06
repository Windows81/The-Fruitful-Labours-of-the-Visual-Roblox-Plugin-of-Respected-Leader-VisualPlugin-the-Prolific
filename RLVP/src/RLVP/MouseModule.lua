local main=script.Parent
local actv=require(main.ActiveModule)
local mouse=main.Plugin.Value:GetMouse()
local binds,locked,prK,active={},0,nil,nil

function bind(pr,...)
	if not prK or pr>prK then
	prK=pr end binds[pr]={...}
end

function unbind(pr)
	binds[pr],prK=nil,nil
	for i in next,binds do
	if not prK or i>prK then
	prK=i end end
end

--Calls only the binds with the highest priority.
mouse.Button1Down:connect(function()
	local t=binds[prK]
	if 1>locked and active
	and t and'function'==typeof(t[1])
	then t[1](mouse)end
end)
mouse.Button2Down:connect(function()
	local t=binds[prK]
	if 1>locked and active
	and t and'function'==typeof(t[2])
	then t[2](mouse)end
end)

actv.bind(function(
b)active=b end)

return{
	bind=bind,
	mouse=mouse,
	unbind=unbind,
	lock=function()locked=locked+1 end,
	unlock=function()locked=locked-1 end,
	
	--Returns the position of the mouse cast into a Vector2.
	position=function()return Vector2.new(mouse.X,mouse.Y)end,
}