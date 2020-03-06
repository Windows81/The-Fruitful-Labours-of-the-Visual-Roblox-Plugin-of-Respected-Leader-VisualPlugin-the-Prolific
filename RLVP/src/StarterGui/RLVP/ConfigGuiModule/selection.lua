local main=script.Parent.Parent
local format=require(main.FormatModule)
local srts=require(main.ShortcutModule)
local field=require(main.ConfigFieldModule)
local srtPr=require(main.ShortcutProcessModule)
local elems={}

return{
	init=function(fd)
		local elem=script.Frame
		for i,k in next,srts.list()do
			local e=elem:clone()
			e.TextButton.Text=k
			e.TextLabel.Text=i
			e.Parent=fd
			elems[i]=e
			
			e.TextButton.MouseButton1Click:
			connect(function()srtPr.process(i)end)
		end
	end,
	shortcuts=function(fd,fKeys)
		print(fd)
		for i,k in next,fKeys do
			elems[i].TextButton.Text=k
		end
	end,
	show=function(fd,configT)
		
	end,
	config=function(fd,_,cache)
		
	end,
}