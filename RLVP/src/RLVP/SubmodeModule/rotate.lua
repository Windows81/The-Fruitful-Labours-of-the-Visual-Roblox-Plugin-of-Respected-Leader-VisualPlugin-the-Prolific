--Rotation function that takes the CFrame in.
function rot8Main(p,tags,axis,angle,...)
	
	local o0=tags.origin.CFrame
	local v3=Vector3.FromAxis(axis)
	local o1=CFrame.fromAxisAngle(v3,math.rad(angle))
	p.CFrame=o0*o1*(o0:inverse()*p.CFrame)
end

return{
	[{'rotate','axis'}]={drag=rot8Main,origin='axisO',waypoint='Rotate'},
	[{'rotate','group'}]={drag=rot8Main,origin='axisG',waypoint='Rotate'},
	[{'rotate','first'}]={drag=rot8Main,waypoint='Rotate'},
}