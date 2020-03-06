local main=script.Parent
local srts=require(main.ShortcutModule)
local stacks={activeTick1={},activeTick2={},}

function func(i,...)
	local t=stacks[i]
	if#t>0 then t[#t](...)end
end

for i in next,stacks do
	srts.bind(i,func)
end

return{
	bind=function(i,f)
		local t=stacks[i]
		t[#t+1]=f
	end,
	unbind=function(i)
		local t=stacks[i]
		t[#t]=nil
	end,
}