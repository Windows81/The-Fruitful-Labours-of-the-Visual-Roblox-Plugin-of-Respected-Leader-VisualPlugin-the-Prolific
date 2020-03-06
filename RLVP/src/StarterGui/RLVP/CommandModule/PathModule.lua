function parseComponents(path)
	local comps,index,esc1,esc2={''},1,0,0
	for i in string.gmatch(path,'.')do
		
		if i=='['and esc2<1 then
			esc1=esc1+1
			index=index+1
			comps[index]=''
			
		elseif i==']'and esc2<1 then esc1=esc1-1
		elseif i=='"'and esc2<2 then esc2=1-esc2
		elseif i=='\''then esc2=2
			
		elseif esc1==0 and esc2==0 and i=='.'then
			index=index+1
			comps[index]=''
		else
			comps[index]=comps[index]..i
		end
	end
	return comps
end

function getPartsRec(t,obj,comps,single,cn)
	if cn>#comps then t[#t+1]=obj return end
	local comp=comps[cn]
	
	if comp:find'[%*%?%[%]%(%)%^%$%%]'then
		for i,p in next,obj:children()do
			local succ,valid=pcall(function()
			return p.Name:find(comp)end)
			
			if succ and valid then
				getPartsRec(t,p,comps,single,cn+1)
				if single then return end
			end
		end
		
	elseif single then
		local part=obj:findFirstChild(comp)
		getPartsRec(t,part,comps,single,cn+1)
		
	else
		for i,p in next,obj:children()do
			local succ,valid=pcall(function()
			return p.Name==comp end)
			
			if succ and valid then
				getPartsRec(t,p,comps,single,cn+1)
				if single then return end
			end
		end
	end
end

function getParts(comps,single)
	local items={}
	getPartsRec(items,game,comps,single,2)
	return single and items[1]or items
end

return{
	parse=function(path)
		local comps=parseComponents(path)
		local parts=getParts(comps)
		return parts
	end,
}