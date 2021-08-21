local format = string.format;
local buttonSize = 40;
--[[---------------------------------------------------------------------------
	This is an annotated version of Nevcairiel's LibActionButton.
	I thought it was amazing that you could create your own buttons
	and tailor the in-game UI to your liking, but I struggled to
	figure out how it all worked, and I couldn't find any guides
	either. I decided to create one for anyone who might want to
	follow in my footsteps.
--]]---------------------------------------------------------------------------

--[[---------------------------------------------------------------------------
	1. Button types.
--]]---------------------------------------------------------------------------
-- (1.0)
-- The baseline for any button will be a simple CheckButton frame.
local Generic = CreateFrame('CheckButton');
-- Setting up the metatables this way is perhaps easier than constantly doing
--	Generic.__index = Generic;
-- This is how it was originally done in LibActionButton, so I left it in.
local Generic_MT = { __index = Generic };

-- (1.1)
-- Other kinds of buttons simply derive from (1.0).
local Action    = setmetatable({}, Generic_MT);
local PetAction = setmetatable({}, Generic_MT);
local Spell     = setmetatable({}, Generic_MT);
local Item      = setmetatable({}, Generic_MT);
local Macro     = setmetatable({}, Generic_MT);

local Action_MT    = { __index = Action    };
local PetAction_MT = { __index = PetAction };
local Spell_MT     = { __index = Spell     };
local Item_MT      = { __index = Item      };
local Macro_MT     = { __index = Macro     };

-- (1.2)
-- We will establish a mapping between button types and (1.1).
local typeMetaMap =
{
	empty  = Generic_MT,
	action = Action_MT,
	pet    = PetAction_MT,
	spell  = Spell_MT,
	item   = Item_MT,
	macro  = Macro_MT,
};

