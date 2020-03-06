local main=script.Parent
local plugin=main.Plugin.Value
local button=plugin:CreateToolbar'RLVP':CreateButton(
	'Respected Leader VisualPlugin',
	'Upon the honourly might of Respected Leader VisualPlugin, I beseech you!',
	'rbxassetid://1024760812'
)

local locked
local binds={}
function bind(f)
	binds[#binds+1]=f
end

local active=false
function activate()
	
	--Debounce to prevent duplicate calls.
	if locked then return end locked=true
	
	active=true
	button:SetActive(true)
	plugin:Activate(true)
	for i,b in next,binds
	do b(true)end
	locked=false
	return true
end

--Fires when deactivated.
function deactivate()
	
	--Debounce to prevent duplicate calls.
	if locked then return end locked=true
	
	active=false
	button:SetActive(false)
	for i,b in next,binds
	do b(false)end
	locked=false
	return true
end

function lock()locked=true end
function unlock()locked=false end

button.Click:connect(function()
	if locked then return elseif active
	then deactivate()else activate()end
end)

plugin.Deactivation
:connect(deactivate)

function isActive()
return active end

return{bind=bind,
lock=lock,unlock=unlock,
activate=activate,
isActive=isActive,
deactivate=deactivate}