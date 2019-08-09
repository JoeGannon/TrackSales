TrackSales.db = TrackSales:NewModule("DB", "AceConsole-3.0")

local _, ts = ...

function TrackSales.db:TrackSale(item, gold)

	local matchedProfession = ts:MatchProfession(item)

	if matchedProfession ~= nil then 
		self:AddGold(matchedProfession, gold)
	end
end

function TrackSales.db:AddGold(profession, gold)

	local prof = self:FindTrackedProfession(profession)

	if prof then
		local goldMade = prof.GoldMade + gold

		--things get weird when the value is set to negative
		if goldMade < 0 then 
			prof.GoldMade = 0
		else 
			prof.GoldMade = goldMade
		end

		return
	end
end

function TrackSales.db:SubtractGold(profession, gold)
	
	self:AddGold(profession, -gold)
end

function TrackSales.db:SetGold(profession, gold)

	local prof = self:FindTrackedProfession(profession)

	if prof then 
		prof.GoldMade = gold
		return 
	end

   self:Print("Profession Not Found "..profession)
end

local professions = {
	"Alchemy",
	"Blacksmithing",
	"Enchanting",
	"Engineering",
	"Herbalism",
	"Leatherworking",
	"Mining",
	"Skinning",
	"Tailoring",
	"Cooking",
	"First Aid",
	"Fishing"
}

function TrackSales.db:TryAddNewProfession(profession, log)

	local arg = profession:gsub("^%l", string.upper)
	
	local prof = self:FindTrackedProfession(arg)

	if prof and prof.Name == arg then 
		return 
	end	

	profession = self:ConsoleHack(profession, true)

	for index, value in ipairs(professions) do
		if value == profession then		
			local prof = { 
					Name = profession,
					GoldMade = 0,
					IsVisible = true 
				}
			
			table.insert(TrackSalesDB.Professions, prof)

			TrackSales:PrintMessage("Now tracking "..prof.Name)
			return
		end	
	end	

	if log then
		TrackSales:PrintMessage("Profession not found "..profession)
	end
end

function TrackSales.db:RemoveProfession(profession)	
	 
	profession = self:ConsoleHack(profession) 		

	for index, value in ipairs(TrackSalesDB.Professions) do
		if (value.Name == profession) then 
			table.remove(TrackSalesDB.Professions, index)
			TrackSales:PrintMessage(profession.." removed")
			return
		end
	end

	TrackSales:PrintMessage("Profession not found "..profession)
end

function TrackSales.db:ShowProfession(profession)	
	 
	profession = self:ConsoleHack(profession) 

	local prof = self:FindTrackedProfession(profession)

	if prof then 
		prof.IsVisible = true
		TrackSales:PrintMessage(profession.." is now shown")
		return
	end

	TrackSales:PrintMessage("Profession not found "..profession)
end

function TrackSales.db:HideProfession(profession)	
	 
	profession = self:ConsoleHack(profession) 

	local prof = self:FindTrackedProfession(profession)
	 
	 if prof then		
		prof.IsVisible = false
		TrackSales:PrintMessage(profession.." is now hidden")
		return		
	 end

	TrackSales:PrintMessage("Profession not found "..profession)
end

function TrackSales.db:OrderProfessions(order)

	local items = 0;
	local indexes = { }
	local hasDupes = false			
 	local test = false
	order:gsub(".", function(idx)
		items = items + 1
		local dupes = ts:ContainsItem(indexes, idx)		
		
		table.insert(indexes, idx)	
		
		if dupes then 			
			hasDupes = true
			return
		end		
	end)	
	
	local maxIndex = self:MaxOrderIndex()

	if hasDupes then 
		TrackSales:PrintMessage("Found duplicate Indexes! Must specify each index once")
		return
	end
	if items > maxIndex then
		TrackSales:PrintMessage("Too many Indexes provivded!")
		TrackSales:PrintMessage("There are only "..maxIndex.." visible Indexes. You provided "..items)
		return 
	end
	if items < maxIndex then
		TrackSales:PrintMessage("Too few Indexes provivded!")
		TrackSales:PrintMessage("There are "..maxIndex.." visible Indexes. You provided "..items)
		return 
	end	
	
	for index, value in ipairs(indexes) do 
	
		if tonumber(value) > maxIndex then 
			TrackSales:PrintMessage("Invalid Index "..value)
			return
		end		
	end

	local newOrder = { }
	local isVisibleIndex = 0

	for index, value in ipairs(indexes) do 
		isVisibleIndex = 0
		for i, prof in ipairs(TrackSalesDB.Professions) do 			

			if prof.IsVisible then 
				isVisibleIndex = isVisibleIndex + 1
			end

			if prof.IsVisible and isVisibleIndex == tonumber(value) then 				
				table.insert(newOrder, prof)
			end
		end
	end	

	for i, prof in ipairs(TrackSalesDB.Professions) do 			
		if not prof.IsVisible then 
			table.insert(newOrder, prof)
		end
	end	

	TrackSalesDB.Professions = newOrder

	return true
