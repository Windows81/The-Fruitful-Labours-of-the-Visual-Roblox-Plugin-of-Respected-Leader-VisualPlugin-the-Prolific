local main=script.Parent
local sel=require(main.SelectionModule)
local subMd=require(main.SubmodeModule)
local ogMod=require(main.OriginModule)
local wpm=require(main.WaypointModule)

--Modifies global environment.
require(main.DebugModule)()

local bind,tagT
local binds=subMd.binds()
function modeHash(modeT)
	if not modeT then return''end
	return modeT[1]..'_'..modeT[2]
end

function set(modeT)
	if tagT then return end
	local hash=modeHash(modeT)
	warn'Tool set.'
	bind=binds[hash]
	tagT={}
	
	local repT={}
	local s=sel.get()
	local o=ogMod.get()
	for i,p in next,s do
		
		local nP,par=p,p.Parent
		local tags={tagged=false,mode=modeT}
		if bind and bind.input then
			nP,tags=bind.input(p)
			tags.tagged=true
		end
		
		tags.origin=o
		tagT[nP]=tags
		
		--If the part is altered.
		if p~=nP then
			nP.Parent=par
			p:destroy()
			repT[p]=nP
			
			--If the altered part happened to be an origin.
			if o==p then tags.origin=nP o=nP end
		end
	end
	
	tagT[o]=tagT[o]or{
	origin=o,tagged=false}
	tagT[o].isOrigin=true
	
	--Procrastinated call for efficient looping.
	sel.replaceTbl(repT)
end

function unset()
	if not tagT then return end
	warn'Tool unset.'
	local repT={}
	
	for p,t in next,tagT do
		local nP,par=p,p.Parent
		if bind.output and t.tagged
		then nP=bind.output(p,t)end
		tagT[p]=nil
		
		--If the part is altered.
		if p~=nP then
			nP.Parent=par
			p:destroy()
			repT[p]=nP
		end
	end
	
	--Procrastinated call for efficient looping.
	sel.replaceTbl(repT)
	
	--Adds modifications to the undo chain.
	if bind.waypoint then
		wpm.set('RLVP_Tool_'..bind.waypoint)
		sel.set()
	end
	
	--Variables are reset.
	tagT,bind=nil,nil
end

--Execute after setting and before unsetting.
function exec(...)
	if bind and tagT then
		for p,t in next,tagT do
			bind.drag(p,t,...)
		end
	end
end

--TODO: make it actually be used.
--Execute as a 'console' command.
function execC(modeT,...)
	if not bind then
	return end
	
	if not tagT then
		local repT={}
		local t=sel.get()
		local o=ogMod.get()
		
		if bind.input then
			local originDone
			for i,p in next,t do
				
				--Sets the object up.
				local nP,tags=bind.input(...)
				
				--Miscellaneous tags.
				tags.isOrigin=p==o
				tags.inSelection=true
				tags.tagged=true
				tags.mode=modeT
				tags.origin=o
				
				--Stores that the origin part was done.
				originDone=originDone or p==o
				
				--Executes the object.
				bind.drag(nP,tags,...)
				
				--Unsets the object.
				nP=bind.output(p,tags)
				
				if p~=nP then
				repT[p]=nP end
			end
			
			if not originDone then
				bind.drag(o,{
					isOrigin=true,
					inSelection=true,
					tagged=false,
				},...)
			end
			
			--Procrastinated call for efficient looping.
			sel.replaceTbl(repT)
			
		else
			for i,p in next,t do
				bind.drag(p,{
					isOrigin=p==o,
					inSelection=true,
					tagged=false,
				},...)
			end
		end
	else
		exec(...)
	end
end


return{
	exec=exec,execC=execC,set=set,unset=unset,
	getBind=function(modeT)return binds[modeHash(modeT)]or{}end,
	--setBind=function(modeT,...)binds[modeHash(modeT)]={...}end,
}