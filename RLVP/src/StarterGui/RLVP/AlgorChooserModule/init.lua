local selAlgors={
	--testU=require(script.TestUnitModule),
	--testN=require(script.TestNonUnitModule),
	csg=require(script.CSGModule),
}

--Adds the index name to each algorithm table.
for n,algor in next,selAlgors do algor.index=n end

return{
	getChoices=function()
	return selAlgors end,
	choose=function(p)
		if p:isA'PartOperation'then
			return selAlgors.csg
		end
	end,
}