local main=script.Parent
local config=require(main.ConfigModule)
local uis=game:service'UserInputService'
local configModes={
	['number']='num',
}

local funcs={
	numInput=function(v)
		local n=tonumber(v)
		if n then return n
		elseif typeof(v)=='string'
		and#v==0 then return nil end
		local lsW,lsV=pcall(loadstring('return '..v))
		lsV=tonumber(lsV)if lsW then return lsV end
	end,
	numOutput=function(n,dec)
		dec=dec or 3
		if not tonumber(n)then return''end
		local m=math.floor(math.log10(math.max(1e-9,math.abs(n))))
		
		if m<=dec then
			return string.format('%.'..math.clamp(dec-m,0,dec)..'f',n)
		else
			local l=1-math.floor(math.log10(m))
			return string.format('%.'..l..'fE%i',n/10^m,m)
		end
	end,
	srtOutput=function(s,k)
		if typeof(k)=='EnumItem'then
		k=uis:GetStringForKeyCode(k)end
		if s then return utf8.char(0x2191)
		..k:upper()else return k:lower()end
	end,
}

funcs.configInput=function(key,value)
	local def=config.getDefault(key)
	local mode=def.format[1]
	local name=configModes[mode]
	if not def.check(value)then return
	elseif not name then return value
	else
		local func=funcs[name..'Input']
		return func(value,unpack(def.format,2))
	end
end

funcs.configOutput=function(key,value)
	local def=config.getDefault(key)
	local mode=def.format[1]
	local name=configModes[mode]
	if not def.check(value)then return
	elseif not name then return value
	else
		local func=funcs[name..'Output']
		return func(value,unpack(def.format,2))
	end
end

return funcs