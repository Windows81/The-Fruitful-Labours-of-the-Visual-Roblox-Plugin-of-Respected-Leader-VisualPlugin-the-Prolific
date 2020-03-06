local main=script.Parent
local enumC=require(main.EnumConfigSubModule)

local subs,binds={},{}
function getSubs()return subs end
function getBinds()return binds end

function modeHash(modeT)
	if not modeT then return''end
	return modeT[1]..'_'..modeT[2]
end

for i,m in next,script:children() do
	local t=require(m)
	for i,bt in next,t do
		local t=subs[i[1]]
		if t then t[#t+1]=i[2]
		else subs[i[1]]={i[2]}end
		binds[modeHash(i)]=bt
	end
end

local configSubs={}
subs.config=configSubs
for i in next,enumC
do configSubs[i]=i end

return{getSubs=getSubs,binds=getBinds}