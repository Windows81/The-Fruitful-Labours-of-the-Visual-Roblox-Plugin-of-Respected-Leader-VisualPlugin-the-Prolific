local settings=settings().Studio

if settings.RuntimeUndoBehavior~=Enum.RuntimeUndoBehavior.Hybrid then
	warn('Respected Leader VisualPlugin advises that it is not compatible with your'
	..'current \'RuntimeUndoBehavior\' option; it has been modified to \'Hybrid\'.')
	settings.RuntimeUndoBehavior=Enum.RuntimeUndoBehavior.Hybrid
	print()
end
wait()

--Enables waypoint history persistence.
game.ChangeHistoryService:SetEnabled(true)

return nil