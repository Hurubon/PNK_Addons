--[[---------------------------------------------------------------------------
	Generic function for creating lines on a grid.
--]]---------------------------------------------------------------------------
local function createLines(grid, count, Setup)
	for i = 1, count do
		local line = grid.unusedLines:Top();

		if line then
			grid.unusedLines:Pop();
		else
			line = grid:CreateTexture();
			grid.activeLines:Push(line);
		end

		Setup(grid, line, i);
	end
end

--[[---------------------------------------------------------------------------
	Member functions
--]]---------------------------------------------------------------------------
function PNK_Align.grid.Create(self, parent, thickness, spacing)
	self:SetParent(parent);
	self:SetAllPoints(parent);

	local width  = self:GetWidth();
	local height = self:GetHeight();

	local function rightLinesSetup(grid, line, i)
		line:SetTexture(PNK_Align.meta.theme.gridLines.WowRGBA());
		line:SetSize(thickness, height);
		line:SetPoint('CENTER', grid, 'CENTER', spacing * i, 0);
	end;
	local function leftLinesSetup(grid, line, i)
		line:SetTexture(PNK_Align.meta.theme.gridLines.WowRGBA());
		line:SetSize(thickness, height);
		line:SetPoint('CENTER', grid, 'CENTER', -spacing * i, 0);
	end;
	local function upperLinesSetup(grid, line, i)
		line:SetTexture(PNK_Align.meta.theme.gridLines.WowRGBA());
		line:SetSize(width, thickness);
		line:SetPoint('CENTER', grid, 'CENTER', 0, spacing * i);
	end;
	local function lowerLinesSetup(grid, line, i)
		line:SetTexture(PNK_Align.meta.theme.gridLines.WowRGBA());
		line:SetSize(width, thickness);
		line:SetPoint('CENTER', grid, 'CENTER', 0, -spacing * i);
	end;
	local function axesSetup(grid, line, i)
		line:SetTexture(PNK_Align.meta.theme.axes.WowRGBA());

		if i == 1 then
			line:SetSize(thickness, height);
		else
			line:SetSize(width, thickness);
		end

		line:SetPoint('CENTER');
	end;

	createLines(self, floor(width  / spacing / 2), rightLinesSetup);
	createLines(self, floor(width  / spacing / 2), leftLinesSetup);
	createLines(self, floor(height / spacing / 2), upperLinesSetup);
	createLines(self, floor(height / spacing / 2), lowerLinesSetup);

	createLines(self, 2, axesSetup);
end

function PNK_Align.grid.Destroy(self)
	for i = 1, self.activeLines:Size() do
		local line = self.activeLines:Top();
		self.unusedLines:Push(line);
		self.activeLines:Pop();
	end
end
