--[[---------------------------------------------------------------------------
	Member functions
--]]---------------------------------------------------------------------------
function PNK_Stack.Construct(self)
	local stack = setmetatable({ container = {} }, self);
	self.__index = self;
	return stack;
end

-- Element access
function PNK_Stack.Top(self)
	return self.container[self:Size()];
end

-- Capacity
function PNK_Stack.Empty(self)
	return self.container[1] == nil;
end

function PNK_Stack.Size(self)
	return #self.container;
end

-- Modifiers
function PNK_Stack.Push(self, value)
	self.container[self:Size() + 1] = value;
end

function PNK_Stack.Pop(self)
	self.container[self:Size()] = nil;
end

function PNK_Stack.Swap(self, other)
	local container = self.container;
	self.container  = other.container;
	other.container = container;
end

function PNK_Stack.Wipe(self)
	wipe(self.container);
end

--[[---------------------------------------------------------------------------
	Non-member functions
--]]---------------------------------------------------------------------------
function PNK_Stack.Compare(lhs, rhs, Predicate)
	if not (
		getmetatable(lhs) == PNK_Stack or
		getmetatable(rhs) == PNK_Stack
	) then
		return nil;
	elseif lhs:Size() ~= rhs:Size() then
		return false;
	end

	local lhs = lhs.container;
	local rhs = rhs.container;

	-- We've established #lhs == #rhs.
	for i = 1, #lhs do
		if not Predicate(lhs[i], rhs[i]) then
			return false;
		end
	end

	return true;
end

function PNK_Stack.__eq(lhs, rhs) -- a == b
	return PNK_Stack.Compare(lhs, rhs, function(a, b) return a == b end);
end

function PNK_Stack.__le(lhs, rhs) -- a <= b
	return PNK_Stack.Compare(lhs, rhs, function(a, b) return a <= b end);
end

function PNK_Stack.__lt(lhs, rhs) -- a < b
	return PNK_Stack.Compare(lhs, rhs, function(a, b) return a < b end);
end
