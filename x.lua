class "Jax"  -- Class: a structure - Keeps everything orginaized and readable

function Jax:__init() -- the starting point of the script that is called one time - This is where you put all the functions/varibles you want to initalize at the start.
	self:LoadSpells() -- doing function Jax:LoadSpells() - "self" is making code more readable, so people/you know it's your function and not in the api, this is the only reason why classes are useful.
	self:LoadMenu() -- doing function Jax:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end) -- Callback.Add is a function of GoS, applies your function self:Draw() into theirs.
	Callback.Add("Draw", function() self:Draw() end) -- Applies all your self:Draw() code.
end

function Jax:LoadSpells()
	Q = {Range = myHero:GetSpellData(_Q).range, Delay = myHero:GetSpellData(_Q).delay, Radius = myHero:GetSpellData(_Q).radius, Speed = myHero:GetSpellData(_Q).speed}
	W = {Range = myHero:GetSpellData(_Q).range, Delay = myHero:GetSpellData(_Q).delay, Radius = myHero:GetSpellData(_Q).radius, Speed = myHero:GetSpellData(_Q).speed}
	E = {Range = myHero:GetSpellData(_Q).range, Delay = myHero:GetSpellData(_Q).delay, Radius = myHero:GetSpellData(_Q).radius, Speed = myHero:GetSpellData(_Q).speed}
	R = {Range = myHero:GetSpellData(_Q).range, Delay = myHero:GetSpellData(_Q).delay, Radius = myHero:GetSpellData(_Q).radius, Speed = myHero:GetSpellData(_Q).speed}
	-- Table of each hotkey/spell, the reason why this is included into __init() is because these are static(always the same) values, so it's obviously effencent.
	-- can be called whatever, you'll be the one using these, not GoS.
end

function Jax:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "Jax", name = "TheJaxScript", leftIcon = "http://i.imgur.com/B1yTPrK.png"}) -- MenuElement table - Part of GoS api for menu, id - sets id... you'll be using this can be called anything, name - displays string, leftIcon - displays icon
	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Jax Combo Settings"}) -- same as above, but now makes a MenuElement (clickable menu) for id-Jax and will be called "Combo"
	self.Menu.Combo:MenuElement({id = "ComboQ", name = "Use Q", value = true}) -- Makes an MemuElement for Combo called "ComboQ", with a value of "true" (Read api for other type of values)
	self.Menu.Combo:MenuElement({id = "ComboW", name = "Use W", value = true})
	self.Menu.Combo:MenuElement({id = "ComboE", name = "Use E", value = true})

	self.Menu:MenuElement({type = MENU, id = "Draw", name = "Jax Draw Settings"}) -- Same format as above (Will explain logic easier later)
	self.Menu.Draw:MenuElement({id = "DrawQ", name = "Q Range", value = true})
	self.Menu.Draw:MenuElement({id = "DrawW", name = "W Range", value = true})
	self.Menu.Draw:MenuElement({id = "DrawE", name = "E Range", value = true})
	self.Menu.Draw:MenuElement({id = "DrawR", name = "R Range", value = true})
end

function Jax:Draw() -- Draw, for callback "Draw" as shown in __init
	local myHeroPositionAsVector2D = myHero.pos:To2D() -- myHero is a already estabished gameObject, "pos" (Vector x,y,z) calls the position of the object in game, To2D() is a vector function that turns a 3d vector(xyz) into a 2d position on screen (x,y)
	if self.Menu.Draw.DrawQ:Value() then
		Draw.Circle(myHero.pos, Q.Range, 1, Draw.Color(255, 255, 255, 255)) -- Draw.Circle, part of GoS api, example: (vector3, size of circle, width of circle, color of circle)
	end
end

function Jax:Tick() -- Draw, for callback "Tick" as shown in __init
	local target = _G.GOS and _G.GOS:GetTarget(Q.Range, "AD") -- Read below, GetTarget(range, type) function in GOS orbwalker that returns a object (which is gonna be ex: Vayne)
	if _G.GOS and _G.GOS:GetMode() == "Combo" then -- "_G." means we're calling a global class, GOS is GoS orbwalker, GOS:GetTarget() is a function in the class GOS (like we're calling self:IsTargetValid)
		if self:IsValidTarget(target, Q.Range) and self:IsReady(_Q) and self.Menu.Combo.ComboQ:Value() then -- self:IsValidTarget() is our function with the parameters (target, range), self:IsReady() our function with the parameter _Q (search the api for _Q), self.Menu.Combo.ComboQ:Value() returns the value of "value =" as applied in the LoadMenu function
			Control.CastSpell(HK_Q, target.pos) -- Part of GoS api, CastSpell(hotkey, vector), will press hotkey and if vector is included will move mouse to vector.
		end

	end
end

function Jax:IsValidTarget(target, range)
	if target ~= nil and target.valid and target.visible and not target.dead and target.isTargetable and target.pos:DistanceTo(myHero.pos) <= range then -- Most are part of GoS api, lots of checks to see if target is valid.
		return true
	end
end

function Jax:IsReady(spell)
	return Game.CanUseSpell(spell) == 0 -- Part of GoS api, CanUseSpell(_Q) returns true of false (0 or 1) if spell is ready
end

function OnLoad() -- Part of GoS, this is where everything starts, Jax() will be executed starting at __init (initalize) of course. 
	Jax()
end
