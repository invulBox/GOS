class "KoreanCaitlyn"


function KoreanCaitlyn:__init()
	self:LoadSpells()
    self:LoadMenu()
    Callback.Add("Draw", function() self:Draw() end)

    self.predictionModified = {champion = "Ezreal", dodger = false}
    self.lastPath = 0
    self.counter = false
    self.ctimes = false
end

function KoreanCaitlyn:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "KoreanCaitlyn", name = "Korean Caitlyn", leftIcon = "http://i.imgur.com/B1yTPrK.png"})
	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Korean Caitlyn - Combo Settings"})
	self.Menu.Combo:MenuElement({id = "HotKeyChanger", name = "Q Hotkey Changer | Auto Q: Mouse", key = 0x5a, toggle = true, value = false})
	self.Menu.Combo:MenuElement({id = "HotKeyChanger2", name = "Q Hotkey Changer | Disable Q+E In Combo", key = 0x58, toggle = true, value = false})
	self.Menu.Combo:MenuElement({id = "HotKeyChanger3", name = "Q Hotkey Changer | Auto Trap", key = 0x56, toggle = true, value = false})
	self.Menu.Combo:MenuElement({id = "ComboQ", name = "Use Q", value = true})
	self.Menu.Combo:MenuElement({id = "ComboW", name = "Use W", value = true})
	self.Menu.Combo:MenuElement({id = "ComboE", name = "Use E", value = true})
	self.Menu:MenuElement({type = MENU, id = "Prediction", name = "Korean Caitlyn - xPrediction Settings"})
	self.Menu.Prediction:MenuElement({id = "Am", name = "Prediction Range", value = 80, min = 20, max = 200})
	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Korean Caitlyn - Harass Settings"})
	self.Menu.Harass:MenuElement({id = "CS", name = "Comming Soon.", value = true})
	self.Menu:MenuElement({type = MENU, id = "Draw", name = "Korean Caitlyn - Draw Settings"})
	self.Menu.Draw:MenuElement({id = "DrawTraps", name = "Trap Helper", value = true})
	self.Menu.Draw:MenuElement({id = "DrawQ", name = "Q Range", value = true})
	self.Menu.Draw:MenuElement({id = "DrawW", name = "W Range", value = true})
	self.Menu.Draw:MenuElement({id = "DrawE", name = "E Range", value = true})
	self.Menu.Draw:MenuElement({id = "DrawR", name = "R Range", value = true})
	
end

function KoreanCaitlyn:LoadSpells()
	Q = {Range = myHero:GetSpellData(_Q).range, Delay = myHero:GetSpellData(_Q).delay, Radius = myHero:GetSpellData(_Q).radius, Speed = myHero:GetSpellData(_Q).speed}
	W = {Range = myHero:GetSpellData(_W).range, Delay = myHero:GetSpellData(_W).delay, Radius = myHero:GetSpellData(_Q).radius, Speed = 0}
	E = {Range = myHero:GetSpellData(_W).range, Delay = myHero:GetSpellData(_E).delay, Radius = myHero:GetSpellData(_Q).radius, Speed = 0}
	R = {Range = myHero:GetSpellData(_W).range, Delay = myHero:GetSpellData(_R).delay, Radius = myHero:GetSpellData(_R).radius, Speed = 0}
end

function KoreanCaitlyn:xPath(unit)
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

function KoreanCaitlyn:Prediction(unit)

	local target = unit
	local offset = 50
	local pathingVector = self:xPath(target)
	local distanceToTarget = myHero.pos:DistanceTo(target.pos)
	local predictionVector
	if myHero.pos:DistanceTo(unit.pos) > 700 then
		offset = 35
	end
	if self.predictionModified.dodger == false then
		predictionVector = target.pos:Extended(pathingVector, (distanceToTarget / 3) + target.ms - (self.Menu.Prediction.Am:Value() + 200) - offset)
		
		Draw.Circle(predictionVector)
		return predictionVector
	elseif self.predictionModified.dodger == true then
		predictionVector = target.pos:Shortened(pathingVector, (distanceToTarget / 3) + target.ms - (self.Menu.Prediction.Am:Value() + 450))
		Draw.Circle(predictionVector)
		
		return predictionVector
	end

end

