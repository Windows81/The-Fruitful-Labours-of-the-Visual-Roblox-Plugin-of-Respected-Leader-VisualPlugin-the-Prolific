local collS=game:service'CollectionService'
local tagFName='RLVP_Tags'
local mpSuffix='-main'

--Prepares the storage folder before anything else could be done.
local wF spawn(function()wF=collS:WaitForChild(tagFName,1/2)end)

--Mechanism for storing the names of saved tags.
local tF function tagFolder()
	
	--Returns value if cached.
	if tF then return tF end
	
	--Checks the storage folder.
	if wF then return wF end
	
	local f=Instance.new'Folder'
	f.Name,f.Parent=tagFName,collS
	tF=f return tF
end

--Mechanism for generating tag names.
local hashT={}function hash(...)
	
	--Generates random string.
	local sT={}for i=1,10 do
	local r=math.random(65,90)
	sT[i]=string.char(r)end
	return table.concat(sT)
end

return{
	tagGroup=function(group)
		
		--Repeats until a unique tag is produced, then caches it.
		local h repeat h=hash(group)until not hashT[h]hashT[h]=true
		
		--Adds all of the group's parts to that hashed tag.
		for i,gp in next,group.parts do collS:AddTag(gp,h)end
		
		--Special tag name for the main part.
		collS:AddTag(group.main,h..mpSuffix)
		
		--Saves in group object.
		group.tag=h
		
		--Saves in the Studio hierarchy.
		local o=Instance.new'Configuration'
		o.Name,o.Parent=h,tagFolder()
	end,
	removeTagged=function(group)
		local h=group.tag
		
		--Removes cached object.
		local o=tagFolder():findFirstChild(h)
		o:destroy()
		
		--Removes all traces of that tag from the parts.
		local t=game.CollectionService:GetTagged(h)
		for i,gp in next,t do collS:RemoveTag(gp,h)end
	end,
}