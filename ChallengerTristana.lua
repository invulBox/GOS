class "ChallengerTristana" 

function ChallengerTristana:__init() 
	if myHero.charName ~= "Tristana" then return end
	self:LoadSpells() 
	self:LoadMenu() 
	Callback.Add("Tick", function() self:Tick() end) 
	Callback.Add("Draw", function() self:Draw() end) 
	
end

function ChallengerTristana:LoadSpells()
	Q = {Range = myHero:GetSpellData(_Q).range, Delay = myHero:GetSpellData(_Q).delay, Radius = myHero:GetSpellData(_Q).radius, Speed = myHero:GetSpellData(_Q).speed}
	W = {Range = myHero:GetSpellData(_W).range, Delay = myHero:GetSpellData(_W).delay, Radius = myHero:GetSpellData(_W).radius, Speed = myHero:GetSpellData(_W).speed}
	E = {Range = myHero:GetSpellData(_E).range, Delay = myHero:GetSpellData(_E).delay, Radius = myHero:GetSpellData(_E).radius, Speed = myHero:GetSpellData(_E).speed}
	R = {Range = myHero:GetSpellData(_R).range, Delay = myHero:GetSpellData(_R).delay, Radius = myHero:GetSpellData(_R).radius, Speed = myHero:GetSpellData(_R).speed}
	
end

function ChallengerTristana:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "ChallengerTristana", name = "TheChallengerTristanaScript", leftIcon = "http://i.imgur.com/B1yTPrK.png"})
	self.Menu:MenuElement({type = MENU, id = "Combo", name = "ChallengerTristana Combo Settings"})
	self.Menu.Combo:MenuElement({id = "FocusE", name = "Focus E Target", value = true})
	self.Menu.Combo:MenuElement({id = "BufferW", name = "Hotkey Changer | W Cancel CC", key = 0x5a, toggle = true, value = true})
	self.Menu.Combo:MenuElement({id = "BufferW", name = "", value = true})
	self.Menu.Combo:MenuElement({id = "ComboQ", name = "Use Q", value = true})
	self.Menu.Combo:MenuElement({id = "ComboW", name = "Use W", value = true})
	self.Menu.Combo:MenuElement({id = "ComboE", name = "Use E", value = true})
	self.Menu.Combo:MenuElement({id = "ComboR", name = "Use R", value = true})

	self.Menu:MenuElement({type = MENU, id = "Draw", name = "ChallengerTristana Draw Settings"}) 
	self.Menu.Draw:MenuElement({id = "DrawQ", name = "Q Range", value = true})
	self.Menu.Draw:MenuElement({id = "DrawW", name = "W Range", value = true})
	self.Menu.Draw:MenuElement({id = "DrawE", name = "E Range", value = true})
	self.Menu.Draw:MenuElement({id = "DrawR", name = "R Range", value = true})
end
local timer = {state = false, tick = GetTickCount(), mouse = mousePos, done = false, delayer = GetTickCount()}
function ChallengerTristana:CastSpell(targetPos, spell)
	local curTime = GetTickCount()
	
	if timer.state == false then
		timer.tick = GetTickCount()
		timer.state = true
	end
	
	if curTime - timer.tick > 0 and timer.state == true and targetPos:ToScreen().onScreen and timer.done == false then
		
		if curTime - timer.tick <= 40 then
			timer.mouse = cursorPos
		elseif curTime - timer.tick > 50 then
			
			Control.SetCursorPos(targetPos)
			Control.KeyDown(spell)
			Control.KeyUp(spell)
			Control.SetCursorPos(timer.mouse)
			timer.state = false
			timer.done = true
		end
		
	end
	
	
end

function ChallengerTristana:Buffs(unit, buffName)

	local activeBuffs = {}

	for i = 0, unit.buffCount do
		local Buff = unit:GetBuff(i)
		if Buff.count > 0 then
			table.insert(activeBuffs, Buff)
		end
	end
	for i, Buff in pairs(activeBuffs) do
		if Buff.name:lower() == buffName then
			return true
		end
		
	end
	return false
	
end

function ChallengerTristana:GetTarget(range)
    local target
    for i = 1,Game.HeroCount() do
        local hero = Game.Hero(i)
        if self:IsValidTarget(hero, range) and hero.team ~= myHero.team then
			if self:Buffs(hero, "tristanaechargesound") ~= false then 
				return hero
			end
        end
    end
    return false
end

