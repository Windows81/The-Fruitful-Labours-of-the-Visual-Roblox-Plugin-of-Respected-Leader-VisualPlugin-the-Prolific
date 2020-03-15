local main=script.Parent
local rs=game['Run Service'].RenderStepped
local pfMod=require(main.PartFilterModule)
local active=require(main.ActiveModule)
local wpm=require(main.WaypointModule)
local addParts,remParts={},{}
local selSer=game.Selection
local binds,debounce={},nil

--Modifies global environment.
require(main.DebugModule)()

local added=game.DescendantAdded
local remov=game.DescendantRemoving

--Prevents permission-level issues for class security checks and filters out non-parts.
function check(p)return pcall(function()return p.ClassName end)and pfMod.part(p) end

--Safely calls a binded function; doesn't if function is nil.
function callBind(n,...)return binds[n]and binds[n](...)end

function chooseWp(wp,...)
	if wp then return wp end
	
	local aT,rT=...
	local aL,rL=#aT,#rT
	if aL==rL then
		
		--Determines if there is evidence for NegateSelection.
		local isNeg8=true for i=1,aL do
			local aN=aT[i]:isA'NegateOperation'
			local rN=rT[i]:isA'NegateOperation'
			if aN==rN then isNeg8=false break end
		end if isNeg8 then return'NegateSelection'end
		
		--Determines if there is evidence of either a union or a separation.
		elseif aL==1 and aT[1]:isA'UnionOperation'then return'UnionSelection'
		elseif rL==1 and rT[1]:isA'UnionOperation'then return'SeparateSelection'
	end
end

--Executes an action that relates to the one listed in undo history.
function wpAction(wp,undo,...)
	active.lock()
	
	--Sets waypoint if one is not given.
	wp=wp or chooseWp(wp,...)
	
	--Mappings for Studio-based waypoints for CSG .
	if wp=='NegateSelection'then callBind('negateSel',...)
	elseif wp=='UnionSelection'then callBind(undo and'separSel'or'unionSel',...)
	elseif wp=='SeparateSelection'then callBind(undo and'unionSel'or'separSel',...)
	
	else--if wp:sub(10)=='RLVP_Tool_'then
		callBind('restore',wp)
	end
	
	active.unlock()
end

--Event that fires when something gets added.
added:Connect(function(p)
	
	--Self-explanitorily prevents unneeded calls and calls that could error out.
	if not check(p)or not active.isActive()or debounce then return end debounce=true
	
	--Aggregate tables for additional modifications.
	warn('Added (first): ',p)addParts[1]=p
	
	--Event for placing added parts in aggreagte table.
	local addC=added:Connect(function(p)
		if not check(p)then return end
		warn('Added: ',p)
		addParts[#addParts+1]=p
	end)
	
	--Event for placing removed parts in aggreagte table.
	local remC=remov:Connect(function(p)
		if not check(p)then return end
		warn('Removed: ',p)
		remParts[#remParts+1]=p
	end)
	
	--Prevents multiple events from firing at once.
	local done
	
	--Takes care of the event for undoing changes.
	coroutine.resume(coroutine.create(
		function()local wp=wpm.onUndo:
		Wait()if done then return end
			done=true warn('Action undone:',wp)
			addC:Disconnect()remC:Disconnect()
			wpAction(wp,true,addParts,remParts)
		end))
		
	--Takes care of the event for redoing changes.
	coroutine.resume(coroutine.create(
		function()local wp=wpm.onRedo:
		Wait()if done then return end
			done=true warn('Action redone:',wp)
			addC:Disconnect()remC:Disconnect()
			wpAction(wp,false,addParts,remParts)
		end))
	
	--Waits for events to lapse.
	rs:wait()
	addC:Disconnect()
	remC:Disconnect()
	if done then return end
	
	local canUndo,wp=wpm.prevWp()
	warn(wp or'Undefined waypoint'
	,'added to undo history.')
	
	wpAction(wp,false,addParts,remParts)
	for i=#addParts,1,-1 do addParts[i]=nil end
	for i=#remParts,1,-1 do remParts[i]=nil end
	debounce=false
end)

--Event that fires when something gets removed.
remov:Connect(function(p)
	
	--Self-explanitorily prevents unneeded calls and calls that could error out.
	if not check(p)or not active.isActive()or debounce then return end debounce=true
	
	--Aggregate tables for additional modifications.
	warn('Removed (first): ',p)remParts[1]=p
	
	--Event for placing added parts in aggreagte table.
	local addC=added:Connect(function(p)
		if not check(p)then return end
		warn('Added: ',p)
		addParts[#addParts+1]=p
	end)
	
	--Event for placing removed parts in aggreagte table.
	local remC=remov:Connect(function(p)
		if not check(p)then return end
		warn('Removed: ',p)
		remParts[#remParts+1]=p
	end)
	
	--Prevents multiple events from firing at once.
	local done
	
	--Takes care of the event for undoing changes.
	coroutine.resume(coroutine.create(
		function()local wp=wpm.onUndo:
		Wait()if done then return end
			done=true warn('Action undone:',wp)
			addC:Disconnect()remC:Disconnect()
			wpAction(wp,true,addParts,remParts)
		end))
	
	--Takes care of the event for redoing changes.
	coroutine.resume(coroutine.create(
		function()local wp=wpm.onRedo:
		Wait()if done then return end
			done=true warn('Action redone:',wp)
			addC:Disconnect()remC:Disconnect()
			wpAction(wp,false,addParts,remParts)
		end))
	
	--Waits for events to lapse.
	rs:wait()
	addC:Disconnect()
	remC:Disconnect()
	if done then return end
	
	local canUndo,wp=wpm.prevWp()
	warn(wp or'Undefined waypoint'
	,'added to undo history.')
	
	wpAction(wp,false,addParts,remParts)
	for i=#addParts,1,-1 do addParts[i]=nil end
	for i=#remParts,1,-1 do remParts[i]=nil end
	debounce=false
end)

--TODO: cases when the undo event fires first.
wpm.onUndo:Connect(function(name)
	if name:sub(1,10)=='RLVP_Tool_'then
		debounce=true
		--local wp=name:sub(6)
		wpAction(name)
		debounce=false
	end
end)

--Event for manually changing selection.
selSer.SelectionChanged:Connect(function()
	if debounce then return end debounce=true
	
	--Stores all removed parts on a table.
	local t,d={},nil local e=remov:Connect(function(p)
		if check(p)and p.Parent then
			warn('Destroyed:',p)
			t[p],d=true,true
		end
	end)
	
	--Maintains event for a short time.
	rs:wait()e:Disconnect()
	
	if d then
		warn'Parts destroyed.'
		callBind('destroy',t)
	else
		warn'Studio selection changed.'
		callBind'selChanged'
	end
	debounce=false
end)

return{
	lock=function()debounce=true end,
	unlock=function()debounce=false end,
	bind=function(n,f)binds[n]=f end,
	getBind=function(n)return binds[n]end,
}