--[==[-------------------------------------------------------------------------
	2. The CreateButton function
------------------------------[ Before we begin ]------------------------------
I will briefly discuss the concept of headers.

SecureHeaders are a new concept added near the beginning of WotLK.
We are only concerned with the API functions we can use to achieve desired
UI behaviour. Unfortunately, LAB in its original form started from 4.0
onwards, which introduced some functionality in the form of header methods.
Since this implementation is intended for 3.3.5, we have to use functions
instead. This was a source of a lot of frustration and confusion, but with
some help from the MayronUI Discord community, I was able to break through.

You can find the relevant source code and examine the differences betwen
versions, and how I converted one to the other, on this link:
	https://www.townlong-yak.com/framexml/3.3.0/SecureHandlers.lua

You can find our discussions pretaining to this functionality on this link:
	https://discord.com/channels/473158824514158592/630314441807888394/876383343451713596
-------------------------------------------------------------------------------
3.3.5:
function SecureHandlerWrapScript(frame, script, header, preBody, postBody)
	...
end

4.0.1:
local function SecureHandlerMethod_WrapScript(self, frame, script, preBody, postBody)
	-- Wrapped since args are in different order.
	return SecureHandlerWrapScript(frame, script, self, preBody, postBody);
end
-------------------------------------------------------------------------------
And then later on:
function SecureHandler_OnLoad(self)
    self.Execute = SecureHandlerMethod_Execute;
    self.WrapScript = SecureHandlerMethod_WrapScript;
    self.UnwrapScript = SecureHandlerMethod_UnwrapScript;
    self.SetFrameRef = SecureHandlerMethod_SetFrameRef;
end

Which would essentially equate to:
function SecureHandler:WrapScript(frame, script, preBody, postBody)
	return SecureHandlersWrapScript(frame, script, self, preBody, postBody);
end
-------------------------------------------------------------------------------
Original LAB (script not shown for brevity):
	header:WrapScript(button, 'OnDragStart', [[script]]);

So we have:
	self    := header
	frame   := button
	script  := 'OnDragStart'
	preBody := [[script]]

Which becomes:
	SecureHandlerWrapScript(button, 'OnDragStart', header, [[script]]);
--]==]-------------------------------------------------------------------------
local function CreateButton(
	id,    -- number: Unique id to identify the button.
	name,  -- string: Unique global button name (not used by this lib).
	header -- frame:  The 'parent' of the button, like an action bar.
)
	local button = setmetatable(
		CreateFrame(
			'CheckButton',
			name,
			header,
			'SecureActionButtonTemplate, ActionButtonTemplate'
		),
		Generic_MT
	);

	button.id     = id;
	button.header = header;
	-- (2.0)
	-- We use these tables to map from a state to a type and action.
	button.stateTypes   = {};
	button.stateActions = {};

	-- (2.1)
	-- Default state, in case there is no header for this button.
	-- Other states require a secure header.
	button:SetAttribute('state', 0);

	-- (2.2)
	-- This script is called every time the state of a button changes.
	-- For example, when we drag an ability into a button, its 'state'
	-- attribute becomes 'spell' and its 'action' attribute becomes
	-- an ID representing that spell. Similarly for macros, items, etc.
	-- https://wowwiki-archive.fandom.com/wiki/SecureActionButtonTemplate
	button:SetAttribute('UpdateState', [[
		-- GetAttribute('state') not guaranteed to return
		-- current state in this method!
		local state = ...;
		local stateType   = self:GetAttribute('type-'..state);
		local stateAction = self:GetAttribute('action-'..state);

		print(state, stateType, stateAction);

		self:SetAttribute('type', stateType);
		-- If the type is 'pet' then the action is 'action',
		-- otherwise they are the same.
		local field = (stateType == 'pet') and 'action' or stateType;
		if stateType ~= 'empty' then
			self:SetAttribute(field, stateAction);
			self:SetAttribute('action_field', field);
		end
	]]);

	-- The header invokes (2.2) to update the child's state.
	button:SetAttribute('_childupdate-state', [[
		control:RunFor(self, self:GetAttribute('UpdateState'), message);
		-- Important to run this afterwards.
		self:SetAttribute('state', message);
	]]);

	button:SetScript('OnAttributeChanged', Generic.OnAttributeChanged);
	button:SetScript('OnDragStart',        Generic.OnDragStart);
	button:SetScript('OnReceiveDrag',      Generic.OnReceiveDrag);

	-- (2.3)
	-- This script allows us to pick up whatever was placed into a button.
	-- Example: Abilities, items, macros.
	button:SetAttribute('PickupButton', [[
		local kind, value = ...;

		if kind == 'empty' then
			return 'clear';
		elseif kind == 'action'
		       or kind == 'macro'
		       or kind == 'item'
		       or kind == 'pet'
		then
			local actionType = kind == 'pet'
				    	   and 'petaction'
				           or kind;
		        return actionType, value;
		elseif kind == 'spell'
			-- TODO: Fix, function is unreliable.
			return kind, FindSpellBookSlotBySpellID(value);
		else
			print('LAB: Unknown kind ' .. tostring(kind));
			return false;
		end
	]]);

	-- (2.4)
	-- See [Before we begin] section.
	-- This script will be wrapped around the button's built-in handler
	-- for 'OnDragStart', specifically, before the main body.
	-- Here, we will use (2.3) to allow us to drag things out of buttons.
	SecureHandlerWrapScript(button, 'OnDragStart', header, --[[preBody]] [[
		-- DEBUG:
		print('DragStart');

		local subtype = ...;
		local btnState = self:GetAttribute('state');
		local btnType  = self:GetAttribute('type');
		-- If the button is empty, nothing can be dragged off it.
		if btnType == 'empty' then
			return false;
		end

		local field  = self:GetAttribute('action_field');
		local action = self:GetAttribute(field);
		-- Non-action fields should become empty after dragging off.
		if btnType ~= 'action' and btnType ~= 'pet' then
			self:SetAttribute('type-'  .. btnState, 'empty');
			self:SetAttribute('action-'.. btnState, nil);
			self:RunAttribute('UpdateState', btnState);
		end

		-- And now we use (2.3).
		-- Return button contents for pickup.
		return self:RunAttribute('PickupButton', btnType, btnState);
	]]);

	-- Similarly to (2.4), this script will be wrapped around the handler
	-- for 'OnReceiveDrag', allowing us to drag thins into buttons.
	SecureHandlerWrapScript(button, 'OnReceiveDrag', header, [[
		-- DEBUG:
		print('ReceiveDrag');
		local subtype = ...;
		local btnState  = self:GetAttribute('state');
		local btnType   = self:GetAttribute('type');
		local btnAction = nil;

		--[=[ Nevcairiel comments:
			Action buttons can do their own magic. For all other
			button types, we'll need to update the content now.
		--]=]
		if btnType ~= 'action' and btnType ~= 'pet' then
			-- We get SpellBookID's from CursorInfo.
			-- Convert them to actual SpellID's.
			if kind == 'spell' then
				print(value, subtype);
				local _, spellID, spellType = GetCursorInfo();
				if spellType == 'SPELL' then
					value = spellID;
				else
					-- Other things from the spellbook,
					-- like racial bonuses and whatnot.
					return false;
				end
			end

			-- Get the thing that was on the button previously.
			if btnType ~= 'empty' then
				local field = self:GetAttribute('action_field');
				btnAction   = self:GetAttribute(field);
			end

			-- TODO:
			-- Validate what kind of action is being fed in here.
			-- We can only use a handful of the possible things on
			-- the cursor, and return false for things which can't
			-- be on buttons.
			self:SetAttribute('type-'   .. btnState, kind);
			self:SetAttribute('action-' .. btnState, value);
			self:RunAttribute('UpdateState', btnState);
		else
			-- Get the action for (pet-)action buttons.
			btnAction = self:GetAttribute('action');
		end

		-- See (2.3).
		return self:RunAttribute('PickupButton', btnType, btnState);
	]]);

	button:RegisterForDrag('LeftButton', 'RightButton');
	button:RegisterForClicks('AnyUp');

	-- Easier access to button textures.
	button.icon               = _G[name .. 'Icon'];
	button.flash              = _G[name .. 'Flash'];
	button.flyoutBorder       = _G[name .. 'FlyoutBorder'];
	button.flyoutBorderShadow = _G[name .. 'FlyoutBorderShadow'];
	button.flyoutArrow        = _G[name .. 'FlyoutArrow'];
	button.hotkey             = _G[name .. 'HotKey'];
	button.count              = _G[name .. 'Count'];
	button.actionName         = _G[name .. 'Name'];
	button.border             = _G[name .. 'Border'];
	button.cooldown           = _G[name .. 'Cooldown'];

	return button;
