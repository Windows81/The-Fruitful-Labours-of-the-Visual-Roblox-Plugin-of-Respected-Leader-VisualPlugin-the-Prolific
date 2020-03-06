local main=script.Parent
local plugin=main.Plugin.Value
local defaults=require(main.EnumConfigModule)
local util=require(main.EnumConfigModule.util)
local tempCache,permCache,currCache={},{},{}
local bindEchT,bindAllT,allSaved={},{},true

function loadKey(i)
	return plugin:GetSetting(i)
	or defaults[i].value
end

--Loads each listed setting to cache.
for i,t in next,defaults do
	local v=loadKey(i)
	currCache[i]=v
	permCache[i]=v
end

--Responsible for callbacks.
function send(dict,isTemp)
	
	--Calls the 'each' binds.
	for i,v in next,dict do
		local f=bindEchT[i]
		if f then f(v,false)end
	end
		
	--Calls the 'all' binds.
	for i,f in next,bindAllT do
	f(dict,currCache,isTemp,allSaved)end
end

--Algorithms from various modes of selection.
local algorChT={value=true,check=util.isBool}
local chT=require(main.AlgorChooserModule).getChoices()
for i,algor in next,chT do defaults[i],defaults[i..'_prompt']=algorChT,algorChT end

return{
	setPerm=function(i,v)
		if defaults[i].check(v)
		then else return end
		
		currCache[i]=v
		permCache[i]=v
		tempCache[i]=nil
		allSaved=not next(tempCache)
		send({[i]=v},false,allSaved)
		plugin:SetSetting(i,v)
	return true end,
	
	setTemp=function(i,v)
		if defaults[i].check(v)
		then else return end
		
		currCache[i]=v
		tempCache[i]=v
		allSaved=false
		send({[i]=v},true)
	return true end,
	
	get=function(i)
		if tempCache[i]~=nil then return tempCache[i]
		elseif permCache[i]~=nil then return permCache[i]
		else return loadKey(i)end
	end,
	
	getDefault=function(i)return defaults[i]end,
	currCache=function()return currCache end,
	permCache=function()return permCache end,
	tempCache=function()return tempCache end,
		
	isTemp=function(i)
		return not not
		tempCache[i]
	end,
	
	saveToPerm=function()if allSaved
		then return end allSaved=true
		print'Saving configuration to permanent storage.'
		
		--Don't affect tempCache yet.
		for i,v in next,tempCache do
			plugin:SetSetting(i,v)
			bindEchT[i](v,true)
			permCache[i]=v
			currCache[i]=v
		end
		
		--Calls the 'all' binds; tempCache should still have its items.
		for i,f in next,bindAllT do f(tempCache,currCache,false,allSaved)end
		
		--Prevents memory leaks.
		for i in next,tempCache
		do tempCache[i]=nil end
	end,
	
	--Binds function to each setting-change.
	bindIndv=function(i,f)bindEchT[i]=f end,
	
	--Binds function to any setting-change.
	bindAll=function(f)bindAllT[#bindAllT+1]=f end,
}