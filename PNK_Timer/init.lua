--[[---------------------------------------------------------------------------
	Slash commands
--]]---------------------------------------------------------------------------
PNK_Timer.commands = {};

function PNK_Timer.commands.HELP()
	PNK_Timer.Print('TODO!');
end

function PNK_Timer.commands.TEST()
	PNK_Timer.Print('No tests to run.');
	--[[
	for _, test in pairs(PNK_Timer.tests) do
		test();
	end

	PNK_Timer.Print('Testing complete.');
	--]]
end

--[[---------------------------------------------------------------------------
	Handler
--]]---------------------------------------------------------------------------
local function HandleSlashCommands(commandText)
	if commandText:len() == 0 then
		PNK_Timer.commands.HELP();
		return;
	end

	local args = {};
	for _, arg in pairs( { string.split(' ', commandText) }) do
		if arg:len() > 0 then
			table.insert(args, arg);
		end
	end

	local path = PNK_Timer.commands;
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
			PNK_Timer.commands.HELP();
			return;
		end
	end
end

--[[---------------------------------------------------------------------------
	Initialisation
--]]---------------------------------------------------------------------------
function PNK_Timer.Init(self, event, name)
	if name ~= PNK_Timer.meta.name then
		return;
	end

	PNK_Timer.Print('Loaded.');
end

-- TODO: Optimize so that one listener subscribes to all add-ons.
local listener = CreateFrame('Frame');
listener:RegisterEvent('ADDON_LOADED');
listener:SetScript('OnEvent', PNK_Timer.Init);
