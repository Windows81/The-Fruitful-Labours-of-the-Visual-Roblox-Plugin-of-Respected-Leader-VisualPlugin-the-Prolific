local main=script.Parent
local path=require(script.PathModule)
local sel=require(main.SelectionModule)

function process(input)
	local command=select(3,input:find'^(%w+)'):lower()
	
	local components={}
	for key,arg in string.gmatch(input,'%-(%w) ([^-]+)')do
		components[key:lower()]=arg end
	for key,arg in string.gmatch(input,'%-%-(%w+) ([^-]+)')do
		components[key:lower()]=arg end
	
	if command=='lp'then
		local items=path.parse(components.path)
		for i,item in next,items do
			print(item:GetFullName())
		end
		
	elseif command=='as'then
		local items=path.parse(components.path)
		for i,item in next,items do
			sel.add(item)
		end
		sel.update()
		
	elseif command=='rs'then
		local items=path.parse(components.path)
		for i,item in next,items do
			sel.remove(item)
		end
		sel.update()
	end
end

_G.RLVP=process
return process