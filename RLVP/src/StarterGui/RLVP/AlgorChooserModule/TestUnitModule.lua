local cache={}
return{
	--asUnit = whether the parts 
	asUnit=true,
	input=function(o)
		local t=tick()
		local f=Instance.new'Folder'
		local c=o:clone()
		c.Name=math.random(1,10)
		c.Parent=f
		o.Parent=f
		return f,{o,c}
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