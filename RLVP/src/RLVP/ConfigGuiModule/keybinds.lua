local main=script.Parent.Parent
local format=require(main.FormatModule)
local srts=require(main.ShortcutModule)
local field=require(main.ConfigFieldModule)
local srtPr=require(main.ShortcutProcessModule)
local keyEnums=require(main.EnumShortcutModule)
local elems={}

return{
	init=function(fd)
		local elem=script.Frame
		for i,t in next,keyEnums do
			
			local i=t[1]
			local k=format.srtOutput(
				srts.shiftPair(t[2]))
				
			local e=elem:clone()
			e.TextButton.Text=k
			e.TextLabel.Text=t[3]
			e.Parent=fd
			elems[i]=e
			
			--e.TextButton.MouseEnter:connect(function()e.TextButton.Screentip.Visible=true end)
			--e.TextButton.MouseLeave:connect(function()e.TextButton.Screentip.Visible=false end)
			
			e.TextButton.MouseButton1Click:
			connect(function()srtPr.process(i)end)
		end
	end,
	shortcuts=function(fd,fKeys)
		for i,k in next,fKeys do
			elems[i].TextButton.Text=k
		end
	end,
	show=function(fd,configT)
		
	end,
	config=function(fd,_,cache)
		
	end,
}