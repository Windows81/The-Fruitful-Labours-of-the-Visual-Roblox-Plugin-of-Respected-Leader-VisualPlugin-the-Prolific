local main=script.Parent
local subMd=require(main.SubmodeModule)
local tbm=require(main.TextBoxModule)
local cSubs,binds,busy={},{},nil
require(main.DebugModule)()
local subs=subMd.getSubs()
local dfltM={'select',1}
local currM=dfltM
local tempM=nil

--Locking mechanism.
local locked=0 function lock()locked=locked+1
end function unlock()locked=locked-1 end

function setMode(m,s)
	if busy or locked>=1
	then return end
	local m=m or currM[1]
	local s=s or getSub(m)
	local oM,oS=unpack(currM)
	print('Setting mode:',m,s)
	currM,tempM={m,s},nil
	send(currM)
	cSubs[m]=s
end

function preview(m,s)
	if busy then return end 
	local s=s or getSub(m)
	print('Previewing mode:',m,s)
	tempM={m,s}send(currM,tempM)
end

function getSub(m)return cSubs[m]or(subs[m]or{''})[1]end
function getTemp()return tempM or currM end
function getSubs(m)return subs[m or currM[1]]or{}end
function getMode()return currM end

--Fires already-bound functions.
function send(...)busy=true
for i,f in next,binds do
f(...)end busy=false end

--Removes temporarily-set mode.
function restore()if busy then return end
print'Restoring mode.' tempM=nil send(currM)end

--Ensures text-input doesn't mess it up.
tbm.bindGlobal(1,lock,unlock)

send(currM)
return{
	bind=function(f)binds
	[#binds+1]=f end,
	set=setMode,
	get=getMode,
	getTemp=getTemp,
	preview=preview,
	restore=restore,
	getSubs=getSubs,
	unlock=unlock,
	lock=lock,
	--[[unbind=function(i)
	binds[i]=nil end,]]
}