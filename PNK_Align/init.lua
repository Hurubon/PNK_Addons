--[[---------------------------------------------------------------------------
	Slash commands
--]]---------------------------------------------------------------------------
PNK_Align.commands = {};

function PNK_Align.commands.HELP()
	PNK_Align.Print('TODO!');
end

function PNK_Align.commands.TEST()
	PNK_Align.Print('No tests to run.');
	--[[
	for _, test in pairs(PNK_Align.tests) do
		test();
	end

	PNK_Align.Print('Testing complete.');
	--]]
end

function PNK_Align.commands.HIDE()
	PNK_Align.grid:Hide();
	PNK_Align.grid:Destroy();
end

function PNK_Align.commands.DRAW(parent, thickness, spacing)
	local parent    = parent or UIParent;
	local thickness = tonumber(thickness or 2);
	-- TODO: Use the UI scale.
	local spacing   = tonumber(spacing or 40);

	PNK_Align.grid:Show();
	PNK_Align.grid:Create(parent, thickness, spacing);
end

--[[---------------------------------------------------------------------------
	Handler
--]]---------------------------------------------------------------------------
local function HandleSlashCommands(commandText)
	if commandText:len() == 0 then
		PNK_Align.commands.HELP();
		return;
	end

	local args = {};
	for _, arg in pairs( { string.split(' ', commandText) }) do
		if arg:len() > 0 then
			table.insert(args, arg);
		end
	end

	local path = PNK_Align.commands;
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
			PNK_Align.commands.HELP();
			return;
		end
	end
end

--[[---------------------------------------------------------------------------
	Initialisation
--]]---------------------------------------------------------------------------
function PNK_Align.Init(self, event, name)
	if name ~= PNK_Align.meta.name then
		return;
	end

	SLASH_PNK_Align1 = '/align';
	SlashCmdList.PNK_Align = HandleSlashCommands;

	PNK_Align.Print('Loaded.');
end

-- TODO: Optimize so that one listener subscribes to all add-ons.
local listener = CreateFrame('Frame');
listener:RegisterEvent('ADDON_LOADED');
listener:SetScript('OnEvent', PNK_Align.Init);
