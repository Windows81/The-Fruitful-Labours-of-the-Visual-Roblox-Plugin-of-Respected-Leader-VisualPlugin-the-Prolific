local main=script.Parent.Parent
local field=require(main.ConfigFieldModule)

return{
	init=function(fd)
		local tb=fd.Frame.Value.TextBox
		field.text('debugLevel',tb)
	end,
	show=function(fd,configT)
		
	end,
}