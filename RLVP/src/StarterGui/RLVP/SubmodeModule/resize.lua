local main=script.Parent.Parent
local plugin=main.Plugin.Value

function resize(p,d)
	p.Size=p.Size+d
end

return{
	[{'resize','face'}]={drag=function(p,tags,f,d)
		local v1=CFrame.new(Vector3.FromNormalId(f)*d/2)
		local v2=Vector3.FromNormalId(f.Value%3)*d
		resize(p,v2)p.CFrame=p.CFrame*v1
	end,waypoint='Resize'},
	
	[{'resize','both'}]={drag=function(p,tags,f,d)
		local v=Vector3.FromNormalId(f.Value%3)*d
		resize(p,v)
	end,waypoint='Resize'},
}