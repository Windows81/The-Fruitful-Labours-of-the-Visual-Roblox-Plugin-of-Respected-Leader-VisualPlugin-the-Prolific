local main=script.Parent
local config=require(main.ConfigModule)
local format=require(main.FormatModule)
local tbm=require(main.TextBoxModule)
local inputs={}

config.bindAll(function(dict)
	for tb,info in next,inputs do
		local key,mode=unpack(info)
		if dict[key]then
			local val=config.get(key)
			local def=config.getDefault(key)
			if mode=='text'then
				tb.Text=format.configInput(key,val)
			end
		end
	end
end)

return{
	text=function(key,tb)
		local val=config.get(key)
		inputs[tb]={key,'text'}
		tb.Text=format.configOutput(key,val)
		
		tbm.bindTextBox(tb,nil,function()
			local num=format.configInput(key,tb.Text)
			if num then config.setTemp(key,num)return end
			tb.Text=format.configOutput(key,config.get(key))
		end)
	end,
}