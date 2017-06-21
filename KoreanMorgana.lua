class "KoreanMorgana"

function KoreanMorgana:__init()
	

    self.spellNames = {
    		{name = "Q", buffName = ""},
    		{name = "R", buffName = "soulshackles"},
    		{name = "RStunned", buffName = "soulshacklesstunsound"}
	}

    self:LoadSpells()
    self:LoadMenu()
    Callback.Add("Draw", function() self:Draw() end)

    self.predictionModified = {champion = "Ezreal", dodger = false}
    self.misscount = 0
end

function KoreanMorgana:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "KoreanMorgana", name = "Korean Morgana", leftIcon = "http://i.imgur.com/B1yTPrK.png"})
	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Korean Morgana - Combo Settings"})
	self.Menu.Combo:MenuElement({id = "ComboQ", name = "Use Q", value = true})
	self.Menu.Combo:MenuElement({id = "ComboW", name = "Use W", value = true})
	self.Menu.Combo:MenuElement({id = "ComboE", name = "Use E", value = true})
	self.Menu:MenuElement({type = MENU, id = "Prediction", name = "Korean Morgana - xPrediction Settings"})
	self.Menu.Prediction:MenuElement({id = "Am", name = "Prediction Range", value = 80, min = 20, max = 200})
	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Korean Morgana - Harass Settings"})
	self.Menu.Harass:MenuElement({id = "CS", name = "Comming Soon.", value = true})
	self.Menu:MenuElement({type = MENU, id = "Draw", name = "Korean Morgana - Draw Settings"})
	self.Menu.Draw:MenuElement({id = "DrawQ", name = "Q Range", value = true})
	self.Menu.Draw:MenuElement({id = "DrawW", name = "W Range", value = true})
	self.Menu.Draw:MenuElement({id = "DrawE", name = "E Range", value = true})
	self.Menu.Draw:MenuElement({id = "DrawR", name = "R Range", value = true})
	
end

function KoreanMorgana:LoadSpells()
	Q = {Range = 850, Delay = myHero:GetSpellData(_Q).delay, Radius = 235, Speed = myHero:GetSpellData(_Q).speed}
	W = {Range = 900, Delay = myHero:GetSpellData(_W).delay, Radius = 275, Speed = 0}
	E = {Range = 800, Delay = myHero:GetSpellData(_E).delay, Radius = 0, Speed = 0}
	R = {Range = 625, Delay = myHero:GetSpellData(_R).delay, Radius = myHero:GetSpellData(_R).radius, Speed = 0}
end

function KoreanMorgana:xPath(unit)
	local hero = unit
	local path = hero.pathing
	local path_vec
	

		if path.hasMovePath then
			for i = path.pathIndex, path.pathCount do
				path_vec = hero:GetPath(i)
				
			end
		end
		
		return path_vec
end

function KoreanMorgana:IsValidTarget(unit,range)
	return unit ~= nil and unit.valid and unit.visible and not unit.dead and unit.isTargetable and not unit.isImmortal and unit.pos:DistanceTo(myHero.pos) <= range
end

function KoreanMorgana:CanUseSpell(spell)
	return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana
end

function KoreanMorgana:Buffs(unit, buffname)
	

	local textPos2 = unit.pos:To2D()
	textOffset = 50

	local activeBuffs = {}

	for i = 0, unit.buffCount do
		local Buff = unit:GetBuff(i)
		if Buff.count > 0 then
			table.insert(activeBuffs, Buff)
		end
	end
	for i, Buff in pairs(activeBuffs) do
		if Buff.name:lower() == buffname:lower() then
			return true
		end
	end
	return false
end

local timer = {start = 0, tick = GetTickCount()} 
function KoreanMorgana:Timer(mindelay, maxdelay)
	local ticker = GetTickCount()
	if timer.start == 0 then
		timer.start = 1
		timer.tick = ticker
	end

	if timer.start == 1 then
		if ticker - timer.tick > mindelay and ticker - timer.tick < maxdelay then
			timer.start = 0
			return true
		end
	end

	return false

end

function  KoreanMorgana:Check(target)
	if self:Buffs(target, "darkbindingmissle") == false then 
		if self.predictionModified.dodger == false then
			self.predictionModified.dodger = true 
			self.misscount = self.misscount + 1
		elseif self.predictionModified.dodger == true then
			self.predictionModified.dodger = false

		end
	end
end

