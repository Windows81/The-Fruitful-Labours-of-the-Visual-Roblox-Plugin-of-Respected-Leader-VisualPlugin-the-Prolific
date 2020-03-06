local cache={}
return{
	asUnit=false,
	input=function(o)
		local t=tick()
		local f=Instance.new('Folder',o.Parent)
		local c=o:clone()
		c.Name=math.random(1,10)
		c.Parent=f
		c.CFrame=c.CFrame*CFrame.new(0,c.Size.Y,0)
		o.Parent=f
		return f,{o,c},{o}
	end,
	get=function(f,t)
		return t[1]
	end,
	output=function(f,t)
		local o=t[1]
		o.Parent=f.Parent
		f:destroy()
		return o
	end,
}