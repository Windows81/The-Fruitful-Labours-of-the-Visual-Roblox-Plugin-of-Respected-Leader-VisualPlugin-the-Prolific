local props={
	Color=BrickColor.Gray().Color,
	Material='Plastic',
	BackSurface='Smooth',
	BottomSurface='Smooth',
	FrontSurface='Smooth',
	LeftSurface='Smooth',
	RightSurface='Smooth',
	TopSurface='Smooth',
	Transparency=0,
	Reflectance=0,
	CastShadow=true,
}

--Parts for property storage.
local cache={}return{
	
	--Used for union explosion.
	explode=function(new,old)
		print'Object exploding.'
		
		--Clones the original part for caching upon implosion.
		local cPart,c=Instance.new'Part',new.Color cache[new]=cPart
		
		--Decorates the cache part according to the old one's appearance.
		if old then for pr in next,props do cPart[pr]=old[pr]end end
		
		--Mimicks the original NegativePart.
		new.BottomSurface='Smooth'
		new.TopSurface='Smooth'
		new.Material='Plastic'
		new.CastShadow=false
		new.Transparency=.41
		new.Color=Color3.fromRGB(c
		.r*255,c.g*155,c.b*165)
		
		return new
	end,
	
	--Used for union implosion.
	implode=function(new,old)
		print'Object imploding.'
		local cPart=cache[old]
		
		--Reverts all properties; or decorates with stock appearance.
		if cPart then for pr in next,props do new[pr]=cPart[pr]end cPart
		:destroy()else for pr,val in next,props do new[pr]=val end end
		
		return new
	end,
	
	decorate=function(part)
		for pr,val in next,props
		do part[pr]=val end
	end
}