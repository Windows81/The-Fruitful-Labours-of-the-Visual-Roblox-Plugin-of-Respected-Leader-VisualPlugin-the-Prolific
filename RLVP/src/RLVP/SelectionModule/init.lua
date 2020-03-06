local main=script.Parent
local algorSel=require(main.AlgorChooserModule).choose
local algorConf=require(main.AlgorConfigModule)
local evtMod=require(main.PartEventModule)
local pfMod=require(main.PartFilterModule)
local grTag=require(script.GroupTagModule)
local hb=game['Run Service'].Heartbeat
local active=require(main.ActiveModule)
local selGroups,binds,locked={},{},nil
local wpm=require(main.WaypointModule)

--Modifies global environment.
require(main.DebugModule)()

--One-to-one mapping to each other by numerical index.
local studioSels,pluginSels={},{}

--Only returns any selection if the plugin is active.
function get()return active.isActive()and pluginSels or{}end

--Prints contents of addT and remT.
function tblPrint(t1,t2)
	local l=math.max(#t1,#t2)
	print()warn'Two-table dump:'
	for i=1,l do print('    ',i,t1[i],t2[i])end
end

--Prints selection.
function selPrint()
	
	--Dumps the selection data to the output.
	print()warn'Selection dump:'
	for i=1,math.max(#studioSels,#pluginSels) do
		local ss,sl=studioSels[i],pluginSels[i]
		if ss==sl then print('    ',i,ss)
		else print('    ',i,ss,sl)end
	end
	
	--Dumps the main-parts of each selection group.
	print()warn'Selection-group dump:'
	for m in next,selGroups do print('    ',m)end
end

--Fires events, overrides studio selections.
function send(bypass)
	for i,b in next,binds do b(pluginSels)end
	if locked or bypass then return end
	
	--Sets the actual selection on Studio.
	lock()setStudioSels()unlock()
end

function addP(p,selP)
	selP=selP or p
	local n=#studioSels
	for i=1,n do
		if studioSels[i]==p or pluginSels
		[i]==selP then return end
	end
	
	if pfMod.part(selP)then
		while n>#pluginSels do
			studioSels[n+1]=studioSels[n]
			pluginSels[n+1]=pluginSels[n]
		n=n-1 end pluginSels[n+1]=selP
	end
	studioSels[n+1]=p
	return true
end

function removeP(p)
	for i=#studioSels,1,-1 do
		
		--Case when part is included in selection.
		if pluginSels[i]==p or studioSels[i]==p then
			
			--Removes element at critical index.
			for I=i,#pluginSels do
			pluginSels[I]=pluginSels[I+1]
			studioSels[I]=studioSels[I+1]end
			return true
		end
	end
end

--More efficient version of removeP for associated arrays.
function removeTbl(t)local b
	
	--Removes parts from the studioSels and pluginSels tables.
	for i=#studioSels,1,-1 do
		if t[studioSels[i]]or t[pluginSels[i]]then
			
			--Removes element at critical index.
			for I=i,#studioSels do 
			pluginSels[I]=pluginSels[I+1]
			studioSels[I]=studioSels[I+1]end
			b=true
		end
	end
	return b
end

function addG(a,p,...)
	local par,g=p.Parent,{algor=a}
	g.main,g.parts,g.defSel=a.input(p,...)
	
	g.main.Parent=par
	selGroups[g.main]=g
	return g
end

--Method for removing group from its main part.
function removeGroup(main)
	
	--Returns if there is none linked to it.
	if not selGroups[main]then return end
	
	--Declares variable for the group.
	local g=selGroups[main]
	
	--Removes the group from persistence.
	grTag.removeTagged(g)
	
	--Removes just the main part if as a unit.
	if g.algor.asUnit then removeP(g.main)else
		
		--Removes all parts of the group otherwise.
		local parts={}for i,p in next,g.parts
		do parts[p]=true end removeTbl(parts)
	end
	
	--Removes the group's temporary parts.
	local p=g.algor.output(main,g.parts)
	
	--Clears all waypoints to resolve undo bugs.
	if g.algor.clearUndo then wpm.reset()end
	
	selGroups[main]=nil return p
end

--Conditionally calls the group's respective algorithm function.
function callGroupFunc(partI,name,...)
	if not selGroups[partI]then return end
	local g=selGroups[partI]local f=g.algor[name]
	if f then return f(partI,g.parts,...)end
end

--Selects part in a group if one already lists it.
function addGrPart(p)
	
	--Evaluates whether the part is already in a group.
	--If the part to add is in a group, mark it and break the loop. 
	local inGroup
	for m,g in next,selGroups do
		if not g.asUnit then
			local gr=g.parts
			for i,gp in next,gr do if gp==p
			then inGroup=gr break end end
			if inGroup then break end
		end
	end
	
	--Only add to group if the group is not as unit.
	--As a unit, all group's parts would be selected.
	if inGroup then return addP(p)end
end

--Creates a group then adds the first part.
function createGroup(p,cmdMode)
	
	--Special cases for groups.
	local algor=algorSel(p)
	if algor then
		
		--If algorithm is disabled, returns dummy value.
		if not algorConf(algor,cmdMode)then return 0 end
		
		--Adds a group in the group table.
		local g=addG(algor,p)
		
		--Tags them using CollectionService for when place gets open after being saved.
		grTag.tagGroup(g)
		
		--Adds the group's main part along with a plugin-level cast onto the selection.
		if algor.asUnit then addP(g.main,g.algor.get(g.main,g.parts))
		
		--If not as a unit, ensure there are default selected parts and select them.
		else g.defSel=g.defSel or g.parts for i,gp in next,g.defSel do addP(gp)end end
		
		--Clears all waypoints to resolve undo bugs.
		if algor.clearUndo then wpm.reset()end
		
		return g
	end
end

--Add part (command)
function addC(p)
	
	--Debounce protection.
	if locked then return
	end lock()
	
	local b=p and(
		addGrPart(p)or
		createGroup(p,true)or
		addP(p))
	
	unlock()
	if not b then return end
	selPrint()return p
end

--Remove part (command)
function removeC(p)
	
	--Debounce protection.
	if locked then return
	end lock()
	
	local r
	for i,g in next,selGroups do
		local u,has=g.algor.asUnit,nil
		
		--Evaluates whether the part is in a selection group.
		for i,gp in next,g.parts do if gp==p then has=true end end
		if has then
			
			--Removes the group.
			if u then removeGroup(i)r=true
			
			--If not as a unit, removes part.
			else if removeP(p)then
					
					--Evaluates whether there are other parts in the group.
					for i,sp in next,studioSels do
						for i,gp in next,g.parts do
							if gp==sp then r=true break end
						end if r then break end
					end
					
					--If there are no parts left in the group.
					if not r then r=removeGroup(i)end
					
				else r=false end
			end
			break
		end
	end
	
	if r==nil then
	r=removeP(p)end unlock()
	return r and true or false
end

--Efficiently replaces table indicies with corresponding values (one-to-one).
function replaceTblRaw(t)
	
	--Returns if locked or nothing in the table.
	if locked or not next(t)then return end
	
	--Redirects all saved parts within each group.
	local grRedirs,inGrT={},{}
	for m,g in next,selGroups do
		
		--Redirects the main part of group.
		grRedirs[m]=t[m]
		
		--Redirects default part table.
		local ds,pt=g.defSel,g.parts
		if ds and ds~=pt then
			for i,gp in next,ds do
				ds[i]=t[gp]or ds[i]
			end
		end
		
		--Redirects part table.
		for i,gp in next,pt do
			
			--Also stores index of parts that are in groups.
			local v=t[gp]if v then pt[i]=v inGrT[gp]=v end
		end
	end
	
	--Redirects main-part indicies.
	for p1,p2 in next,grRedirs do
	selGroups[p2]=selGroups[p1]
	selGroups[p1]=nil end
	
	--Redirects plugin-level selections.
	for i,p in next,pluginSels do
	pluginSels[i]=t[p]or pluginSels[i]end
	
	--Redirects both sleection tables.
	for i=#studioSels,1,-1 do
	pluginSels[i]=t[pluginSels[i]]or pluginSels[i]
	studioSels[i]=t[studioSels[i]]or studioSels[i]end
	
	--Removals from newly-grouped parts.
	local grRemove={}
	
	--Creates new groups from the parts.
	for p1,p2 in next,t do
		if not grRedirs[p1]
		and not inGrT[p1]then
			createGroup(p2)
			grRemove[p2]=true
		end
	end
	
	--Removes the parts.
	removeTbl(grRemove)
	return true
end

--Wrapper function for code reference to be executed externally.
function replaceTbl(...)if replaceTblRaw(...)then send()end end

--Shifts to the front.
function shift(p)
	
	--Ensures the algorithm wouldn't do anything if it doesn't have to.
	if pluginSels[1]==p or studioSels[1]==p then return true end
	
	for i=2,#pluginSels do
		if pluginSels[i]==p then
			
			--Shifts the plugin selections.
			pluginSels[i]=pluginSels[1]pluginSels[1]=p
			
			--Shifts the corresponding studio selections.
			studioSels[i]=studioSels[1]studioSels[1]=p
			
			--Relays the event, bypassing selection changes.
			send(true)return p
		end
	end
end

--Self-explanitory.
function getStudioSels()
	return game.Selection:Get()
end

--Again, self-explanitory.
function setStudioSels(t)
	print'Selection set.'
	studioSels=t or studioSels
	game.Selection:Set(studioSels)
end

--Passes in a table of enum. strings indexed by parts.
function changeSel(changes)
	
	--Determines if Selection:Set() should be invoked.
	--local changed
	
	--Object that needs to be changed before proceeding.
	local newSS={}
	
	--Redirects newly-selected parts.
	for m,g in next,selGroups do
		
		--If as-a-unit, selects the group's main part.
		if g.asUnit then for i,gp in next,g.parts do
			if changes[gp]=='add'then
				changes[gp]=nil
				changes[m]='add'
				break
			end
		end
		
		--If not as a unit, and main part is being added to selection, redirect to the default parts.
		elseif changes[m]=='add'then changes[m]=nil for i,gp in next,g.defSel do changes[gp]='add'end end
	end
		
	--Adds part to the new selection.
	for p,l in next,changes do
		if l=='keep'then
			newSS[#newSS+1]=p
		end
	end
	
	--Sets the redirects in stone.
	studioSels=newSS
	
	--Group-edition flags.
	local grAdded,grRemvd
	
	--Part table to efficiently remove from.
	local remove={}
	
	--Does special modifications on groups and their parts.
	for m,g in next,selGroups do local u=g.algor.asUnit
		
		--If grouped as a unit.
		if u then
			
			--Evaluates if at least one part got added/removed.
			local a,r=changes[m]=='add',changes[m]=='remove'
			
			--Removes the entire unit only if a part is being deselected and another one is NOT being selected.
			if r and not a then grRemvd=true removeGroup(m)changes[m]=nil end
		else
			--Evaluates whether all parts already selected within the selection group are being removed.
			local all=true for i,gp in next,g.parts do if changes[gp]and'remove'~=changes[gp]then all=false break end end
			
			--Removes the selection group ONLY if none are being added back.
			if all then
				for i,gp in next,g.parts do
					if'remove'==changes[gp]then
						changes[gp]=nil
					end
				end
				grRemvd=true
				removeGroup(m)
				
			--Otherwise, add and remove necessary parts.
			else for i,gp in next,g.parts do
					
					--Remove function is omitted to be used all at once later.
					if'remove'==changes[gp]then remove[gp]=true changes[gp]=nil
					elseif'add'==changes[gp]then
						newSS[#newSS+1]=gp
						changes[gp]=nil
						addP(gp)
					end
				end
			end 
		end
	end
	
	--Iterates through remaining changes.
	for p,l in next,changes do
		
		--Stages that parts for removal.
		if l=='remove'then remove[p]=true
		
		--For adding new part.
		elseif l=='add'then
			
			--Attempts to create a new group.
			local g=createGroup(p)
			
			--Modifies flag if group-able.
			if g then grAdded=true
			
			--Adds that part to selection otherwise.
			else addP(p)end
		end
	end
	
	--Removes all parts counted for removal.
	removeTbl(remove)
	
	--Finalises selection changes.
	send(not grAdded and not grRemvd)
end

function selChanged()
	if locked or not active.isActive() then return end
	warn'SelectionChanged event fired'
	hb:wait()
	
	local logs,old={},studioSels
	studioSels=getStudioSels()
	
	--Searches for objects to add.
	for i,p1 in next,studioSels do
		local b='add' 
		for I,p2 in next,old do
			if p1==p2 then
				b='keep'
				break
			end
		end
		logs[p1]=b
	end
	
	--Searches for objects to remove.
	for i,p in next,old do
		if not logs[p]then
			logs[p]='remove'
		end
	end
	
	--Main method.
	changeSel(logs)
end

--Lock functions for the selection module.
function lock()locked=true evtMod.lock()end
function unlock()locked=false evtMod.unlock()end

--Binds the refined selection event.
evtMod.bind('selChanged',selChanged)

--[[
evtMod.bind('modifyGroup',function(addT,remT)
	for p,t in next,tagT do
		bind.modify(p,t,addT,remT)
	end
end)
]]

evtMod.bind('destroy',function(t)
	for m,g in next,selGroups do
		local all=true
		for i,gp in next,g.parts do
			if not t[gp]then
			all=false break end
		end
		if all then
			
			--Removes the group from persistence.
			grTag.removeTagged(g)
			
			--Removes just the main part if as a unit.
			if g.algor.asUnit then removeP(g.main)else
				
				--Removes all parts of the group otherwise.
				local parts={}for i,p in next,g.parts
				do parts[p]=true end removeTbl(parts)
			end
			
			--Removes reference.
			selGroups[m]=nil
		end
	end
	
	--Clears selection tables.
	studioSels,pluginSels={},{}
	send(true)
end)

--Implements bind for the negation of parts.
evtMod.bind('negateSel',function(addT,remT)
	
	--Table for groups to remove.
	local remGrT={}
	
	--Attempts to send event data to each group; will modify addT and remT.
	for m,g in next,selGroups do if not callGroupFunc(m,'modify','negateSel',addT,remT)then remGrT[m]=true end end
	
	--Generates a one-to-one table that will be used to modify the current selection.
	local l,replT=#addT,{}for i=1,l do replT[remT[i]]=addT[i]end replaceTblRaw(replT)
	
	--Removes groups that returned false on the other loop.
	for m in next,remGrT do addP(removeGroup(replT[m]or m))end
	
	tblPrint(addT,remT)
	selPrint()send()
end)

--Implements bind for separated parts.
evtMod.bind('unionSel',function(addT,remT)
	
	--Table for groups to remove.
	local remGrT={}
	
	--Attempts to send event data to each group; will modify addT and remT.
	for m,g in next,selGroups do if not callGroupFunc(m,'modify','unionSel',addT,remT)then remGrT[m]=true end end
	
	--Generates a one-to-one table that will be used to modify the current selection.
	local l,replT=#addT,{}for i=1,l do replT[remT[i]]=addT[i]end replaceTblRaw(replT)
	
	--Removes groups that returned false on the other loop.
	for m in next,remGrT do addP(removeGroup(replT[m]or m))end
	
	tblPrint(addT,remT)
	selPrint()send()
end)

--Implements bind for separated parts.
evtMod.bind('separSel',function(addT,remT)
	
	--Table for groups to remove.
	local remGrT={}
	
	--Attempts to send event data to each group; will modify addT and remT.
	for m,g in next,selGroups do if not callGroupFunc(m,'modify','separSel',addT,remT)then remGrT[m]=true end end
	
	--Generates a one-to-one table that will be used to modify the current selection.
	local l,replT=#addT,{}for i=1,l do replT[remT[i]]=addT[i]end replaceTblRaw(replT)
	
	--Removes groups that returned false on the other loop.
	for m in next,remGrT do addP(removeGroup(replT[m]or m))end
	
	tblPrint(addT,remT)
	selPrint()send()
end)

evtMod.bind('restore',function(wp)
	warn'Adjusting selection.'
	local tempSS=getStudioSels()
	local selIndexT={}
	local algorIndexT={}
	
	for i,p in next,tempSS do
		if algorSel(p)then
			algorIndexT[p]=true
		end
	end
	
	for m,g in next,selGroups do
		for i,gp in next,g.parts do
			local nulled
			
			--If parts have been deleted, removes from group.
			if nulled then removeP(gp)elseif not gp.Parent
			then selGroups[m]=nil removeP(gp)nulled=true end
		end
	end
	
	--Create groupss
	for p in next,algorIndexT do
	createGroup(p)end send()
end)

--Sets bind for (de)activation.
active.bind(function(a)
	
	--If active, makes table blank.
	if a then studioSels={}
		
		--Re-establishes the selection by iterating part-by-part.
		for i,p in next,getStudioSels()do if pfMod.part(p)then
		local r=createGroup(p)if not r then addP(p)end end end
		
	--Otherwise, reverts all selection-groups for streamlined use.
	else for m,g in next,selGroups do addP(removeGroup(m))end
		
		--Sends without calling binds.
		lock()setStudioSels()unlock()
		
		--Disposes the now-useless table.
		pluginSels={}
	end
end)

return{
	add=addC,get=get,
	remove=removeC,
	
	--Determines if there are non-single objects selected.
	hasGroups=function()return next(selGroups)~=nil end,
	
	shift=shift,set=setStudioSels,
	replaceTbl=replaceTbl,
	changeSel=changeSel,
	
	update=send,
	lock=lock,unlock=unlock,
	bind=function(f)binds[#binds+1]=f end,
	selChanged=selChanged,
}