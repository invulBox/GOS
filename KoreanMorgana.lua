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
    self.lastPath = 0
    self.ShootDelay = {}

	self.dashAboutToHappend =
	{
		{name = "ezrealarcaneshift", duration = 0.25},
		{name = "deceive", duration = 0.25}, 
		{name = "riftwalk", duration = 0.25},
		{name = "gate", duration = 1.5},
		{name = "katarinae", duration = 0.25},
		{name = "elisespideredescent", duration = 0.25},
		{name = "elisespidere", duration = 0.25},
		{name = "ahritumble", duration = 0.25},
		{name = "akalishadowdance", duration = 0.25},
		{name = "headbutt", duration = 0.25},
		{name = "caitlynentrapment", duration = 0.25},
		{name = "carpetbomb", duration = 0.25},
		{name = "dianateleport", duration = 0.25},
		{name = "fizzpiercingstrike", duration = 0.25},
		{name = "fizzjump", duration = 0.25},
		{name = "gragasbodyslam", duration = 0.25},
		{name = "gravesmove", duration = 0.25},
		{name = "ireliagatotsu", duration = 0.25},
		{name = "jarvanivdragonstrike", duration = 0.25},
		{name = "jaxleapstrike", duration = 0.25},
		{name = "khazixe", duration = 0.25},
		{name = "leblancslide", duration = 0.25},
		{name = "leblancslidem", duration = 0.25},
		{name = "blindmonkqtwo", duration = 0.25}, 
		{name = "blindmonkwone", duration = 0.25},
		{name = "luciane", duration = 0.25},
		{name = "maokaiunstablegrowth", duration = 0.25},
		{name = "nocturneparanoia2", duration = 0.25},
		{name = "pantheon_leapbash", duration = 0.25},
		{name = "renektonsliceanddice", duration = 0.25},
		{name = "riventricleave", duration = 0.25},
		{name = "rivenfeint", duration = 0.25},
		{name = "sejuaniarcticassault", duration = 0.25},
		{name = "shenshadowdash", duration = 0.25},
		{name = "shyvanatransformcast", duration = 0.25},
		{name = "rocketjump", duration = 0.25},
		{name = "slashcast", duration = 0.25},
		{name = "vaynetumble", duration = 0.25},
		{name = "viq", duration = 0.25},
		{name = "monkeykingnimbus", duration = 0.25},
		{name = "xenzhaosweep", duration = 0.25},
		{name = "yasuodashwrapper", duration = 0.25},

	}
end

function KoreanMorgana:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "KoreanMorgana", name = "Korean Morgana", leftIcon = "http://i.imgur.com/B1yTPrK.png"})
	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Korean Morgana - Combo Settings"})
	self.Menu.Combo:MenuElement({id = "HotKeyChanger", name = "Q Hotkey Changer | Wait for AA or Spell", key = 0x5a, toggle = true, value = false})
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

function KoreanMorgana:Prediction(unit)

	local target = unit

	local pathingVector = self:xPath(target)
	local distanceToTarget = myHero.pos:DistanceTo(target.pos)
	local predictionVector
	if self.predictionModified.dodger == false then
		predictionVector = target.pos:Extended(pathingVector, (distanceToTarget / 3) + target.ms - (self.Menu.Prediction.Am:Value() + 200) - 50)
		
		Draw.Circle(predictionVector)
		return predictionVector
	elseif self.predictionModified.dodger == true then
		predictionVector = target.pos:Shortened(pathingVector, (distanceToTarget / 3) + target.ms - (self.Menu.Prediction.Am:Value() + 450))
		Draw.Circle(predictionVector)
		
		return predictionVector
	end

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

function KoreanMorgana:SearchForDash(unit)
	for i, k in ipairs (self.dashAboutToHappend) do
		if unit.activeSpell.name:lower() == k.name then
			self.ShootDelay[unit.charName] = k.duration
			return
		end
	end
end
local timeDash = 0
function KoreanMorgana:StartQ()
	local target = (_G.GOS and _G.GOS:GetTarget(1000,"AD"))
	if target == nil or self:IsValidTarget(target,1000) == false then return 
	end
	if target.pos:DistanceTo(myHero.pos) <= 1000 and self:IsReady(_Q) and self.Menu.Combo.ComboQ:Value() and target:GetCollision(Q.width,Q.speed,Q.delay) == 0 then
		if target.activeSpell.windup > 0.1 and self.Menu.Combo.HotKeyChanger:Value()  then
			self:SearchForDash(target)
			if self.ShootDelay[target.charName] ~= nil then
				DelayAction(function()
				local posAfterAutoAttack = target.pos:Extended(self.lastPath, 50)
				Draw.Circle(posAfterAutoAttack)
				self:fast(HK_Q, target, posAfterAutoAttack, 100) end,
				self.ShootDelay[target.charName].duration)
				self.ShootDelay[target.charName] = nil	
			else	
				if myHero.pos:DistanceTo(target.pos) < 750 and target.ms < 400 then
					local posAfterAutoAttack = target.pos:Extended(self.lastPath, 50)
				else
					local posAfterAutoAttack = target.pos:Extended(self.lastPath, target.ms / 7)
				end
				Draw.Circle(posAfterAutoAttack)
				self:fast(HK_Q, target, posAfterAutoAttack, 50)
			end
		elseif self.Menu.Combo.HotKeyChanger:Value() ~= true then
			self:fast(HK_Q, target, self:Prediction(target), 200)
		end
	end
end

local timer = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
function KoreanMorgana:fast(spell, unit, prediction, delay)
	if unit == nil then 
		return 
	end
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
		
		if ticker - timer.tick >= 100 and ticker - timer.tick <= 1000 then
			
			if ticker - timer.tick > 100 and ticker - timer.tick < 500 and self:IsReady(_Q) and targetPos:ToScreen().onScreen then
				if self.predi:DistanceTo(unit.pos) > 600 then
					return
				end
				Control.SetCursorPos(target.x, target.y)
				if mousePos:DistanceTo(targetPos) > myHeroPos:DistanceTo(targetPos) and mousePos:DistanceTo(prediction) > 100 then
					return
				else
					Control.CastSpell(spell)
				end
				

			end
			if ticker - timer.tick > 501 and self:IsReady(_Q) == false then
				Control.SetCursorPos(timer.mouse)
				timer.state = 0
				
			end

			
		end
	end
end

function KoreanMorgana:Draw()
	
	local text2d = myHero.pos:To2D()
	if self.Menu.Combo.HotKeyChanger:Value() then
		Draw.Text("Q After Auto Attack or Missle", text2d.x - 50, text2d.y + 30)
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

	local target = (_G.GOS and _G.GOS:GetTarget(1000,"AD"))
	if target == nil or self:IsValidTarget(target,1000) == false then return 
	end
	if self:xPath(target) ~= nil then
		self.lastPath = self:xPath(target)
	end
	
	if (_G.GOS and _G.GOS:GetMode() == "Combo") then
		if GetTickCount() - timer.tick > 4000 then
			timer.state = 0
		end
		if self:IsReady(_Q) then
			self:StartQ()
		end		
	end
	
	
end

function OnLoad()
	KoreanMorgana()
end