end
--[[---------------------------------------------------------------------------
	3. State management
--]]---------------------------------------------------------------------------
function Generic.ClearStates(self)
	for state, _ in pairs(self.stateTypes) do
		self:SetAttribute('type-'..state, nil);
		self:SetAttribute('action-'..state, nil);
	end
	wipe(self.stateTypes);
	wipe(self.stateActions);
end

function Generic.SetState(self, state, stateType, stateAction)
	local kind = kind or 'empty';
	-- See (3.0).
	-- Nevcairiel must've been very paranoid. Is this necessary?
	state = tonumber(state);

	if not typeMetaMap[kind] then
		error('SetState: Unknown kind ' .. tostring(kind), 2);
	elseif kind ~= 'empty' and not action then
		error('SetState: Action required for non-empty kind.', 2);
	elseif action and not (
		type(action) == 'number' or
		type(action) == 'string'
	) then
		error(
			'SetState: Invalid action type, '..
		      	'only numbers and strings allowed.',
		      	2
		);
	end
	-- See (2.0).
	self.stateTypes[state]   = stateType;
	self.stateActions[state] = stateAction;
	-- Defined below.
	self:UpdateState(state);
end

function Generic.UpdateState(self, state)
	-- See (3.0).
	state = tonumber(state);
	-- (3.1)
	-- We no longer use the state directly, but look up the
	-- type and action in our tables. See (2.0).
	self:SetAttribute('type-'..state, self.stateTypes[state]);
	self:SetAttribute('action-'..state, self.stateActions[state]);

	if state ~= self:GetAttribute('state') then
		return;
	elseif self.header then
		-- These possibly don't exist. See [Before we begin].
		self.header:SetFrameRef('updateButton', self);
		self.header:Execute([[
			local f = self:GetFrameRef('updateButton');
			control:RunFor(
				f,
				f:GetAttribute('UpdateState'),
				f:GetAttribute('state')
			);
		]])
	else
		-- TODO
	end

	-- This is defined later on.
	self:UpdateAction();
