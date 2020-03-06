local plugin=script.Parent.Plugin.Value
local reset=false

--Implements the increments' setting.
local incrs=plugin:GetSetting'increments'
if reset or not incrs then incrs={}end
function initIncrs(gr,ov)
	if ov or not incrs[gr] then
		incrs[gr]={0}
	end
end

return{
	getCurr=function(gr)initIncrs(
	gr)return unpack(incrs[gr])end,
	getHist=function(gr)
	return incrs[gr]end,
	remove=function(gr,v)
		local incrT=incrs[gr]
		if not incrT then return end
		for i=#incrT,1,-1 do if incrT[i]==v then
			for I=i,#incrT do incrT[I]=incrT[I+1]end
			if#incrT==0 then incrs[gr]={}initIncrs(gr)end
			plugin:SetSetting('increments',incrs)end
		end
	end,
	set=function(gr,v)
		initIncrs(gr)
		local incrT=incrs[gr]
		for i=#incrT,1,-1 do
			if v==incrT[i]then
				for I=i,2,-1 do incrT[I]=incrT[I-1]end incrT[1]=v
				plugin:SetSetting('increments',incrs)return
			end
		end
		for i=#incrT,1,-1 do incrT[i+1]=incrT[i] end incrT[1]=v
		plugin:SetSetting('increments',incrs)
	end,
	clear=function(gr)
		initIncrs(gr,true)
		return incrs[gr][1]
	end,
	calc=function(gr,v,i)
		initIncrs(gr)
		i=i or incrs[gr][1]if i==0 then return v end
		if gr=='rot'then v=(math.deg(v)+360)%360 return
		math.floor((v-360*math.floor(v/180))/i+.5)*i
		else return math.floor(v/i+.5)*i end
	end,
}