function KoreanCaitlyn:BlueTrapDraw()
	if myHero.pos:DistanceTo(Vector(13891, 52, 4513)) < 1050 then -- Blue Bot Tier 3
		Draw.Circle(Vector(14029, 53, 4354))
		Draw.Circle(Vector(13666, 53, 4617))
		Draw.Circle(Vector(13870, 52, 4640))
		Draw.Circle(Vector(13419, 52, 4574))
	end	
	if myHero.pos:DistanceTo(Vector(8967, 54, 8501)) < 1050 then -- Blue Mid Tier 3
		Draw.Circle(Vector(9023, 53, 8314))
		Draw.Circle(Vector(9000, 54, 8666))
		Draw.Circle(Vector(8798, 54, 8638))
		Draw.Circle(Vector(8613, 54, 8767))
	end	
	if myHero.pos:DistanceTo(Vector(9780, 52, 10100)) < 1050 then -- Blue Mid Tier 2
		Draw.Circle(Vector(9936, 52, 9953))
		Draw.Circle(Vector(10070, 52, 9847))
		Draw.Circle(Vector(10207, 52, 9739))
		Draw.Circle(Vector(9607, 52, 10223))
	end	
	if myHero.pos:DistanceTo(Vector(11144, 93, 11172)) < 1050 then -- Blue Mid Tier 1
		Draw.Circle(Vector(11233, 91, 10726))
		Draw.Circle(Vector(11185, 91, 11015))
	end	
end

function KoreanCaitlyn:RedTrapDraw()
	if myHero.pos:DistanceTo(Vector(10492, 50, 1035)) < 1050 then -- Red Bot Tier 3
		Draw.Circle(Vector(10524, 50, 830))
		Draw.Circle(Vector(10362, 50, 1199))
		
	end	
	if myHero.pos:DistanceTo(Vector(5848, 51, 6383)) < 1050 then -- Red Mid Tier 3
		Draw.Circle(Vector(5711, 51, 6496))
		Draw.Circle(Vector(5994, 51, 6253))
		Draw.Circle(Vector(6143, 51, 6116))
		Draw.Circle(Vector(6294, 51, 5992))
	end	
end

local startEQCombo = false
function KoreanCaitlyn:KTDeft(target, target2)
	
	if target.pos:DistanceTo(myHero.pos) < 600 and self:IsReady(_E) and self.Menu.Combo.ComboE:Value() and target:GetCollision(E.width,E.speed,E.delay) == 0 then
		if target.activeSpell.windup > 0.1 then
			local possAfterAutoAttack = target.pos:Extended(self.lastPath, 50)
			_G.EOW:SetMovements(false)
			_G.EOW:SetAttacks(false)
			self:fast(HK_E, _E, target, possAfterAutoAttack, 10, false, false)
			_G.EOW:SetMovements(true)
			_G.EOW:SetAttacks(true)
			startEQCombo = true
		else
			_G.EOW:SetMovements(false)
			_G.EOW:SetAttacks(false)
			self:fast(HK_E, _E, target, self:Prediction(target), 10, false, false)
			_G.EOW:SetMovements(true)
			_G.EOW:SetAttacks(true)
			startEQCombo = true
		end
	end
	if self:IsReady(_Q) and self:IsReady(_E) ~= true and self.Menu.Combo.ComboQ:Value() then
		local offset = 50
		if target.activeSpell.windup > 0.1 then
			local posAfterAutoAttack = target.pos:Extended(self.lastPath, 50)
				Draw.Circle(posAfterAutoAttack)
				_G.EOW:SetMovements(false)
				_G.EOW:SetAttacks(false)
				self:fast(HK_Q, _Q, target, posAfterAutoAttack, 50, false, false)
				_G.EOW:SetMovements(true)
				_G.EOW:SetAttacks(true)	
		else
			
			self:fast(HK_Q, _Q, target, self:Prediction(target), 75, false, false)
		end
		
	end

	if self:IsReady(_Q) ~= true and self:IsReady(_E) ~= true then
		startEQCombo = false
		return
	end
end

local timer = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
function KoreanCaitlyn:fast(spell, spell2, unit, prediction, delay, keepmouse, trap)
	local keepmousee = keepmouse or false
	local trap = trap or false
	if unit == nil then 
		return 
	end
	local target = prediction:To2D()

	local unit2 = unit
	local myHeroPos = myHero.pos
	local targetPos = unit2.pos
	local shootsbackwards
	local ticker = GetTickCount()
	
	if target.onScreen ~= true then
		PrintChat("OffScreen, please report if still fires: 0001")
		Control.SetCursorPos(targetPos.x, targetPos.y)
		return
	end
	
	if timer.state == 0 and ticker - timer.tick > delay then
		timer.state = 1
		timer.mouse = mousePos
		timer.tick = ticker
		self.predi = prediction
	end

	if timer.state == 1 then
		
		if ticker - timer.tick > 0 and ticker - timer.tick <= 500 then
			
			if ticker - timer.tick > 0 and ticker - timer.tick < 10 + Game.Latency() and targetPos:ToScreen().onScreen then
				if self.predi:DistanceTo(unit.pos) > 600 or target:DistanceTo(unit2.pos:To2D()) > 600 then
					return
				end
				
				Control.SetCursorPos(target.x, target.y)
				--if mousePos:DistanceTo(targetPos) > myHeroPos:DistanceTo(targetPos) then
					--return
				--else
				if trap == true then
						self.ctimes = true
				end
					Control.CastSpell(spell)
					
				--end
				

			end
			
		end
		if ticker - timer.tick > 300 + Game.Latency() and keepmousee == false then
				Control.SetCursorPos(timer.mouse)
				timer.state = 0
		elseif ticker - timer.tick > 300 + Game.Latency() and keepmousee == true then
				timer.state = 0	
		end
	end