local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
function KoreanMorgana:CastSpell(spell, pos, range, tvec, delay)
	local ticker = GetTickCount()

	if castSpell.state == 0 and pos:DistanceTo(tvec) < range and ticker - castSpell.casting > delay and pos:ToScreen().onScreen then
		castSpell.state = 1
		castSpell.mouse = mousePos
		castSpell.tick = ticker
	end

	if castSpell.state == 1 then
		if ticker - castSpell.tick < Game.Latency() then
			Control.SetCursorPos(pos)
			Control.CastSpell(spell, pos)
			castSpell.casting = ticker + delay
			DelayAction(function() if castSpell.state == 1 then Control.SetCursorPos(castSpell.mouse) castSpell.state = 0 end end, 1)
		end
		if ticker - castSpell.casting > 80 then
			
			castSpell.state = 0
		end
	end
end



function KoreanMorgana:Prediction()
	local target = (_G.GOS and _G.GOS:GetTarget(800, "AD"))
	if target == nil then return end
	local pathingVector = self:xPath(target)
	local distanceToTarget = myHero.pos:DistanceTo(target.pos)
	local predictionVector
	if self.predictionModified.dodger == true then
		predictionVector = target.pos:Shortened(pathingVector, (distanceToTarget / 4) + target.ms - (self.Menu.Prediction.Am:Value() + 500))
		if predictionVector:DistanceTo(target.pos) < 700 then
		if self:CanUseSpell(_Q) and target:GetCollision(Q.width,Q.speed,Q.delay) == 0 then
			self:CastSpell(HK_Q, predictionVector, 700, target.pos, 80)
		end

		if myHero:GetSpellData(_Q).currentCd >= 9 and myHero:GetSpellData(_Q).currentCd <= 10 then
			self:Check(target)
		end
	end
	elseif self.predictionModified.dodger == false then
		predictionVector = target.pos:Extended(pathingVector, (distanceToTarget / 3) + target.ms - (self.Menu.Prediction.Am:Value() + 220) )
		if predictionVector:DistanceTo(target.pos) < 700 then
		if self:CanUseSpell(_Q) and target:GetCollision(Q.width,Q.speed,Q.delay) == 0  then
			self:CastSpell(HK_Q, predictionVector, 700, target.pos, 80)
		end

		if myHero:GetSpellData(_Q).currentCd >= 9 and myHero:GetSpellData(_Q).currentCd <= 10 then
			self:Check(target)
		end
	end
			
	end

	Draw.Circle(predictionVector)
	
end
function KoreanMorgana:AutoW()
	local target =  (_G.GOS and _G.GOS:GetTarget(1000,"AD"))
	if self:IsValidTarget(target, W.Range) and self:IsReady(_W) and self:IsSnared(target) then
		Control.CastSpell(HK_W, target.pos2D.x + 30, target.pos2D.y - 20)
	end
end

function KoreanMorgana:IsSnared(unit)
	for i = 0, unit.buffCount do
			if unit:GetBuff(i).type == 11 or unit:GetBuff(i).type == 5 then
				return true
			end
	end
	return false
end

function KoreanMorgana:IsReady (spell)
	return Game.CanUseSpell(spell) == 0 
end

function KoreanMorgana:AutoE()
if self:IsReady(_E) then
	local threat
	for i = 1, Game.HeroCount() do
		local hero = Game.Hero(i)
		if self:IsValidTarget(hero, 1100) and hero.isChanneling then
			local currSpell = hero.activeSpell
			local sRadious = 100
			local spellPos = Vector(currSpell.placementPos.x, currSpell.placementPos.y, currSpell.placementPos.z)
			if spellPos:DistanceTo(myHero.pos) < 100 then
				Control.CastSpell(HK_E, myHero.pos)
			end
			
		end
	end
end
end

function KoreanMorgana:Draw()
	
	if (_G.GOS and _G.GOS:GetMode() == "Combo") then
		if self.Menu.Combo.ComboQ:Value() then
			self:Prediction()
			self:AutoW()
		end
	end


	if self.Menu.Draw.DrawQ:Value() then
		Draw.Circle(myHero.pos, Q.Range, 1, Draw.Color(255, 255, 255, 255))
	end
	if self.Menu.Draw.DrawW:Value() then
		Draw.Circle(myHero.pos, W.Range, 1, Draw.Color(255, 255, 255, 255))
	end
	if self.Menu.Draw.DrawE:Value() then
		Draw.Circle(myHero.pos, E.Range, 1, Draw.Color(255, 255, 255, 255))
	end
	if self.Menu.Draw.DrawR:Value() then
		Draw.Circle(myHero.pos, R.Range, 1, Draw.Color(255, 255, 255, 255))
	end
	
	
end

function OnLoad()
	KoreanMorgana()
end

