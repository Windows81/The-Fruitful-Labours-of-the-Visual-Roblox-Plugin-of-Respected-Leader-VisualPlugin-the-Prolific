local main=script.Parent.Parent
local tween=require(main.TweenModule)
local tbm=require(main.TextBoxModule)
local format=require(main.FormatModule)
local srts=require(main.ShortcutModule)
local data=require(main.IncrementModule)
local enabled

local ddButton=script.DropdownButton
function getDDItem(e,n)
	local c=ddButton:clone()c.Text=format.numOutput(n)
	c.Activated:connect(function()e:Fire(n)end)
	return c
end

function doDropdown(card,fr,list)
	local top=list[1]
	fr.TextBox.Visible=false
	fr.TextButton.Visible=true
	fr.Expand.ImageLabel.Rotation=90
	fr.TextButton.Text=format.numOutput(top)
	local ddName=card.position.y>.5 and'Dropup'or'Dropdown'
	local dd=script[ddName]:clone()
	local sc,e=dd.ScrollingFrame,Instance.new'BindableEvent'
	fr.TextButton.Activated:connect(function()e:Fire(top)end)
	sc.Clear.Activated:connect(function()e:Fire(nil)end)
	sc.Clear.Visible=#list>1
	
	local ddH=21*math.min(5,#list-.5)
	dd.Size=UDim2.new(1,0,0,ddH-10)
	tween.tween(dd,{Size=UDim2.new(1,0,0,ddH)})
	for i=2,#list do getDDItem(e,list[i]).Parent=sc end
	sc.CanvasSize=UDim2.new(0,0,0,21*(#list-1))
	e.Parent,dd.Parent=dd,fr
	
	local r=e.Event:wait()
	fr.Expand.ImageLabel.Rotation=-90
	fr.TextButton.Visible=false
	fr.TextBox.Visible=true
	dd:destroy()
	return r
end

function doIncrFrame(card,fr,key,min,max)
	local tb=fr.TextBox
	local v=data.getCurr(key)
	local curr=format.numOutput(v)
	tb.Text=curr
	
	--Suppresses input if disabled.
	tb.Focused:connect(function()
		if not enabled then
			tb:ReleaseFocus()
		end
	end)
	
	--Captures new value and processes.
	tb.FocusLost:connect(function()
		if not enabled then return end
		local v=format.numInput(tb.Text)
		if v and v>=min and v<max then 
			data.set(key,v)
			curr=format.numOutput(v)
		end tb.Text=curr
	end)
	
	--Constructs drop-down list for increments.
	fr.Expand.Activated:connect(function()
		if
			not enabled or
			card.busy or
			tb:IsFocused()
			
		then return end card.busy=true
		local l=data.getHist(key)
		local ddv=doDropdown(card,fr,l)
		if ddv then data.set(key,ddv)
		else ddv=data.clear(key)end
		tb.Text=format.numOutput(ddv)
		card.busy=false
	end)
end

--Toggles taking in user input for the increment.
function setEnabled(card,b)
	if enabled==b
	then return end
	local cardO=card.card
	local lat,rot=cardO.LatIncr,cardO.RotIncr
	lat.TextBox.TextTransparency=b and 0 or.5
	rot.TextBox.TextTransparency=b and 0 or.5
	lat.TextBox.ClearTextOnFocus=b
	rot.TextBox.ClearTextOnFocus=b
	lat.Expand.AutoButtonColor=b
	rot.Expand.AutoButtonColor=b
	enabled=b
end

return{
	shortcuts=function(card,fKeys)
		local cardO=card.card
		local lat=fKeys.latIncr
		local rot=fKeys.rotIncr
		cardO.LatIncr.Shortcut.Text=lat
		cardO.RotIncr.Shortcut.Text=rot
		tbm.bindTextBox(cardO.RotIncr.TextBox)
		tbm.bindTextBox(cardO.LatIncr.TextBox)
		
		--Looking for how these shortcuts got binded?
		srts.bind('latIncr',function()wait()if enabled
		then cardO.LatIncr.TextBox:CaptureFocus()end end)
		srts.bind('rotIncr',function()wait()if enabled
		then cardO.RotIncr.TextBox:CaptureFocus()end end)
	end,
	init=function(card)
		local o=card.card
		doIncrFrame(card,o.LatIncr,'lat',0,10^13)
		doIncrFrame(card,o.RotIncr,'rot',0,360)
		setEnabled(card,true)
	end,
	mode=function(card,currM,tempM)
		local m=tempM or currM
		setEnabled(card,m[1]~='config')
	end,
}