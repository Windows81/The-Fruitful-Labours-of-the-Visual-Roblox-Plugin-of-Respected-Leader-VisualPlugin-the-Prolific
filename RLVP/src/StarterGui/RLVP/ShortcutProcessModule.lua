local main=script.Parent
local block=require(main.BlockWindowModule)
local srts=require(main.ShortcutModule)
local kb=require(main.KeybindModule)
local mode=require(main.ModeModule)
local locked

--Stores the shortcut to variables when undergoing process.
local collE=Instance.new'BindableEvent'
function collect(s,k)collE:Fire(s,k)end

return{
	process=function(name)
		
		--Prevents concurrent calls.
		if locked then return end
		
		--Locks onto the config mode.
		mode.restore()if mode.get()[
		1]~='config'then return end
		
		--Blocks input interference and shows prompt.
		srts.lockAll()block.show('Setting shortcut',300)locked=true
		
		--Collects and sends new values.
		kb.bind(127,collect)local s,k=collE.Event
		:Wait()kb.unbind(127)srts.set(name,s,k)
		
		--Unlocks those factors of interference.
		srts.unlockAll()block.hide()locked=false
		
		return s,k
	end,
}