local main=script.Parent
local xtra,xtraCl=script.Extra,nil
local acTk=require(main.ActiveTickModule)
local srts=require(main.ShortcutModule)
local config=require(main.ConfigModule)
local drpd=require(main.DropdownModule)
local actv=require(main.ActiveModule)

local xtraRes=true function pToggle()xtraRes=not xtraRes
xtraCl.Toggle.TextTransparency=xtraRes and.3 or 0 end

return function(algor,cmdMode)
	local mC,pC=algor.index,algor.index..'_prompt'
	local skip=cmdMode or not actv.isActive()
	
	--Decides whether to show thread-blocking dialogue box.
	if skip and algor.clearUndo and config.get(pC)~=false then
		
		--For this scope.
		local mainRes
		
		--Custom toggle added; keybinds should be done here.
		if algor.skippable then
			xtraRes,xtraCl=false,xtra:clone()
			xtraCl.Shortcut.Text=srts.get'activeTick1'
			xtraCl.Button.Activated:connect(pToggle)
			acTk.bind('activeTick1',pToggle)pToggle()
			
			mainRes=select(2,drpd.show({'Yes.','No.',},'Selecting this object'
			..' will clear your undo history.  Proceed?',200,xtraCl))==1
			
			config.setPerm(mC,mainRes)
			config.setPerm(pC,xtraRes)
			acTk.unbind'activeTick1'
		else
		
			mainRes=select(2,drpd.show({'Yes.','No.',},'Selecting this'
			..' object will clear your undo history.  Proceed?',200))==1
			config.setPerm(mC,mainRes)
		end
		
		--Already destroyed.
		xtraCl=nil
		
		--As defined in-scope.
		return mainRes
	else
		return config.get(mC)
	end
end