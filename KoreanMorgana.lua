class "XPred"

function XPred:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Draw", function() self:Draw() end)
	self.predictionModified = {champion = "Ezreal", dodger = false}
	self.predi = 0
	self.lastPath = 0
	
end

function XPred:LoadSpells()
	Q = {Range = 1175, Delay = myHero:GetSpellData(_Q).delay, Radius = 75, Speed = myHero:GetSpellData(_Q).speed + 400}
	W = {Range = 900, Delay = myHero:GetSpellData(_W).delay, Radius = 275, Speed = 0}
	E = {Range = 800, Delay = myHero:GetSpellData(_E).delay, Radius = 0, Speed = 0}
	R = {Range = 625, Delay = myHero:GetSpellData(_R).delay, Radius = myHero:GetSpellData(_R).radius, Speed = 0}
end

function XPred:LoadMenu()
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

function XPred:Buffs()
	local target = (_G.GOS and _G.GOS:GetTarget(800,"AD"))
	if target == nil then return end
	local textPos2 = target.pos:To2D()
	textOffset = 50

	if target == nil then return end

	local activeBuffs = {}

	for i = 0, target.buffCount do
		local Buff = target:GetBuff(i)
		if Buff.count > 0 then
			table.insert(activeBuffs, Buff)
		end
	end
	for i, Buff in pairs(activeBuffs) do
		Draw.Text(tostring(Buff.name), textPos2.x , textPos2.y - textOffset)
		textOffset = textOffset - 10
	end
end

function XPred:xPath(unit)
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

function XPred:Prediction(unit)

	local target = unit

	local pathingVector = self:xPath(target)
	local distanceToTarget = myHero.pos:DistanceTo(target.pos)
	local predictionVector
	if self.predictionModified.dodger == false then
		predictionVector = target.pos:Extended(pathingVector, (distanceToTarget / 5) + target.ms - (self.Menu.Prediction.Am:Value() + 200))
		
		Draw.Circle(predictionVector)
		return predictionVector
	elseif self.predictionModified.dodger == true then
		predictionVector = target.pos:Shortened(pathingVector, (distanceToTarget / 5) + target.ms - (self.Menu.Prediction.Am:Value() + 450))
		Draw.Circle(predictionVector)
		
		return predictionVector
	end

end


local timer = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}


function XPred:fast(spell, unit, prediction)

	

	local target = prediction:To2D()
	local ticker = GetTickCount()
	local delay = 200

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
				Control.CastSpell(spell)

			end
			if ticker - timer.tick > 600  then
				Control.SetCursorPos(timer.mouse)
				timer.state = 0
				
			end
			
		end
		
	end
end




function XPred:Draw()
	local target =  (_G.GOS and _G.GOS:GetTarget(2000,"AD"))

	if target == nil then return end
	if self:xPath(target) ~= nil then
		self.lastPath = self:xPath(target)
	end
	Draw.Circle(myHero.pos:Extended(target.pos, 50))
	self:Buffs()
	local textPos2 = target.pos:To2D()
	Draw.Text(tostring(target.activeSpell.windup), textPos2.x, textPos2.y - 10)
	Draw.Text(tostring(self.lastPath), textPos2.x, textPos2.y - 0)
	Draw.Text(tostring(self:xPath(target)), textPos2.x, textPos2.y + 10)
	
	
	
end

function OnLoad()
	local rvector
	XPred()
end