local grabTime = 0
local casterPos
function ChallengerTristana:CheckSpell(range)
    local target
    for i = 1,Game.HeroCount() do
        local hero = Game.Hero(i)
        if self:IsValidTarget(hero, range) and hero.team ~= myHero.team then
			if hero.activeSpell.name == "RocketGrab" then 
				casterPos = hero.pos
				grabTime = hero.activeSpell.startTime * 100
				return true
			end
        end
    end
    return false
end

local RDamage

function ChallengerTristana:Draw() 
	local myHeroPositionAsVector2D = myHero.pos:To2D() 
	if self.Menu.Draw.DrawE:Value() then
		Draw.Circle(myHero.pos, E.Range, 1, Draw.Color(255, 255, 255, 255)) 
	end
	if self.Menu.Combo.BufferW:Value() then
		Draw.Text("Auto W Buffer: Enabled", myHeroPositionAsVector2D.x, myHeroPositionAsVector2D.y) 
	end
	if self.Menu.Draw.DrawW:Value() then
		Draw.Circle(myHero.pos, W.Range, 1, Draw.Color(255, 255, 255, 255)) 
	end
	if GetTickCount - timer.tick > 900 and GetTickCount - timer.tick < 1200 then 
		timer.state = false
		_G.SDK.Orbwalker:SetMovement(true)
		_G.SDK.Orbwalker:SetAttack(true)
	end
	
	local ctc = Game.Timer() * 100
	Draw.Text(tostring(myHero.activeSpell.castEndTime), 500, 200)
	local target = _G.SDK.TargetSelector:GetTarget(900, _G.SDK.DAMAGE_TYPE_PHYSICAL)
	if self.Menu.Combo.BufferW:Value() and self:CheckSpell(900) and grabTime ~= nil then 
		if myHero.pos:DistanceTo(target.pos) > 500 then
			if ctc - grabTime >= 28 then
				local jump = myHero.pos:Shortened(target.pos, 700)
				_G.SDK.Orbwalker:SetMovement(false)
				_G.SDK.Orbwalker:SetAttack(false)
				Control.SetCursorPos(jump)
				Control.KeyDown(HK_W)
				Control.KeyUp(HK_W)
			end
		else
			if ctc - grabTime >= 12 then
				local jump = myHero.pos:Shortened(target.pos, 700)
				_G.SDK.Orbwalker:SetMovement(false)
				_G.SDK.Orbwalker:SetAttack(false)
				Control.SetCursorPos(jump)
				Control.KeyDown(HK_W)
				Control.KeyUp(HK_W)
			end
		end
	end
	if target == nil then return end
	if self.Menu.Combo.FocusE:Value() and self:IsReady(_E) == false then
		local focusE = self:GetTarget(900)
		if focusE ~= false then
			target = focusE
		end
	end
	if _G.SDK then
		if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
		if GetTickCount() - timer.tick > 300 then
			timer.done = false
		end
			if self:IsValidTarget(target, R.Range) and self:IsReady(_R) and self.Menu.Combo.ComboR:Value() and target.health <= RDamage then 
			_G.SDK.Orbwalker:SetMovement(false)
			_G.SDK.Orbwalker:SetAttack(false)
				self:CastSpell(target.pos, HK_R)
			_G.SDK.Orbwalker:SetMovement(true)
			_G.SDK.Orbwalker:SetAttack(true)	
			end
			if self:IsValidTarget(target, E.Range) and self:IsReady(_E) and self.Menu.Combo.ComboE:Value() then 
			_G.SDK.Orbwalker:SetMovement(false)
			_G.SDK.Orbwalker:SetAttack(false)
				self:CastSpell(target.pos, HK_E)
			_G.SDK.Orbwalker:SetMovement(true)
			_G.SDK.Orbwalker:SetAttack(true)
			end
			if self:IsValidTarget(target, E.Range) and self:IsReady(_Q) and self.Menu.Combo.ComboQ:Value() then 
				Control.KeyDown(HK_Q)
				Control.KeyUp(HK_Q)
			end
		end
	end
	
end

function ChallengerTristana:Tick() 
	if myHero:GetSpellData(_R).level == 1 then
		RDamage = 250
	elseif myHero:GetSpellData(_R).level >= 2 then
		RDamage = 450
	end
end

function ChallengerTristana:IsValidTarget(target, range)
	if target ~= nil and target.valid and target.visible and not target.dead and target.isTargetable and target.pos:DistanceTo(myHero.pos) <= range then 
		return true
	end
end

function ChallengerTristana:IsReady(spell)
	return Game.CanUseSpell(spell) == 0 
end

function OnLoad() 
	ChallengerTristana()
end