end

-- (3.2)
-- See (3.1)
function Generic.GetAction(self, state)
	local state = tonumber(state or self:GetAttribute('state'));
	return self.stateTypes[state], self.stateActions[state];
end

function Generic.UpdateAllStates(self)
	for state, _ in pairs(self.stateTypes) do
		self:UpdateState(state);
	end
end
--[[---------------------------------------------------------------------------
	4. Button management
--]]---------------------------------------------------------------------------
-- For buttons containing stackable items like materials or
-- consumables, we will need to update the displayed counter.
local function UpdateCount(button)
	if button:IsConsumableOrStackable() then
		local count = button:GetCount();
		if count > (button.maxDisplayCount or 9999) then
			button.count:SetText('*');
		else
			button.count:SetText(count);
		end
	else
		button.count:SetText('')
	end
end

-- Toggle the state (checked/unchecked), since we use CheckButtons.
local function UpdateButtonState(button)
	local checked = button:IsCurrentlyActive() or button:IsAutoRepeat();
	self:SetChecked(not checked);
end

-- For buttons containing things like abilities, we will need to update
-- the overlay indicating whether they can be used. For example, abilities
-- fade out when you are out of range, and turn blue when you don't have
-- enough resources to use them.
local function UpdateUsable(button)
	local isUsable, notEnoughMana = button:IsUsable();
	-- TODO: Make the colors configurable.
	-- TODO: Allow disabling of the whole recoloring.
	if isUsable then
		-- White.
		button.icon:SetVertexColor(1.0, 1.0, 1.0);
		button.normalTexture:SetVertexColor(1.0, 1.0, 1.0);
	elseif notEnoughMana then
		-- Dark blue.
		button.icon:SetVertexColor(0.5, 0.5, 1.0);
		button.normalTexture:SetVertexColor(0.5, 0.5, 1.0);
	else
		-- Gray.
		button.icon:SetVertexColor(0.4, 0.4, 0.4);
		button.normalTexture:SetVertexColor(1.0, 1.0, 1.0);
	end
end

local function UpdateCooldown(button)
	-- These parameters are kind of confusing, so I'll explain.
	-- number: The timestamp of when the cooldown began (see GetTime()).
	-- number: Cooldown duration in seconds.
	-- number: 0 for toggled abilities like Stealth. Their cooldown begins
	--         when they are toggled off. 1 otherwise.
	local start, duration, enabled = button:GetCooldown();
	CooldownFrame_SetTimer(button.cooldown, start, duration, enabled);
end

-- See (4.0).
-- Could we somehow combine these two?
-- Or refactor such that they aren't necessary?
local function StartFlash(button)
	button.flashing = true;
	button.flashtime = 0;
	UpdateButtonState(button);
end

-- See (4.0).
local function StopFlash(button)
	button.flashing = false;
	button.flash:Hide();
	UpdateButtonState(button);
end

-- (4.0)
-- Auto-attack, shoot/wand and toggleable abilities flash
-- while they are active.
local function UpdateFlash(button)
	local active = button:IsAttack()
		       and button:IsCurrentlyActive()
		       or  button:IsAutoRepeat();
	if active then
		StartFlash(button);
	else
		StopFlash(button);
	end
end


local function UpdateTooltip(button)
	if (GetCVar('UberTooltips') == '1') then
		GameTooltip_SetDefaultAnchor(GameTooltip, button);
	else
		GameTooltip:SetOwner(button, 'ANCHOR_RIGHT');
	end
	if button:SetTooltip() then
		button.UpdateTooltip = UpdateTooltip;
	else
		button.UpdateTooltip = nil;
	end
