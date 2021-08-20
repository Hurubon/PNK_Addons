--[[---------------------------------------------------------------------------
	Slash commands
--]]---------------------------------------------------------------------------
PNK_Adverts.commands = {};

function PNK_Adverts.commands.HELP()
	PNK_Adverts.Print('TODO!');
end

function PNK_Adverts.commands.TEST()
	PNK_Adverts.Print('No tests to run.');
	--[[
	for _, test in pairs(PNK_Adverts.tests) do
		test();
	end

	PNK_Adverts.Print('Testing complete.');
	--]]
end

function PNK_Adverts.commands.PUSH(
	name,       -- string: Advert name.
	frequency,  -- string: How often to broadcast.
	...         -- string: Fragments of the advert message.
)
	local message = string.join(' ', ...);
	local Action  = function()
		SendChatMessage(
			message,
			'CHANNEL',
			nil,
			GetChannelName(PNK_Adverts_OutputChat)
		);
	end;

	-- TOOD: Factor out.
	local toSeconds = function(time)
		local h = tonumber( string.sub(time, 1, 2) );
		local m = tonumber( string.sub(time, 4, 5) );
		local s = tonumber( string.sub(time, 7, 8) );

		return 3600 * h + 60 * m + s;
	end

	PNK_Adverts.Print(string.format(
		'Created advert %s in %s (repeat every %s).',
		name, PNK_Adverts_OutputChat, frequency
	));
	PNK_Timer.Start(name, true, toSeconds(frequency), 1, Action);
	Action();
end

function PNK_Adverts.commands.STOP(name)
	local stopped = PNK_Timer.Stop(name);

	if stopped then
		PNK_Adverts.Print(string.format('Stopped advert %s.', name));
	else
		PNK_Adverts.Print(string.format('Couldn\'t find %s.', name));
	end
end

function PNK_Adverts.commands.SETCHAT(chat)
	PNK_Adverts_OutputChat = chat;
end

--[[---------------------------------------------------------------------------
	Handler
--]]---------------------------------------------------------------------------
local function HandleSlashCommands(commandText)
	if commandText:len() == 0 then
		PNK_Adverts.commands.HELP();
		return;
	end

	local args = {};
	for _, arg in pairs( { string.split(' ', commandText) }) do
		if arg:len() > 0 then
			table.insert(args, arg);
		end
	end

	local path = PNK_Adverts.commands;
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
			PNK_Adverts.commands.HELP();
			return;
		end
	end
end

--[[---------------------------------------------------------------------------
	Initialisation
--]]---------------------------------------------------------------------------
function PNK_Adverts.Init(self, event, name)
	if name ~= PNK_Adverts.meta.name then
		return;
	end

	SLASH_PNK_Adverts1 = '/ads';
	SlashCmdList.PNK_Adverts = HandleSlashCommands;

	PNK_Adverts.Print('Loaded.');
end

-- TODO: Optimize so that one listener subscribes to all add-ons.
local listener = CreateFrame('Frame');
listener:RegisterEvent('ADDON_LOADED');
listener:SetScript('OnEvent', PNK_Adverts.Init);
