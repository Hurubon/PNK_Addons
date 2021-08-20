PNK_Stack.meta.tests = {};

function PNK_Stack.meta.tests.ConstructTest()
	local stack = PNK_Stack:Construct();

	assert(getmetatable(stack) == PNK_Stack);
	assert(stack:Empty());
	assert(stack:Top() == nil);
end

function PNK_Stack.meta.tests.SizeTest(n)
	local n     = n or 10;
	local stack = PNK_Stack:Construct();

	for i = 1, n do
		stack:Push(math.random());
	end

	assert(stack:Size() == n);
end

function PNK_Stack.meta.tests.PushTest()
	local stack = PNK_Stack:Construct();
	local value = math.random();

	stack:Push(value);

	assert(stack:Top() == value);
end

function PNK_Stack.meta.tests.PopTest()
	local stack = PNK_Stack:Construct();
	local value = math.random();
	stack:Push(value);

	stack:Pop();

	assert(stack:Empty());
end

function PNK_Stack.meta.tests.SwapTest(n, m)
	local n      = n or 10;
	local m      = m or 20;
	local stack1 = PNK_Stack:Construct();
	local stack2 = PNK_Stack:Construct();
	local array1 = {};
	local array2 = {};

	for i = 1, n do
		local value = math.random();
		table.insert(array1, value);
		stack1:Push(value);
	end
	for i = 1, m do
		local value = math.random();
		table.insert(array2, value);
		stack2:Push(value);
	end

	local size1 = stack1:Size();
	local size2 = stack2:Size();
	stack1:Swap(stack2);

	assert(stack1:Size() == size2);
	assert(stack2:Size() == size1);
	for i = m, 1, -1 do
		assert(stack1:Top() == array2[i]);
		stack1:Pop();
	end
	for i = n, 1, -1 do
		assert(stack2:Top() == array1[i]);
		stack2:Pop();
	end
end

function PNK_Stack.meta.tests.SwapIndempotenceTest(n, m)
	local n      = n or 10;
	local m      = m or 20;
	local stack1 = PNK_Stack:Construct();
	local stack2 = PNK_Stack:Construct();
	local stack1Copy = PNK_Stack:Construct();
	local stack2Copy = PNK_Stack:Construct();

	for i = 1, n do
		local value = math.random();
		stack1:Push(value);
		stack1Copy:Push(value);
	end
	for i = 1, m do
		local value = math.random();
		stack2:Push(value);
		stack2Copy:Push(value);
	end

	stack1:Swap(stack2);
	stack1:Swap(stack2);

	assert(stack1 == stack1Copy);
	assert(stack2 == stack2Copy);
end

function PNK_Stack.meta.tests.WipeTest(n)
	local n     = n or 10;
	local stack = PNK_Stack:Construct();
	for i = 1, n do
		stack:Push(math.random());
	end

	stack:Wipe();

	assert(stack:Empty());
end

function PNK_Stack.meta.tests.EqualityTest(n)
	local n      = n or 10;
	local stack1 = PNK_Stack:Construct();
	local stack2 = PNK_Stack:Construct();

	assert(stack1 == stack2);

	for i = 1, n do
		local value = math.random();
		stack1:Push(value);
		stack2:Push(value);
	end

	assert(stack1 == stack2);
end

function PNK_Stack.meta.tests.InequalityTest(n)
	local n      = n or 10;
	local stack1 = PNK_Stack:Construct();
	local stack2 = PNK_Stack:Construct();

	for i = 1, n do
		local value = math.random();
		stack1:Push(value);
		stack2:Push(value + math.random(1, 2));
	end

	-- This stack should be bigger.
	stack2:Push(math.random());

	assert(stack1 ~= stack2);

	stack2:Pop();
	-- Even when they're the same size,
	-- their elements differ.
	assert(stack1 ~= stack2);

end

function PNK_Stack.meta.tests.LessThanTest(n)
	local n     = n or 10;
	local stack1 = PNK_Stack:Construct();
	local stack2 = PNK_Stack:Construct();

	assert(stack1 <= stack2);

	for i = 1, n do
		local value = math.random();
		stack1:Push(value);
		stack2:Push(value + math.random(0, 1));
	end

	assert(stack1 <= stack2);
end

function PNK_Stack.meta.tests.StrictlyLessTest(n)
	local n      = n or 10;
	local stack1 = PNK_Stack:Construct();
	local stack2 = PNK_Stack:Construct();

	for i = 1, n do
		local value = math.random();
		stack1:Push(value);
		stack2:Push(value + math.random(1, 2));
	end

	assert(stack1 < stack2);
end