end

local function UpdateHotkeys(button)
	local key = GetBindingKey(string.format(
		'CLICK %s:LeftButton', button:GetName()
	));
	local text = GetBindingText(key, 'KEY_', 1);

	if text then
		button.hotkey:SetText(text);
		button.hotkey:SetPoint('TOPLEFT', button, 'TOPLEFT', -2, -2);
		button.hotkey:Show();
	else
		button.hotkey:SetText(RANGE_INDICATOR);
		button.hotkey:SetPoint('TOPLEFT', button, 'TOPLEFT', 1, -2);
		button.hotkey:Hide();
	end
end

--[[---------------------------------------------------------------------------
	5. Main update function
--]]---------------------------------------------------------------------------
local function Update(button)
	-- In your interface options, you can tick 'always show action bars'.
	-- If you don't, empty buttons will be hidden.
	-- This models similar behaviour.
	if button:IsEmpty() then
		-- TODO: Hide button.
		button.cooldown:Hide();
	else
		-- TODO: Show button.
		UpdateButtonState(button);
		UpdateUsable(button);
		UpdateCooldown(button);
		UpdateFlash(button);
	end

	-- If you put an item into a button, it will have a green border.
	if button:IsEquipped() then
		-- Green.
		button.border:SetVertexColor(0, 1.0, 0, 0.35);
		button.border:Show();
	else
		button.border:Hide();
	end

	-- Is this necessary?
	if button:IsConsumableOrStackable() then
		button.actionName:SetText('');
	else
		button.actionName:SetText(button:GetActionText());
	end

	-- Update icon and hotkey.
	local texture = button:GetTexture();
	if texture then
		button.icon:SetTexture(texture);
		button.icon:Show();
		button.rangeTimer = -1;
		button:SetNormalTexture('Interface\\Buttons\\UI-Quickslot2');
	else
		button.icon:Hide();
		button.cooldown:Hide();
		button.rangeTimer = nil;
		button:SetNormalTexture('Interface\\Buttons\\UI-Quickslot');
		if button.hotkey:GetText() == RANGE_INDICATOR then
			button.hotkey:Hide();
		else
			-- Gray.
			button.hotkey:SetVertexColor(0.6, 0.6, 0.6);
		end
	end

	-- See (5.0)
	button:UpdateLocal();
	UpdateCount(button);

	-- TODO: Update flyout.
	-- TODO: Update Overlay Glow.
	if GameTooltip:GetOwner() == button then
		UpdateTooltip();
	end
end

-- (5.0)
-- Dummy function the other button types can override for special updating.
function Generic.UpdateLocal(self)

end

function Generic.UpdateAction(self, force)
	-- See (3.2)
	local stateType, stateAction = self:GetAction();

	if stateType ~= self._state_type then
		-- See (1.2)
		local mt = typeMetaMap[stateType] or typeMetaMap['empty'];
		setmetatable(self, mt);
		self._state_type   = stateType;
		self._state_action = stateAction;
		Update(self);
		return true;
	elseif force or stateAction ~= self._state_action then
		self._state_action = stateAction;
		Update(self);
		return true;
	end

	return false;
end


--[[---------------------------------------------------------------------------
	6. WoW API mapping
--]]---------------------------------------------------------------------------
-- (6.0)
-- Generic button
function Generic.IsEmpty                (self) return true; end
function Generic.GetActionText          (self) return '';   end
function Generic.GetTexture             (self) return nil;  end
function Generic.GetCount               (self) return 0;    end
function Generic.GetCooldown            (self) return nil;  end
function Generic.IsAttack               (self) return nil;  end
function Generic.IsEquipped             (self) return nil;  end
function Generic.IsCurrentlyActive      (self) return nil;  end
function Generic.IsAutoRepeat           (self) return nil;  end
function Generic.IsUsable               (self) return nil;  end
function Generic.IsInRange              (self) return nil;  end
function Generic.SetTooltip             (self) return nil;  end
function Generic.IsConsumableOrStackable(self) return nil;  end

