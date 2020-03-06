local main=script.Parent
local stor=require(script.ShortcutStorageModule)
local keyEnums=require(main.EnumShortcutModule)
local format=require(main.FormatModule)
local config=require(main.ConfigModule)
local reset=config.get'resetShortcuts'
local kb=require(main.KeybindModule)
local hitBinds,setBinds={},{}

if not reset then
stor.load()end

function shiftPair(k)
	local s=false
	if'EnumItem'~=typeof(k)then
		local c=string.byte(k)
		s=c>=65 and c<=90
		k=Enum.KeyCode[k:upper()]
	end
	return s,k
end

local keyIs,fmtKeys={[
true]={},[false]={}},{}

for i,t in next,keyEnums do
	local s,k=shiftPair(t[2])keyIs[s][k]=t[1]
	fmtKeys[t[1]]=format.srtOutput(s,k)
end

--Keybind-locking mechanism.
local lockT,lockA={},nil function lockAll()lockA=true
end function unlockAll()lockA=false for i in next,lockT do
lockT[i]=nil end end function lock(i)lockT[i]=(lockT[i]or 0)+1
end function unlock(i)lockA=false lockT[i]=lockT[i]-1 end

kb.bind(0,function(shft,key)
	local b=keyIs[shft][key]
	local nL=not lockA and(lockT[b]==0 or not lockT[b])
	if hitBinds[b]and nL then hitBinds[b](b)end
end)

--Sends shortcuts modifications.
function send()for i,f in next,setBinds do f(fmtKeys)end end

function setBind(i,s,k)
	fmtKeys[i]=format.
	srtOutput(s,k)
	keyIs[s][k]=i
end

--Binds default shortcuts.
for i,t in next,keyEnums
do local s,k=shiftPair(t[2])
end send()

function set(i,s,k)
	setBind(i,s,k)send()
	stor.save(keyIs)
end

return{
	set=set,
	get=function(i)return fmtKeys[i]end,
	bind=function(i,f)hitBinds[i]=f end,
	list=function()return fmtKeys end,
	shiftPair=shiftPair,
	
	bindSet=function(f,exec)
	setBinds[#setBinds+1]=f
	if exec then f(fmtKeys)
	end end,
	
	unlockAll=unlockAll,
	lockAll=lockAll,
	unlock=unlock,
	lock=lock,
}