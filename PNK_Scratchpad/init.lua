--[[---------------------------------------------------------------------------
	Slash commands
--]]---------------------------------------------------------------------------
PNK_Scratchpad.commands = {};

function PNK_Scratchpad.commands.HELP()
	PNK_Scratchpad.Print('TODO!');
end

function PNK_Scratchpad.commands.TEST()
	PNK_Scratchpad.Print('No tests to run.');
	--[[
	for _, test in pairs(PNK_Scratchpad.tests) do
		test();
	end

	PNK_Scratchpad.Print('Testing complete.');
	--]]
end

function PNK_Scratchpad.commands.RUN(...)
	local result = PNK_Scratchpad.scratch(...);

	if result then
		PNK_Scratchpad.Print('Scratch returned: ' .. result);
	end
end



--[[---------------------------------------------------------------------------
	Handler
--]]---------------------------------------------------------------------------
local function HandleSlashCommands(commandText)
	if commandText:len() == 0 then
		PNK_Scratchpad.commands.HELP();
		return;
	end

	local args = {};
	for _, arg in pairs( { string.split(' ', commandText) }) do
		if arg:len() > 0 then
			table.insert(args, arg);
		end
	end

	local path = PNK_Scratchpad.commands;
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
			PNK_Scratchpad.commands.HELP();
			return;
		end
	end
end

--[[---------------------------------------------------------------------------
	Initialisation
--]]---------------------------------------------------------------------------
function PNK_Scratchpad.Init(self, event, name)
	if name ~= PNK_Scratchpad.meta.name then
		return;
	end

	SLASH_PNK_Scratchpad1 = '/scratch';
	SlashCmdList.PNK_Scratchpad = HandleSlashCommands;

	PNK_Scratchpad.Print('Loaded.');
end

-- TODO: Optimize so that one listener subscribes to all add-ons.
local listener = CreateFrame('Frame');
listener:RegisterEvent('ADDON_LOADED');
listener:SetScript('OnEvent', PNK_Scratchpad.Init);