-- (6.1)
-- Action button
function Action.IsEmpty          (self) return not HasAction(self._state_action);         end
function Action.GetActionText    (self) return GetActionText(self._state_action);         end
function Action.GetTexture       (self) return GetActionTexture(self._state_action);      end
function Action.GetCount         (self) return GetActionCount(self._state_action);        end
function Action.GetCooldown      (self) return GetActionCooldown(self._state_action);     end
function Action.IsAttack         (self) return IsAttackAction(self._state_action);        end
function Action.IsEquipped       (self) return IsEquippedAction(self._state_action);      end
function Action.IsCurrentlyActive(self) return IsCurrentAction(self._state_action);       end
function Action.IsAutoRepeat     (self) return IsAutoRepeatAction(self._state_action);    end
function Action.IsUsable         (self) return IsUsableAction(self._state_action);        end
function Action.IsInRange        (self) return IsActionInRange(self._state_action);       end
function Action.SetTooltip       (self) return GameTooltip:SetAction(self._state_action); end
function Action.IsConsumableOrStackable(self)
	return IsConsumableAction(self._state_action)
	       or IsStackableAction(self._state_action);
end

-- (6.2)
-- Spell button
function Spell.HasAction              (self) return true;                                         end
function Spell.GetActionText          (self) return '';                                           end
function Spell.GetTexture             (self) return GetSpellTexture(self._state_action);          end
function Spell.GetCount               (self) return GetSpellCount(self._state_action);            end
function Spell.GetCooldown            (self) return GetSpellCooldown(self._state_action);         end
function Spell.IsAttack               (self) return IsAttackSpell(self._state_action);            end
function Spell.IsEquipped             (self) return false;                                        end
function Spell.IsCurrentlyActive      (self) return IsCurrentSpell(self._state_action);           end
function Spell.IsAutoRepeat           (self) return IsAutoRepeatSpell(self._state_action);        end
function Spell.IsUsable               (self) return IsUsableSpell(self._state_action);            end
function Spell.IsConsumableOrStackable(self) return IsConsumableSpell(self._state_action);        end
function Spell.IsInRange              (self) return IsSpellInRange(self._state_action, 'target'); end
function Spell.SetTooltip             (self) return GameTooltip:SetSpellByID(self._state_action); end

--[[---------------------------------------------------------------------------
	7. Frame scripts
--]]---------------------------------------------------------------------------
function Generic.OnAttributeChanged(self, attribute, value)
	if attribute == 'state' then
		self:Update();
	end
end

function Generic.OnDragStart(self)
	if not self:UpdateAction() then
		UpdateButtonState(self);
		UpdateFlash(self);
	end
end

function Generic.OnReceiveDrag(self)
	if not self:UpdateAction() then
		UpdateButtonState(self);
		UpdateFlash(self);
	end
end
--[[---------------------------------------------------------------------------
	End of LibActionButton code
--]]---------------------------------------------------------------------------
local function HideBlizzard()
	ChatFrame1:Hide();
	ChatFrame1ButtonFrame:Hide();
	ChatFrameMenuButton:Hide();
	FriendsMicroButton:Hide();

	PlayerFrame:Hide();

	BuffFrame:Hide();
	Minimap:Hide();
	MinimapCluster:Hide();

	WatchFrame:Hide();

	MultiBarLeft:Hide();
	MultiBarRight:Hide();
	MultiBarBottomLeft:Hide();
	MultiBarBottomRight:Hide();

	MainMenuBar:Hide();
end

function PNK_Scratchpad.scratch(...)
	HideBlizzard();

	for i = 1, 12 do
		local button = CreateButton(i, 'ExampleButton'..i, UIParent);
		button:SetWidth(buttonSize);
		button:SetHeight(buttonSize);
		button:SetPoint(
			'BOTTOMLEFT',
			UIParent,
			'BOTTOM',
			(i - 6) * buttonSize,
			13
		);
		button:Show();
	end
end
