function move(p,tags,face,d)
	local cf=tags.origin.CFrame
	local v=(cf-cf.p)*(Vector3.
	FromNormalId(face)*d)
	p.CFrame=p.CFrame+v
	--[[
	local m=tags.main
	m.CFrame=m.CFrame+v
	]]
end

return{
	[{'move','axis'}]={drag=move,origin='axisG',waypoint='Move'},
	[{'move','first'}]={drag=move,waypoint='Move'},
}