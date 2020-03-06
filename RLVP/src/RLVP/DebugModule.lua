local main=script.Parent
local config=require(main.ConfigModule)
local empty=function()end
local envs={}

--Debug level corresponds with filtering global debug functions.
function set(env,d)
	env.print=d>2 and print or empty
	env.warn=d>1 and warn or empty
	env.error=d>0 and error or empty
end

--Fires when the debug setting changes.
config.bindIndv('debugLevel',function(d,temp)
	for i=1,#envs do set(envs[i],d)end
end)

return function(d)
	--Can be between 0 and 3 inclusive.
	local d=d or config.get'debugLevel'
	
	--Gets current environment and stores it.
	local env=getfenv()envs[#envs+1]=env
	
	set(env,d)
end