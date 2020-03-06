local main=script.Parent
local mouse=require(main.MouseModule)
local sel=require(main.SelectionModule)
local plugin=script.Parent.Plugin.Value
local rs=game:service'RunService'
local origin=script.Origin
local mO=mouse.mouse
local box=script.Box
local currM,currO

function snap(v3)
	local x=math.floor(v3.x+.5)
	local y=math.floor(v3.y+.5)
	local z=math.floor(v3.z+.5)
	return Vector3.new(x,y,z)
end

function camCf()
	return game.Workspace.CurrentCamera.CFrame
end

local savedB
function buffer(diff)
	local a=diff/100
	return Vector3
	.new(a,a,a)
end

local hov1,hov2,hov3
function hover1()
	local p=mO.Target
	if hov1==p
	then return end
	hov1=p if not p
	then return end
	
	local s=p.Size
	box.Adornee=p
end

function hover2()
	local c=mO.Hit
	if not c then
	return end
	origin.CFrame
	=hov2+snap((hov3
	*c).p/hov1)*hov1
end

return{
	get=function()return currO end,
	rawStore=function(v)currO=v end,
	process=function(currP,mode,ovrd)
		
		local parts=sel.get()
		currM=mode if not mode then 
		currO=currP return currP else
			
			--Determines whether user input is allowed.
			ovrd=currM~=mode or ovrd
			
			--Hard-to-explain.
			currO=origin
			
			if mode=='axisO'then
				local p=parts[1]if not p then return
				end origin.CFrame=CFrame.new(p.Position)
				
				local s=p.Size local
				r=p.CFrame-p.Position
				local maxX,maxY,maxZ=0,0,0
				for x=-1,1,2 do
				for y=-1,1,2 do
				for z=-1,1,2 do
				local v=r*(s*Vector3.new(x,y
				,z))local X,Y,Z=v.x,v.y,v.z
				if X>maxX then maxX=X end
				if Y>maxY then maxY=Y end
				if Z>maxZ then maxZ=Z end
				end end end
				
				origin.Size=Vector3
				.new(maxX,maxY,maxZ)
			
			elseif mode=='axisG'then
				if#parts==0 then return end
				
				local maxX,maxY,maxZ=-2^31,-2^31,-2^31
				local minX,minY,minZ=02^31,02^31,02^31
				for i,p in next,parts do
				local s,c=p.Size/2,p.CFrame
				
				for x=-1,1,2 do
				for y=-1,1,2 do
				for z=-1,1,2 do
				local v=c*(s*Vector3.new(x,y,z))
				local X,Y,Z=v.x,v.y,v.z
				if X>maxX then maxX=X elseif X<minX then minX=X end
				if Y>maxY then maxY=Y elseif Y<minY then minY=Y end
				if Z>maxZ then maxZ=Z elseif Z<minZ then minZ=Z end
				end end end end
				
				local sX=maxX-minX
				local sY=maxY-minY
				local sZ=maxZ-minZ
				local cX=(maxX+minX)/2
				local cY=(maxY+minY)/2
				local cZ=(maxZ+minZ)/2
				origin.Size=Vector3.new(sX,sY,sZ)
				origin.CFrame=CFrame.new(cX,cY,cZ)
				
			elseif mode=='edge'and ovrd then
				mouse.bind(666,true)
				box.Visible=true
				local t repeat
					rs:BindToRenderStep(
					'rlvpOrigin',200,hover1)
					mO.Button1Down:wait()
					rs:UnbindFromRenderStep('rlvpOrigin')
				until hov1
				hov2=hov1.CFrame
				hov3=hov2:inverse()
				hov1=hov1.Size/2
				local a=buffer(
				(camCf()-hov2.p
				).magnitude)
				box.Size=a
				
				box.Adornee=origin
				local t repeat
					rs:BindToRenderStep(
					'rlvpOrigin',200,hover2)
					mO.Button1Down:wait()
					rs:UnbindFromRenderStep('rlvpOrigin')
				until hov1
				box.Visible=false
				mouse.unbind(666)
			end
		end
		
		return currO
	end
}