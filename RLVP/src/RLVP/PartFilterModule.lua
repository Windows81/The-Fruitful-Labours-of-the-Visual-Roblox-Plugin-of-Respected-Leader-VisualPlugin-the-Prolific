return{
	part=function(p)
		return p and(not p.Parent or p:IsDescendantOf(game.Workspace))and p:isA'BasePart'and not p:isA'Terrain'
	end
}