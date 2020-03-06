local main=script.Parent
local hb=game['Run Service'].Heartbeat
local srts=require(main.ShortcutModule)
local mouse=require(main.MouseModule)
local vp=require(main.ViewportModule)
local tween=require(main.TweenModule)
local gui=require(main.GuiMainModule)
local mode=require(main.ModeModule)
local dd=script.Dropdown
local el=script.Element
local pr=script.Prompt

local hCol=Color3.new(15/16,15/16,15/16)
local lCol=Color3.new(1.000,1.000,1.000)

local items,yS={},10
local currList,currPrompt
function show(list,prompt,width,xtra)
	
	--Prevents multiple from showing.
	if currList then return end
	
	--Positions then tweens the GUI.
	local pos,size=mouse.position(),vp.size()
	local ap=Vector2.new(pos.x/size.x,math.floor(pos.y/size.y+.5))
	dd.Position=UDim2.new(0,pos.x,0,pos.y)
	local nPos=pos+(Vector2.new(.5,.5)-ap)*20
	tween.tween(dd,{Position=UDim2.new(0,nPos.x,0,nPos.y)})
	mouse.lock()
	mode.lock()
	
	dd.AnchorPoint=ap
	dd.Size=UDim2.new(0,width,0,yS)
	hb:wait()gui.add(dd)yS=10
	
	currList=list
	for i,s in next,list do
		local c=el:clone()
		c.Parent=dd.Items
		c.LayoutOrder=i
		
		c.NameLabel.Text=s:upper()
		c.Shortcut.Text=srts.get(''..i)
		items[s],yS=c,yS+c.AbsoluteSize.Y
		
		--Connects the click event to the button itself.
		c.Button.Activated:connect(function()exec(s)end)
		
		--Shades the button upon hover.
		c.Button.MouseEnter:connect(function()
		c.BackgroundColor3=hCol end)
		
		--Unshades the button upon leaving hover area.
		c.Button.MouseLeave:connect(function()
		c.BackgroundColor3=lCol end)
	end
	
	--Appends element to the drop-down if one has been passed in.
	if xtra then xtra.LayoutOrder=#list+1 items[0]=xtra
	yS=yS+xtra.AbsoluteSize.Y xtra.Parent=dd.Items end
	
	currPrompt=prompt
	if prompt then
		local tl=pr.TextLabel
		tl.Text=prompt
		local y=game.TextService:GetTextSize(prompt,tl.TextSize,tl.
		Font,Vector2.new(dd.AbsoluteSize.X+tl.Size.X.Offset,666)).Y
		pr.Size=UDim2.new(1,0,0,y+5)
		pr.Parent=dd.Items
		yS=yS+y
	end
	
	dd.Size=UDim2.new(0,width,0,yS)
	return dd.Event.Event:Wait()
end

--Event for selecting an option.
function exec(s)
	
	--Only allows active dropdowns and valid values.
	if not currList or not items[s]then return end
	
	--Replays the result to the 'show' method.
	dd.Event:Fire(s,items[s].LayoutOrder)
	
	--Removes the added items.
	for i,e in next,items do
	items[i]=nil e:destroy()end
	pr.Parent=script
	
	dd.Parent=script
	currPrompt=nil
	mouse.unlock()
	mode.unlock()
	currList=nil
end

return{
	get=function()
		return currList,currPrompt
	end,
	exec=exec,
	show=show,
}