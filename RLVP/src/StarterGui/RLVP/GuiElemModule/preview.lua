local main=script.Parent.Parent
local tween=require(main.TweenModule)

local camCf1=CFrame.fromEulerAnglesYXZ(math.rad(45),math
.rad(-15),math.rad(15)):inverse()*CFrame.new(0,1/16,115)
local camCf2=camCf1*CFrame.new(0,0,45)
local camCf3=camCf1*CFrame.new(0,0,69)
local tweens={}
local handles={}
local handlePos={
	{Vector3.new(0,2.5,0),Vector3.new(0,0,0)},
	{Vector3.new(0,-2.5,0),Vector3.new(0,0,180)},
	{Vector3.new(-3,0,0),Vector3.new(0,0,90)},
	{Vector3.new(3,0,0),Vector3.new(0,0,-90)},
	{Vector3.new(0,0,2),Vector3.new(0,90,90)},
	{Vector3.new(0,0,-2),Vector3.new(0,-90,90)},
}

local hMode
function set(card,n)
	if n and hMode==n then
	return end hMode=n
	
	local vf=card.
	card.PreviewFrame
	local pX=vf.PoleX
	local pY=vf.PoleY
	local pZ=vf.PoleZ
	
	local aX=vf.AxleX
	local aY=vf.AxleY
	local aZ=vf.AxleZ
	
	pX.Size=Vector3
	.new(.3,.3,.3)
	pY.Size=Vector3
	.new(.3,.3,.3)
	pZ.Size=Vector3
	.new(.3,.3,.3)
	
	aX.Size=Vector3
	.new(.3,.3,.3)
	aY.Size=Vector3
	.new(.3,.3,.3)
	aZ.Size=Vector3
	.new(.3,.3,.3)
	
	for i=#handles,1,-1 do
		handles[i]:destroy()
		handles[i]=nil
	end
	
	local cam=vf:findFirstChild'Camera'
	or Instance.new('Camera',vf)
	vf.Camera.CFrame=camCf1
	cam.FieldOfView=2.125
	vf.CurrentCamera=cam
	
	local h=n and script:findFirstChild(n)
	for i=#tweens,1,-1 do tweens[i
	]:Cancel()tweens[i]=nil end
	
	if n=='resize'or n=='move'then
		pX.Color=h.Color
		pY.Color=h.Color
		pZ.Color=h.Color
		
		tweens[1]=tween.tween(vf
		.Camera,{CFrame=camCf2})
		
		tweens[2]=tween.tween(pX,{
		Size=Vector3.new(5,.3,.3)})
		tweens[3]=tween.tween(pY,{
		Size=Vector3.new(.3,4,.3)})
		tweens[4]=tween.tween(pZ,{
		Size=Vector3.new(3,.3,.3)})
		
		for i,p in next,handlePos do
			local c=h:clone()c.Orientation=p[2]
			tweens[i+4]=tween.tween(c,{Position
			=p[1]})handles[i]=c c.Parent=vf
		end
	elseif n=='rotate'then
		tweens[1]=tween.tween(vf
		.Camera,{CFrame=camCf3})
		
		tweens[2]=tween.tween(aX,{
		Size=Vector3.new(6,.1,6)})
		tweens[3]=tween.tween(aY,{
		Size=Vector3.new(6,.1,6)})
		tweens[4]=tween.tween(aZ,{
		Size=Vector3.new(6,.1,6)})
		
	elseif not h then return end
end

return{
	init=function(card)
		set(card)
	end,
	mode=function(card,perm,temp)
		local mode=temp or perm
		set(card,mode[1])
	end,
}