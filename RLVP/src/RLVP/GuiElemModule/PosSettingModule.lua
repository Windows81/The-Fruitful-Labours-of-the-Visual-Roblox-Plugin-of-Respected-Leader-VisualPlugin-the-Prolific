local plugin=script.Parent.Parent.Plugin.Value
local t={}
return{
	save=function(card)
		local p=card.position
		local o=card.offset
		t[card.name]={p.x,p.y,o}
		plugin:SetSetting('guiPos',t)
	end,
	load=function(card)
		t=plugin:GetSetting'guiPos'or{}
		local v=t[card.name]
		if not v then return end
		card.position=Vector2.new(v[1],v[2])
		card.offset=v[3]
	end,
}