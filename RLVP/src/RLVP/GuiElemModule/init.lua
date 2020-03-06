local main=script.Parent
local psm=require(script.PosSettingModule)
local srts=require(main.ShortcutModule)
local actv=require(main.ActiveModule)
local tween=require(main.TweenModule)
local gui=require(main.GuiMainModule)
local mode=require(main.ModeModule)
local switchPos=script.SwitchPos
local plugin=main.Plugin.Value

--These values are the differencials applied for each switchPos button.
local switchPosDiffs={negX={-1,0},posX={1,0},negY={0,-1},posY={0,1}}

--This function generates a hash key for a Vector2.
function hashV2(v2)return v2.x^2+math.pi*v2.y end

--Carries the count of cards in each position.
local posStack={}

function activ8SwitchPos(card)
	local v2=card.position
	local sp=card.card.SwitchPos
	for i,diff in next,switchPosDiffs do
		sp[i].Active=v2.x+diff[1]/2
		==.5 or v2.y+diff[2]/2==.5
	end
	
	if card.offset>0 then
		sp.posY.Active=true
		sp.negY.Active=true
	end
end

--This code indexes the cards by name and applies other properties.
local elems,cards=gui.get'elems':children(),{}
local totalH=0 for i,cardO in next,elems do
	
	local name=cardO.Name
	local h=cardO.Size.Y.Offset+7
	local module=require(script[name])
	
	--Searching for the card table's initiation?
	local card={position=Vector2.new(),
		card=cardO,module=module,
		offset=totalH,height=h,
		shown=false,busy=false,
		callbacks={},name=name,
	}
	
	--This code calls an init function, if it has one.
	if module.init then module.init(card)end
	
	psm.load(card)
	local hsh=hashV2(card.position)
	posStack[hsh]=math.max(posStack
	[hsh]or 0,card.offset+h)
	
	local sp=switchPos:clone()
	sp.Parent=cardO
	cards[name]=card
	totalH=totalH+h
	
	--Treats the directional switch buttons.
	for i,diff in next,switchPosDiffs do
		local b=sp[i]
		
		--This code will highligh the buttons.
		b.MouseEnter:connect(function()
			if not b.Active then return end
			b.ImageTransparency
			=b.ImageTransparency-1/2
			for i=1/16,1/2,1/16 do wait()
				b.ImageTransparency
				=b.ImageTransparency+1/16
			end
		end)
		
		b.Activated:connect(function()
			if card.busy then return end
			local p=card.position
			local x=diff[1]+p.x
			local y=diff[2]+p.y
			
			if y>1 or y<0 then shiftCard(card)else
			reposition(card,Vector2.new(x,y))end
		end)
	end
	
	--Constructs the cross thingy.
	activ8SwitchPos(card)
end

function shiftCard(card)
	for i,c in next,cards do
		if c~=card and c.position==card.position then
			print(c.offset)
			if c.offset<card.offset then
				c.offset=c.offset+card.height
				reposCard(c,cardProps(c))
			end
		end
	end
	card.offset=0
	reposCard(card
	,cardProps(card))
end

--Returns a property table that'll be used in TweenService.
function cardProps(card)
	local v2=card.position
	local s=v2.y>.5 and-1 or 1
	local o=card.offset*s
	
	if card.shown then
		local ud=UDim2.new(v2.x,5-10*v2.x,v2.y,5-10*v2.y+o)
		return{Position=ud,AnchorPoint=v2}
	else
		local ud=UDim2.new(v2.x,10*v2.x-5,v2.y,5-10*v2.y+o)
		return{Position=ud,AnchorPoint=Vector2.new(1-v2.x,v2.y)}
	end
end

function switchPosProps(card)
	local o=card.offset
	local v2=card.position
	
	if not card.shown then return{Position=UDim2.
	new(.5,0,1,0),AnchorPoint=Vector2.new(.5,1)}
	
	elseif v2.x>.5 then return{Position=UDim2.
	new(0,-3,1,0),AnchorPoint=Vector2.new(1,1)}
	
	else return{Position=UDim2.new(1,5,
	1,0),AnchorPoint=Vector2.new(0,1)}
	end
end

function reposCard(card,...)
	local mF=card.module.move
	if mF then mF(card,...)end
	tween.tween(card.card,...)
	activ8SwitchPos(card)
	psm.save(card)
end

function reposition(card,v2)
	if not card.shown or card.busy then return end
	local ps=card.position
	local h=card.height
	
	for i,c in next,cards do
		if c~=card and c.position==ps then
			if c.offset>=card.offset then
				c.offset=c.offset-h
				local props=cardProps(c)
				reposCard(c,props)
			end
		end
	end
	
	card.position,card.busy=v2,true
	local oHash,nHash=hashV2(ps),hashV2(v2)
	posStack[nHash]=posStack[nHash]or 0
	
	card.offset=posStack[nHash]
	local sp=card.card.SwitchPos
	tween.tween(sp,switchPosProps(card))
	local cP=cardProps(card)
	reposCard(card,cP)
	posStack[oHash]=posStack[oHash]-h
	posStack[nHash]=posStack[nHash]+h
	
	wait(tween.wTime)
	card.busy=false
	return true
end

function showAll()
	gui.show()
	for i,card in next,cards do
		if not card.shown and not card.busy then
			
			card.busy=true local hp=cardProps(card)
			card.shown=true local sp=cardProps(card)
			
			tween.apply(card.card,hp)
			tween.tween(card.card,sp)
			
			local sp=card.card.SwitchPos
			tween.tween(sp,switchPosProps(card))
		end
	end
	delay(tween.wTime,function()
		for i,card in next,cards do
			card.busy=false
		end
	end)
end

function hideAll()
	for i,card in next,cards do
		if card.shown and not card.busy then
			
			card.busy=true local sp=cardProps(card)
			card.shown=false local hp=cardProps(card)
			
			tween.apply(card.card,sp)
			tween.tween(card.card,hp)
			
			local sp=card.card.SwitchPos
			tween.tween(sp,switchPosProps(card))
		end
	end
	
	delay(tween.wTime,function()
		gui.hide()
		for i,card in next,cards do
			card.busy=false
		end
	end)
end

--Relays an action to its respective module.
function doAction(cardN,actionN,...)
	local card=cards[cardN]
	if not card then return end
	local a=card.module[actionN]
	if a then return a(card,...)end
end

--Relays an action to every module.
function actionAll(actionN,...)
	for i,card in next,cards do
		local a=card.module[actionN]
		if a then a(card,...)end
	end
end

--Adds a function to a list of callbacks.
function callback(cardN,cbN,func)
	cards[cardN].callbacks[cbN]=func
end

function callbackAll(cbN,func)
	for i,card in next,cards do
		card.callbacks[cbN]=func
	end
end

mode.bind(function(...)actionAll('mode',...)end)
srts.bindSet(function(...)actionAll('shortcuts',...)end,true)

actv.bind(function(b)
	(b and showAll or hideAll)()
	actionAll('active',b)
end)

return{
	action=doAction,
	callback=callback,
	actionAll=actionAll,
	callbackAll=callbackAll,
}