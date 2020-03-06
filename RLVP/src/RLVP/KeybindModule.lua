local uis=game:service'UserInputService'
local binds,shft,prK={},false,nil

function bind(pr,f)
	if not prK or pr>prK then
	prK=pr end binds[pr]=f
end

function unbind(pr)
	binds[pr],prK=nil,nil
	for i in next,binds do
	if not prK or i>prK then
	prK=i end end
end

uis.InputBegan:connect(function(input)
	if input.UserInputType==Enum.UserInputType.Keyboard then
		if input.KeyCode.Name:find'Shift$'then shft=true
		else binds[prK](shft,input.KeyCode)end
	end
end)

uis.InputEnded:connect(function(input)
	if input.UserInputType==Enum.UserInputType.Keyboard then
	if input.KeyCode.Name:find'Shift$'then shft=false end end
end)

return{
	bind=bind,
	unbind=unbind,
}