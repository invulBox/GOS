class "KoreanThresh"

function KoreanThresh:__init()
	if myHero.charName ~= "Thresh" then 
		return
	end
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Draw", function() self:Draw() end)
	Callback.Add("Tick", function() self:Tick() end)

	self.lastTick = GetTickCount()
	self.startECombo = false
	self.startQERCombo = false

	self.predictionModified = {champion = "Ezreal", dodger = false}
    self.misscount = 0
    self.qHit = false
end

function KoreanThresh:LoadSpells()
	Q = {Range = myHero:GetSpellData(_Q).range, Delay = myHero:GetSpellData(_Q).delay, Radius = myHero:GetSpellData(_Q).radius, Speed = myHero:GetSpellData(_Q).speed}
	W = {Range = 900, Delay = myHero:GetSpellData(_W).delay, Radius = 275, Speed = 0}
	E = {Range = 800, Delay = myHero:GetSpellData(_E).delay, Radius = 0, Speed = 0}
	R = {Range = 625, Delay = myHero:GetSpellData(_R).delay, Radius = myHero:GetSpellData(_R).radius, Speed = 0}
end

function KoreanThresh:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "KoreanThresh", name = "Korean Thresh", leftIcon = "http://i.imgur.com/B1yTPrK.png"})
	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Korean Thresh - Combo Settings"})
	self.Menu.Combo:MenuElement({id = "HailMary", name = "Allow HailMary Q For KT Mata Engage", value = false})
	self.Menu.Combo:MenuElement({id = "KTMataEngage", name = "KT Mata Engage [E->AA->Q]", value = true})
	self.Menu.Combo:MenuElement({id = "SKTT1WolfCombo", name = "SKT T1 Wolf Combo [Q->R->AA->E]", value = true})
	self.Menu.Combo:MenuElement({id = "HotKeyChanger", name = "Quick Hotkey Changer", key = 0x5a, toggle = true, value = true})
	self.Menu:MenuElement({type = MENU, id = "Prediction", name = "Korean Thresh - xPrediction Settings"})
	self.Menu.Prediction:MenuElement({id = "Am", name = "Prediction Range", value = 80, min = 20, max = 200})
	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Korean Thresh - Harass Settings"})
	self.Menu.Harass:MenuElement({id = "CS", name = "Comming Soon.", value = true})
	self.Menu:MenuElement({type = MENU, id = "Draw", name = "Korean Thresh - Draw Settings"})
	self.Menu.Draw:MenuElement({id = "DrawQ", name = "Q Range", value = true})
	self.Menu.Draw:MenuElement({id = "DrawW", name = "W Range", value = true})
	self.Menu.Draw:MenuElement({id = "DrawE", name = "E Range", value = true})
	self.Menu.Draw:MenuElement({id = "DrawR", name = "R Range", value = true})
	
end

function KoreanThresh:Engage()
	
	local target = (_G.GOS and _G.GOS:GetTarget(1080,"AD"))
	if GetTickCount() - self.lastTick > 6000 then self.startECombo = false end
	if target == nil or self:IsValidTarget(target,1080) == false then return end
		if target.pos:DistanceTo(myHero.pos) >= 650 and self:IsReady(_Q) and self.Menu.Combo.HailMary:Value() and target:GetCollision(Q.width,Q.speed,Q.delay) == 0 then
			self:fast(HK_Q, target, self:Prediction(target), 200)
		elseif target.pos:DistanceTo(myHero.pos) <= 500 then
			if self:IsReady(_E) then
				Control.CastSpell(HK_E, myHero.pos:Extended(target.pos, -200))
				if self.startECombo == false then
					self.lastTick = GetTickCount()
					self.startECombo = true
				end
		end
		if self:IsReady(_Q) and self.startECombo == true then
				if GetTickCount() - self.lastTick > 500 then
					if target.pos:DistanceTo(myHero.pos) > 200 and target:GetCollision(Q.width,Q.speed,Q.delay) == 0 then
						self:fast(HK_Q, target, self:Prediction(target), 200)
					end
				end
		end
		if self:GetBuffs(target, "ThreshQ") then
			self.startECombo = false
		end

		if GetTickCount() - self.lastTick > 6000 then self.startECombo = false end

	end
end

function KoreanThresh:QEintoR()
	local target = (_G.GOS and _G.GOS:GetTarget(1080,"AD"))
	if GetTickCount() - self.lastTick > 6000 then self.startQERCombo = false end
	if target == nil or self:IsValidTarget(target,1080) == false then return 
	end
		if self.startQERCombo == false then
				if self:IsReady(_Q) and target:GetCollision(Q.width,Q.speed,Q.delay) == 0 then
					self:fast(HK_Q, target, self:Prediction(target), 200)
				end
				if self:IsDown(_Q) == true and self:GetBuffs(target, "ThreshQ") then
					self.lastTick = GetTickCount()
					self.startQERCombo = true
				end
		end

		if self.startQERCombo == true and self:GetBuffs(target, "ThreshQ") then
			if GetTickCount() - self.lastTick > 100 then
				Control.CastSpell(HK_Q)
			end
		end

		if self.startQERCombo == true and self:IsDown(_Q) == true and IsReady(_R) then
			if GetTickCount() - self.lastTick > 200 then
				Control.CastSpell(HK_R)
			end
		end

		if self.startQERCombo == true and self:IsDown(_R) and IsReady(_E) == true then
			if GetTickCount() - self.lastTick > 1500 then
				Control.CastSpell(HK_E, myHero.pos:Shortened(target.pos, -200))
				self.startQERCombo = false
			end
		end

		if GetTickCount() - self.lastTick > 6000 then
			self.startQERCombo = false
		end
