--[[---------------------------------------------------------------------------
	Slash commands
--]]---------------------------------------------------------------------------
CombatLogFix.commands = {};

function CombatLogFix.commands.HELP()
	CombatLogFix.Print('TODO!');
end

function CombatLogFix.commands.TEST()
	CombatLogFix.Print('No tests to run.');
	--[[
	for _, test in pairs(CombatLogFix.tests) do
		test();
	end

	CombatLogFix.Print('Testing complete.');
	--]]
end

--[[---------------------------------------------------------------------------
	Handler
--]]---------------------------------------------------------------------------
local function HandleSlashCommands(commandText)
	if commandText:len() == 0 then
		CombatLogFix.commands.HELP();
		return;
	end

	local args = {};
	for _, arg in pairs( { string.split(' ', commandText) }) do
		if arg:len() > 0 then
			table.insert(args, arg);
		end
	end

	local path = CombatLogFix.commands;
	for id, arg in ipairs(args) do
		arg = string.upper(arg);

		if path[arg] == nil then
			-- skip
		elseif type(path[arg]) == 'function' then
			path[arg]( select(id + 1, unpack(args)) );
			return;
		elseif type(path[arg]) == 'table' then
			path = path[arg];
		else
			CombatLogFix.commands.HELP();
			return;
		end
	end
end

--[[---------------------------------------------------------------------------
	Initialisation
--]]---------------------------------------------------------------------------
function CombatLogFix.Init(self, event, name)
	if name ~= CombatLogFix.meta.name then
		return;
	end

	CombatLogFix.Print('Loaded.');
end

-- TODO: Optimize so that one listener subscribes to all add-ons.
local listener = CreateFrame('Frame');
listener:RegisterEvent('ADDON_LOADED');
listener:SetScript('OnEvent', CombatLogFix.Init);

listener.sinceUpdate    = 0;
listener.updateInterval = 5;
listener:SetScript('OnUpdate', CombatLogFix.OnUpdate);
