local plugin=script.Parent.Parent.Plugin.Value
local posN,negN='RLVP_Positive','RLVP_Negative'
local propS=require(script.PropStorModule)

--Implodes exploded negative part.
function implodeNeg(o)
	
	--Restores old values.
	propS.implode(o,o)
	local p=plugin:Negate{o}[1]
	
	return p
end

--Explodes negative parts.
function explodeNeg(o)
	
	--A non-negative part wouldn't need negation at all.
	if not o:isA'NegateOperation'then return o end
	
	--Negates and stores the result.
	local p=plugin:Separate{o}[1]
	
	--A union wouldn't need additional designs.
	if p:isA'UnionOperation'then return p end
	
	--Makes it plugin-compatible.
	return propS.explode(p)
end

--Recursive helper function.
function explodeRec(orig,pT)
	
	--Un-negates instance if negative.
	local union,folder,comps=explodeNeg(orig),nil,nil
	
	--Generates a name for the new part(s).
	local isNeg=orig:isA'NegateOperation'
	local name=isNeg and negN or posN
	
	--Stores variables as object if it's at its most basic.
	if not union:isA'UnionOperation'then
	union.Name=name folder,comps=union,{union}
		
	--Otherwise, splits union in folder.
	else
		local par=union.Parent
		folder=Instance.new'Folder'
		union.Parent=folder
		folder.Name=name
		
		comps=plugin:Separate{union}
		folder.Parent=par
	end
	
	--Recursively splits components.
	for i,p in next,comps do
		if p:isA'PartOperation'then
		p=select(2,explodeRec(p,pT))end
			
		pT[#pT+1]=p
	end
	return folder,union
end

--Recursively undoes the explosion.
function implodeRec(o)
		
	--Negates exploded parts that were NegativeParts.
	if o.Name==negN then return implodeNeg(o)
	
	elseif o:isA'Folder'then
		local allNeg=true
		
		--Determines whether all children are negative parts; will affect later code.
		local c=o:children()for i,u in next,c do allNeg=allNeg and u.Name==negN end
		
		--Labels children negative for future calls.
		if allNeg then for i,old,new in next,c do
				old.Name=posN
				new=implodeRec(old)
				new.Name=negN
				c[i]=new
			end
		
			--Unions the parts.
			local u=plugin:Union(c)
			
			--Removes its now-empty folder.
			u.Parent=o.Parent o:destroy()
			
			--Returns the newly-made union.
			u.Name=negN return u
		
		else for i,u in next,c do
				c[i]=implodeRec(u)
			end
		
			--Unions the parts.
			local u=plugin:Union(c)
			
			--Removes its now-empty folder.
			u.Parent=o.Parent o:destroy()
			
			--Returns the newly-made union.
			u.Name=o.Name return u
		end
	end
	
	return o
end

--Explodes a union and adds all the residue into a table reference.
function explode(u)local t={}local o=explodeRec(u,t)return o,t end

--Wrapper function to ensure code-design consistency.
function implode(o)return implodeRec(o)end

return{
	skippable=true,
	name='CSGExplosion™',
	clearUndo=true,
	asUnit=false,
	input=explode,
	get=function(f,t)
	return t[1]end,
	output=implode,
	modify=function(main,currPT,mode,addT,remT)
		
		if mode=='negateSel'then
			local keepGr
			for i,addP in next,addT do
				
				--One-to-one correspondance.
				local remP=remT[i]
				
				--Checks if part is in group or is the main part.
				if remP==main or addP:IsDescendantOf(main)then
					
					--Creates a new part embodying the properties.
					local n=Instance.new'Part'
					n.Size=addP.Size
					n.CFrame=addP.CFrame
					n.Anchored=true
					n.Parent=addP.Parent
					propS.decorate(n)
					
					--Determines if the original part was negative.
					local negating=remP.Name~=negN
					
					--Decorates the new part if it is negated.
					if negating then propS.explode(n,remP)
					
					--Otherwise, reverse the aforementioned code.
					else propS.implode(n,remP)end
					
					--Modifies the keep-group flag.
					keepGr=negating or remP~=main or keepGr
					
					--Renames the new part appropriately.
					n.Name=not negating and posN or negN
					
					--Destroys useless part.
					addP:destroy()
					
					--Adds new clone.
					addT[i]=n
				end
			end
			
			--Would remove group if made false.
			return keepGr
		
		elseif mode=='unionSel'then
			local u=addT[1]
			local par=u.Parent
			if#par:children()==1 then
				u.Parent=par.Parent
				par:destroy()
			end
			
			--Re-separates the union.
			local f,t=explode(u)
			
			--Overwrites the add table for selection interop.
			for i,p in next,t do addT[i]=p end return true
			
		else
			--Explodes all newly-added parts; adds the residue in.
			local newT={}
			for i,addP in next,addT do
				if addP:IsDescendantOf(main)then
					
					local t=select(2,explode(addP))
					for i,expP in next,t do
						newT[#newT+1]=expP
					end
					
				--Runoff for parts not in the group.
				else newT[#newT+1]=addP end
			end
			
			--Clones the contents of newT to addT.
			local l=math.max(#newT,#addT)
			for i=1,l do addT[i]=newT[i]end
		end
	end,
}