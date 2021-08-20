--[[---------------------------------------------------------------------------
	Slash commands
--]]---------------------------------------------------------------------------
Duelist.commands = {};

function Duelist.commands.HELP()
	Duelist.Print('TODO!');
end

function Duelist.commands.TEST()
	Duelist.Print('No tests to run.');
	--[[
	for _, test in pairs(Duelist.tests) do
		test();
	end

	Duelist.Print('Testing complete.');
	--]]
end

function Duelist.commands.SETMESSAGE(...)
	local message = string.join(' ', ...);

	Duelist_PostDuelMessage = message;
	Duelist.Print(string.format(
		'Set post duel message to "%s".',
		message
	));
end

--[[---------------------------------------------------------------------------
	Handler
--]]---------------------------------------------------------------------------
local function HandleSlashCommands(commandText)
	if commandText:len() == 0 then
		Duelist.commands.HELP();
		return;
	end

	local args = {};
	for _, arg in pairs( { string.split(' ', commandText) }) do
		if arg:len() > 0 then
			table.insert(args, arg);
		end
	end

	local path = Duelist.commands;
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
			Duelist.commands.HELP();
			return;
		end
	end
end

--[[---------------------------------------------------------------------------
	Initialisation
--]]---------------------------------------------------------------------------
function Duelist.Init(self, event, name)
	if name ~= Duelist.meta.name then
		return;
	end

	SLASH_Duelist1 = '/duelist';
	SlashCmdList.Duelist = HandleSlashCommands;

	Duelist.Print('Loaded.');
end

-- TODO: Optimize so that one listener subscribes to all add-ons.
local listener = CreateFrame('Frame');
listener:RegisterEvent('ADDON_LOADED');
listener:RegisterEvent('DUEL_FINISHED');
listener:SetScript('OnEvent', function(self, event, ...)
	if event == 'ADDON_LOADED' then
		Duelist.Init(self, event, ...);
	elseif event == 'DUEL_FINISHED' then
		Duelist.OnDuelFinish();
	end
end);
