local main=script.Parent.Parent
local tween=require(main.TweenModule)
local mode=require(main.ModeModule)
local subTempl=script.TextButton
local subElems={}
local buttons={}
local subC=0
local cList

local shownSub
local showableSub
local enabledSub=true
function doSub(card,k)
	local list=mode.getSubs(k)
	if cList==list or mode.getTemp()[1]=='config'then return end
	cList=list
	
	for i,e in next,subElems do
	e:destroy()end subElems={}
	
	local sf=card.card.Sub.ScrollingFrame
	local subElemC=0 for i,n in next,list do
		local c=subTempl:clone()
		c.Activated:connect(function()mode.set(k,n)end)
		c.MouseEnter:connect(function()mode.preview(k,n)end)
		subElemC=subElemC+1
		c.TextLabel.Text=i
		c.Text=n:upper()
		subElems[n]=c
		c.Parent=sf
	end
	showableSub
	=subElemC>0
	return showableSub
end

function showSub(card)
	local sub=card.card.Sub
	if showableSub and enabledSub and not shownSub then
		local x=card.position.x>=.5 and-1 or 1
		tween.tween(sub,{Position=UDim2.new(x,0,0,1)})
		shownSub=true
	end
end

function hideSub(card)
	local sub=card.card.Sub 
	if shownSub then
		tween.tween(sub,{Position=UDim2.new(0,0,0,1)})
		shownSub=false
	end
end

function hoverShow(card)spawn(function()
subC=subC+1 showSub(card)wait(2)subC=subC-1
if subC==0 then hideSub(card)end end)end

function enableSub(card)enabledSub=true end
function disableSub(card)enabledSub=false hideSub(card)end

function setElems(card,mode,preview)
	local m=(preview or mode)[1]
	for n,b in next,buttons do
		b.ImageTransparency
		=n==m and.5 or.7
	end
	
	local s=mode[2]
	local sP=preview and preview[2]
	for i,e in next,subElems do
		e.TextTransparency=i==s
		and 0 or i==sP and.25 or.5
	end
end

function modeFwd(card,mode,preview)
	local m,s=unpack(mode)
	if preview then
		local mP,sP=unpack(preview)
		if mP==m then
			enableSub(card)
			hoverShow(card)
		else
			disableSub(card)
		end
	else
		doSub(card,m)
		enableSub(card)
		hoverShow(card)
	end
	setElems(card,mode,preview)
end

return{
	init=function(card)
		local grid,aB=card.card.Grid,nil
		for i,b in next,grid:children() do
			if b.ClassName=='ImageButton'then
				local n=b.Name
				buttons[n]=b
				
				b.Activated:connect(function()mode.set(n)end)
				b.MouseEnter:connect(function()mode.preview(n)end)
			end
		end
		
		delay(1/2,function()card.card.MouseLeave
		:connect(mode.restore)end)
		local function s()hoverShow(card)end
		card.card.Sub.ScrollingFrame.MouseMoved:connect(s)
		card.card.MouseMoved:connect(s)
	end,
	shortcuts=function(card,fKeys,binds)
		local grid=card.card.Grid
		for n,b in next,buttons do
			b.TextLabel.Text=fKeys[n]
		end
	end,
	mode=modeFwd,
	move=hideSub,
}