end

--hack to allow /ts p FirstAid a
--First Aid is parsed as 2 arguments
function TrackSales.db:ConsoleHack(arg, superHack)	
	arg = arg:gsub("^%l", string.upper)

	if string.lower(arg) == "firstaid" then
		arg = "First Aid"
	end	

	return arg
end

function TrackSales.db:FindTrackedProfession(profession)
	
	for index, value in ipairs(TrackSalesDB.Professions) do 
		if value.Name == profession then
			return value 
		end
	end

	return nil
end

function TrackSales.db:SetDefaults()
	
	TrackSalesDB = {
		Professions = {	}	 
	 }

	 for skillIndex = 1, GetNumSkillLines() do
		local skillName, isHeader = GetSkillLineInfo(skillIndex)
		  if not isHeader and ts:ContainsItem(professions, skillName) then
			local profession =  {
				  Name = skillName,
				  GoldMade = 0, 
				  IsVisible = true 
				}
		   table.insert(TrackSalesDB.Professions, profession)		   
		end
	end		
end

function TrackSales.db:MaxOrderIndex()	
	local i = 0
	
	for index, value in ipairs(TrackSalesDB.Professions) do 
		if value.IsVisible then 
			i = i + 1
		end		
	end

	return i
end

-- function TrackSales.db:Clear()

-- 	TrackSalesDB = nil

-- 	self:Print("Database cleared")

-- end 

-- function TrackSales.db:RunTests()
	
-- 	DEFAULT_CHAT_FRAME.editBox:SetText("/ts t fishing a")
-- 	ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
	
-- 	self:TestResult("Add Fishing")		
	
-- 	DEFAULT_CHAT_FRAME.editBox:SetText("/ts b fishing a 20000")
-- 	ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
	
-- 	self:TestResult("Add 2 gold to fishing")

-- 	DEFAULT_CHAT_FRAME.editBox:SetText("/ts b fishing s 10000")
-- 	ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
	
-- 	self:TestResult("Subtract 1 gold from fishing")

-- 	DEFAULT_CHAT_FRAME.editBox:SetText("/ts b fishing set 5000")
-- 	ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
	
-- 	self:TestResult("Set fishing to 50 silver")

-- 	DEFAULT_CHAT_FRAME.editBox:SetText("/ts t cooking a")
-- 	ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
	
-- 	self:TestResult("Add Cooking")

-- 	self:TrackSale("Coyote Steak", 10000)

-- 	self:TestResult("Add Tracked Cooking")

-- 	DEFAULT_CHAT_FRAME.editBox:SetText("/ts d o 21")
-- 	ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
	
-- 	self:TestResult("Reorder")

-- 	DEFAULT_CHAT_FRAME.editBox:SetText("/ts d cooking hide")
-- 	ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
	
-- 	self:TestResult("Hide Cooking")

-- 	DEFAULT_CHAT_FRAME.editBox:SetText("/ts d cooking show")
-- 	ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
	
-- 	self:TestResult("show Cooking")

-- 	DEFAULT_CHAT_FRAME.editBox:SetText("/ts t cooking r")
-- 	ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
	
-- 	self:TestResult("remove cooking")
-- end

-- function TrackSales.db:TestResult(test)
-- 	self:Print(test)
-- 	self:Print("--------")
-- 	DEFAULT_CHAT_FRAME.editBox:SetText("/ts")
-- 	ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
-- 	self:Print("--------")
-- end