end	

function KoreanThresh:xPath(unit)
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

function KoreanThresh:Prediction(unit)

	local target = unit

	local pathingVector = self:xPath(target)
	local distanceToTarget = myHero.pos:DistanceTo(target.pos)
	local predictionVector
	if self.predictionModified.dodger == false then
		predictionVector = target.pos:Extended(pathingVector, (distanceToTarget / 3) + target.ms - (self.Menu.Prediction.Am:Value() + 200))
		
		Draw.Circle(predictionVector)
		return predictionVector
	elseif self.predictionModified.dodger == true then
		predictionVector = target.pos:Shortened(pathingVector, (distanceToTarget / 3) + target.ms - (self.Menu.Prediction.Am:Value() + 450))
		Draw.Circle(predictionVector)
		
		return predictionVector
	end

end
local timer = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
function KoreanThresh:fast(spell, unit, prediction, delay)
	local target = prediction:To2D()
	local unit2 = unit
	local myHeroPos = myHero.pos
	local targetPos = unit2.pos
	local shootsbackwards
	local ticker = GetTickCount()
	

	if timer.state == 0 and ticker - timer.tick > delay then
		timer.state = 1
		timer.mouse = mousePos
		timer.tick = ticker
		self.predi = prediction
	end

	if timer.state == 1 then
		
		if ticker - timer.tick >= 100 and ticker - timer.tick <= 3000 then
			
			if ticker - timer.tick < 600 and ticker - timer.tick > 400 then
				if self.predi:DistanceTo(unit.pos) > 200 then
					return
				end
				Control.SetCursorPos(target.x, target.y)
				if mousePos:DistanceTo(targetPos) > myHeroPos:DistanceTo(targetPos) then
					return
				else
					Control.CastSpell(spell)
				end
				

			end
			if ticker - timer.tick > 600  then
				Control.SetCursorPos(timer.mouse)
				timer.state = 0
				
			end
			
		end
		
	end
end

function KoreanThresh:IsValidTarget(unit,range)
	return unit ~= nil and unit.valid and unit.visible and not unit.dead and unit.isTargetable and not unit.isImmortal and unit.pos:DistanceTo(myHero.pos) <= range
end

function KoreanThresh:IsReady (spell)
	return Game.CanUseSpell(spell) == 0 
end

function KoreanThresh:GetTarget(range)
	local target
	for i = 0, Game.HeroCount() do
		local hero = Game.Hero(i)
		if self:IsValidTarget(hero, range) and hero.isEnemy then
			target = hero 
			break
		end
	end
	return target
end

function KoreanThresh:GetBuffs(unit, ability)

	self.T = {}
	for i = 0, unit.buffCount do
		local Buff = unit:GetBuff(i)
		if Buff.count > 0 then
			table.insert(self.T, Buff)
		end
	end
	local texter = 20
	for k, Buff in pairs(self.T) do
		
		if Buff.name:lower() == ability:lower() then
			local textPos2 = unit.pos:To2D()
			Draw.Text(tostring(Buff.name), textPos2.x, textPos2.y + texter)
			texter = texter + 50
			return true
		end
	end
	return false
end

function KoreanThresh:CanUseSpell(spell)
	return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana
end


function KoreanThresh:GetAllyHeroes()
	local Allies
	for i = 1, Game.HeroCount() do
		local unit = Game.Hero(i)
			if unit.isAlly then
				table.insert(Allies,unit)
			end
		
	end
	return Allies
end

function KoreanThresh:IsDown(spell)
	if myHero:GetSpellData(spell).currentCd ~= 0 then 
		return true
	end
	return false
end
		
function KoreanThresh:Tick()
	
end

function KoreanThresh:Draw()
	if myHero.dead then return end
	
	
	if GetTickCount() - timer.tick > 6000 then timer.state = 0 end
					
			
    local textPos2 = myHero.pos:To2D()
			--Draw.Text(tostring(GetTickCount()), textPos2.x, textPos2.y + 50)
			
	
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



	if (_G.GOS and _G.GOS:GetMode() == "Combo") then
		if GetTickCount() - timer.tick > 4000 then
			timer.state = 0
		end
		if self.Menu.Combo.KTMataEngage:Value() and self.Menu.Combo.HotKeyChanger:Value() then
			self:Engage()
		elseif self.Menu.Combo.SKTT1WolfCombo:Value() and self.Menu.Combo.HotKeyChanger:Value() == false then
			self:QEintoR()
		end
			
	end



	if self.Menu.Combo.KTMataEngage:Value() and self.Menu.Combo.HotKeyChanger:Value() then
		Draw.Text(string.format("%s %s", "Enabled Combo: ", "KT Mata Engage [E->AA->Q]"), textPos2.x, textPos2.y + 50)
	end
	if self.Menu.Combo.SKTT1WolfCombo:Value() and self.Menu.Combo.HotKeyChanger:Value() == false then
		Draw.Text(string.format("%s %s", "Enabled Combo: ", "SKT T1 Wolf Combo [Q->R->AA->E]"), textPos2.x, textPos2.y + 50)
	end



end


function OnLoad()
	KoreanThresh()
end 
