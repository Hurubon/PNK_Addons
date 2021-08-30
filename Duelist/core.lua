function Duelist.OnDuelFinish()
	if UnitHealth('player') / UnitMaxHealth('player') < 0.5 then
		SendChatMessage(Duelist_PostDuelMessage, 'SAY');
	end
end
