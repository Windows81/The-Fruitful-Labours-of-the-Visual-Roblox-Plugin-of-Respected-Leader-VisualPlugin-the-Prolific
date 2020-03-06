local main=script.Parent.Parent
local plugin=main.Plugin.Value

return{
	save=function(keyIs)
		local t={}
		for s in next,keyIs do
			for k,v in next,keyIs[s] do
				t[#t+1]={v,s,k.Name}
			end
		end
			
		plugin:SetSetting('shortcuts',t)
	end,
	load=function()
		local t=plugin:GetSetting'shortcuts'
		local keyIs={}for i,v in next,t do
		local s,k=unpack(v,2)keyIs[s]=keyIs
		[s]or{}keyIs[s][k]=t[1]end
		return keyIs
	end,
}