function CombatLogFix.OnUpdate(self, elapsed)
	self.sinceUpdate = self.sinceUpdate + elapsed;

	while self.sinceUpdate >= self.updateInterval do
		CombatLogClearEntries();
		self.sinceUpdate = self.sinceUpdate - self.updateInterval;
	end
end
