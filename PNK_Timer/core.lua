local timerStack  = PNK_Stack:Construct();
local NAME_PREFIX = 'PNK_TimerName_';

--[[---------------------------------------------------------------------------
	Local functions
--]]---------------------------------------------------------------------------
local function GetExistingOrCreate(name)
	local name     = NAME_PREFIX .. name;
	local existing = _G[name];
	local pooled   = timerStack:Top();

	local result = existing or pooled or CreateFrame('Frame', name);
	result.name  = name;

	if pooled then
		timerStack:Pop();
	end

	_G[name] = result;
	return result;
end

--[[---------------------------------------------------------------------------
	Non-member functions
--]]---------------------------------------------------------------------------
function PNK_Timer.Start(
	name,       -- string:   Timer name.
	resetting,  -- bool:     Reset after counting down?
	countdown,  -- number:   How long to count down.
	increment,  -- number:   How much to increment the time.
	Action      -- function: What to do when the countdown ends.
)
	local timer = GetExistingOrCreate(name);

	timer.sinceUpdate = 0;
	timer.countdown   = countdown;
	timer.increment   = increment;

	timer:SetScript('OnUpdate', function(self, elapsed)
		self.sinceUpdate = self.sinceUpdate + elapsed;

		while self.sinceUpdate >= self.increment do
			self.countdown   = self.countdown   - self.increment;
			self.sinceUpdate = self.sinceUpdate - self.increment;
		end

		if self.countdown <= 0 then
			Action();

			if resetting then
				self.countdown = countdown;
			else
				PNK_Timer.Stop(name);
			end
		end
	end);

	return timer;
end

function PNK_Timer.Stop(name)
	local timer = _G[NAME_PREFIX .. name];

	if timer then
		timer:SetScript('OnUpdate', nil);
		timerStack:Push(timer);
		return true;
	else
		return false;
	end
end
