--[[---------------------------------------------------------------------------
	Slash commands
--]]---------------------------------------------------------------------------
PNK_Stack.commands = {};

function PNK_Stack.commands.HELP()
	PNK_Stack.Print('TODO!');
end

function PNK_Stack.commands.TEST()
	for _, test in pairs(PNK_Stack.meta.tests) do
		test();
	end

	PNK_Stack.Print('Testing complete.');
end

--[[---------------------------------------------------------------------------
	Handler
--]]---------------------------------------------------------------------------
local function HandleSlashCommands(commandText)
	if commandText:len() == 0 then
		PNK_Stack.commands.HELP();
		return;
	end

	local args = {};
	for _, arg in pairs( { string.split(' ', commandText) }) do
		if arg:len() > 0 then
			table.insert(args, arg);
		end
	end

	local path = PNK_Stack.commands;
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
			PNK_Stack.commands.HELP();
			return;
		end
	end
end

--[[---------------------------------------------------------------------------
	Initialisation
--]]---------------------------------------------------------------------------
function PNK_Stack.Init(self, event, name)
	if name ~= PNK_Stack.meta.name then
		return;
	end

	PNK_Stack.Print('Loaded.');
end

-- TODO: Optimize so that one listener subscribes to all add-ons.
local listener = CreateFrame('Frame');
listener:RegisterEvent('ADDON_LOADED');
listener:SetScript('OnEvent', PNK_Stack.Init);