end

local staticCoolTimer = GetTickCount()
function KoreanCaitlyn:TrapGod()
	local dCoolTimer = GetTickCount()
	if self.counter == false then
		staticCoolTimer = dCoolTimer
		self.counter = true
	end
	if self.counter == true and self.ctimes == false then
		local target = self:GetValidEnemy()
		if target == nil then return end
		local dist = target.pos:DistanceTo(myHero.pos)
		if dist < 800 and dist > 201 then
			local predic = target.pos:Extended(self:xPath(target), 375)
			if predic:DistanceTo(myHero.pos) > 700 then return end		
			self:fast(HK_W, _W, target, predic, 100, false, true)
		elseif dist < 150
			self:fast(HK_W, _W, target, myHero.pos, 100, false, true)
		end
	end
		
	if dCoolTimer - staticCoolTimer > 6000 then
		self.counter = false
		self.ctimes = false
	end
end

function KoreanCaitlyn:GetValidEnemy()
    for i = 1,Game.HeroCount() do
        local enemy = Game.Hero(i)
        if  enemy.team ~= myHero.team and enemy.valid and enemy.pos:DistanceTo(myHero.pos) < 1500 then
            return enemy
        end
    end
    return enemy
end

function KoreanCaitlyn:Buffs(unit, buffname)
	

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


function KoreanCaitlyn:Draw()
	local textPos = myHero.pos:To2D()
	if self.Menu.Combo.HotKeyChanger2:Value() then
			
			Draw.Text("Q+E Disabled", textPos.x, textPos.y + 40)
	end
	if self.Menu.Combo.HotKeyChanger:Value() then
		
		Draw.Text("Auto Q On Cursor", textPos.x, textPos.y + 30)
	end

	if self.Menu.Combo.HotKeyChanger3:Value() then
		Draw.Text("Auto Trap Enabled", textPos.x, textPos.y + 50)
	end

	if self.Menu.Draw.DrawTraps:Value() then
		self:BlueTrapDraw()
		self:RedTrapDraw()
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


	local target = _G.EOW:GetTarget(1100)
	local target2 =  (_G.GOS and _G.GOS:GetTarget(1100,"AD"))

	if target2 == nil then return end
	if target == nil then return end

	if self:xPath(target) ~= nil then
		self.lastPath = self:xPath(target)
	end

	if GetTickCount() - timer.tick > 4000 then
			timer.state = 0
	end

	if _G.GOS:GetMode() == "Combo" then
		if self.Menu.Combo.HotKeyChanger:Value() == false then
			self:KTDeft(target, target2)
		end
	end
	if self.Menu.Combo.HotKeyChanger:Value() then
		self:AutoQ()
	end

	if self:IsReady(_W) and self.Menu.Combo.HotKeyChanger3:Value() then
		self:TrapGod()
	end

	if self.Menu.Draw.DrawTraps:Value() then
		self:BlueTrapDraw()
		self:RedTrapDraw()
	end
end

function KoreanCaitlyn:AutoQ()
	if self:IsReady(_Q) ~= true or self.Menu.Combo.ComboQ:Value() ~= true then return end
	local target = self:GetValidEnemy()
	if mousePos:DistanceTo(target.pos) < 100 then
		if target.activeSpell.windup > 0.1 then
			local posAfterAutoAttack = target.pos:Extended(self.lastPath, 50)
				Draw.Circle(posAfterAutoAttack)
				_G.EOW:SetMovements(false)
				_G.EOW:SetAttacks(false)
				self:fast(HK_Q, _Q, target, posAfterAutoAttack, 50, true, false)
				_G.EOW:SetMovements(true)
				_G.EOW:SetAttacks(true)	
		else
			_G.EOW:SetMovements(false)
			_G.EOW:SetAttacks(false)
			self:fast(HK_Q, _Q, target, self:Prediction(target), 50, true, false)
			_G.EOW:SetMovements(true)
			_G.EOW:SetAttacks(true)	
		end
	end
end




function KoreanCaitlyn:IsReady (spell)
	return Game.CanUseSpell(spell) == 0 
end

function OnLoad()
	KoreanCaitlyn()
end