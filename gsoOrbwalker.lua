-- loaded
if _G.GamsteronCoreLoaded then return end
_G.GamsteronCoreLoaded = true
if _G.SDK and _G.SDK.Orbwalker then
	
	
math.randomseed(os.clock())
local MENU, MENU_CHAMP, META1, META2
local GAMSTERON_MODE_DMG = false
local CURSOR, TS, FARM, OB, ORB, ACTIONS, UTILS, OBJECTS, SPELLS
local Linq, BuffManager, ItemManager, Utilities, Damage, ObjectManager, TargetSelector, HealthPrediction, Orbwalker, Gamsteron, HoldPositionButton
-- locals
local GOSAPIBROKEN					= 0
local CONTROLL						= nil
local NEXT_CONTROLL					= 0
local MYHERO_IS_CAITLYN				= myHero.charName == "Caitlyn"
local GetTickCount					= GetTickCount
local myHero						= _G.myHero
local LocalCharName					= myHero.charName
local LocalVector					= Vector;
local LocalOsClock					= os.clock;
local LocalCallbackAdd				= Callback.Add;
local LocalCallbackDel				= Callback.Del;
local LocalDrawLine					= Draw.Line;
local LocalDrawColor				= Draw.Color;
local LocalDrawCircle				= Draw.Circle;
local LocalDrawText					= Draw.Text;
local LocalControlIsKeyDown			= Control.IsKeyDown;
local LocalControlMouseEvent		= Control.mouse_event;
local LocalControlSetCursorPos		= Control.SetCursorPos;
local LocalControlKeyUp				= Control.KeyUp;
local LocalControlKeyDown			= Control.KeyDown;
local LocalGameCanUseSpell			= Game.CanUseSpell;
local LocalGameLatency				= Game.Latency;
local LocalGameTimer				= Game.Timer;
local LocalGameParticleCount		= Game.ParticleCount
local LocalGameParticle				= Game.Particle
local LocalGameHeroCount 			= Game.HeroCount;
local LocalGameHero 				= Game.Hero;
local LocalGameMinionCount 			= Game.MinionCount;
local LocalGameMinion 				= Game.Minion;
local LocalGameTurretCount 			= Game.TurretCount;
local LocalGameTurret 				= Game.Turret;
local LocalGameWardCount 			= Game.WardCount;
local LocalGameWard 				= Game.Ward;
local LocalGameObjectCount 			= Game.ObjectCount;
local LocalGameObject				= Game.Object;
local LocalGameMissileCount 		= Game.MissileCount;
local LocalGameMissile				= Game.Missile;
local LocalGameIsChatOpen			= Game.IsChatOpen;
local LocalGameIsOnTop				= Game.IsOnTop;
local STATE_UNKNOWN					= STATE_UNKNOWN;
local STATE_ATTACK					= STATE_ATTACK;
local STATE_WINDUP					= STATE_WINDUP;
local STATE_WINDDOWN				= STATE_WINDDOWN;
local ITEM_1						= ITEM_1;
local ITEM_2						= ITEM_2;
local ITEM_3						= ITEM_3;
local ITEM_4						= ITEM_4;
local ITEM_5						= ITEM_5;
local ITEM_6						= ITEM_6;
local ITEM_7						= ITEM_7;
local _Q							= _Q;
local _W							= _W;
local _E							= _E;
local _R							= _R;
local MOUSEEVENTF_RIGHTDOWN			= MOUSEEVENTF_RIGHTDOWN;
local MOUSEEVENTF_RIGHTUP			= MOUSEEVENTF_RIGHTUP;
local Obj_AI_Barracks				= Obj_AI_Barracks;
local Obj_AI_Hero					= Obj_AI_Hero;
local Obj_AI_Minion					= Obj_AI_Minion;
local Obj_AI_Turret					= Obj_AI_Turret;
local Obj_HQ 						= "obj_HQ";
local pairs							= pairs;
local LocalMathCeil					= math.ceil;
local LocalMathMax					= math.max;
local LocalMathMin					= math.min;
local LocalMathSqrt					= math.sqrt;
local LocalMathRandom				= math.random;
local LocalMathHuge					= math.huge;
local LocalMathAbs					= math.abs;
local LocalStringSub				= string.sub;
local LocalStringLen				= string.len;
local EPSILON						= 1E-12;
local DAMAGE_TYPE_PHYSICAL			= 0;
local DAMAGE_TYPE_MAGICAL			= 1;
local DAMAGE_TYPE_TRUE				= 2;
local MINION_TYPE_OTHER_MINION		= 1;
local MINION_TYPE_MONSTER			= 2;
local MINION_TYPE_LANE_MINION		= 3;
local ORBWALKER_MODE_NONE			= -1
local ORBWALKER_MODE_COMBO			= 0
local ORBWALKER_MODE_HARASS			= 1
local ORBWALKER_MODE_LANECLEAR		= 2
local ORBWALKER_MODE_JUNGLECLEAR	= 3
local ORBWALKER_MODE_LASTHIT		= 4
local ORBWALKER_MODE_FLEE			= 5
local TEAM_ALLY						= myHero.team
local TEAM_ENEMY					= 300 - TEAM_ALLY
local TEAM_JUNGLE					= 300
local MAXIMUM_MOUSE_DISTANCE		= 120 * 120
-- api
META1 =
{
	RESET = function()
		MENU_CHAMP.hold.HoldRadius:Value(120)
		MENU_CHAMP.spell.isaa:Value(true)
		MENU_CHAMP.spell.baa:Value(false)
	end,
	CURSOR = function()
		local c = {}
		local result =
		{
			StartTime = 0,
			IsReady = true,
			IsReadyGlobal = true,
			Key = nil,
			CursorPos = nil,
			CastPos = nil,
			Work = nil,
			WorkDone = true,
			EndTime = 0
		}
		-- init
			c.__index = c
			setmetatable(result, c)
		function c:CastKey()
			if self.CastPos == nil then return end
			local newpos
			if self.CastPos.pos then
				newpos = Vector(self.CastPos.pos.x, self.CastPos.pos.y + self.CastPos.boundingRadius * 0.5, self.CastPos.pos.z):To2D()
			elseif self.CastPos.z then
				newpos = self.CastPos:To2D()
			else
				newpos = self.CastPos
			end
			LocalControlSetCursorPos(newpos.x, newpos.y)
			if self.Work ~= nil then--and Utilities:GetDistance2DSquared(newpos, _G.cursorPos) <= MAXIMUM_MOUSE_DISTANCE then
				self.Work()
				self.Work = nil
			end
		end
		function c:SetCursor(cursorpos, castpos, key, work)
			self.StartTime = LocalGameTimer()
			self.IsReady = false
			self.IsReadyGlobal = false
			self.Key = key
			self.CursorPos = cursorpos
			self.CastPos = castpos
			self.Work = work
			self.WorkDone = false
			self.EndTime = 0
			self:CastKey()
		end
		function c:Tick()
			if self.IsReady then return end
			if not self.WorkDone and (self.IsReadyGlobal or LocalGameTimer() > self.StartTime + 0.1) then
				if not self.IsReadyGlobal then
					self.IsReadyGlobal = true
				end
				local extradelay = MENU.orb.excdelay:Value()
				if extradelay == 0 then
					self.EndTime = 0
				else
					self.EndTime = LocalGameTimer() + extradelay * 0.001
				end
				self.WorkDone = true
			end
			if self.WorkDone and LocalGameTimer() > self.EndTime then
				LocalControlSetCursorPos(self.CursorPos.x, self.CursorPos.y)
				if Utilities:GetDistance2DSquared(self.CursorPos, _G.cursorPos) <= MAXIMUM_MOUSE_DISTANCE then
					self.IsReady = true
				end
				return
			end
			self:CastKey()
		end
		function c:CreateDrawMenu(menu)
			MENU.gsodraw:MenuElement({name = "Cursor Pos",  id = "cursor", type = _G.MENU})
				MENU.gsodraw.cursor:MenuElement({name = "Enabled",  id = "enabled", value = true})
				MENU.gsodraw.cursor:MenuElement({name = "Color",  id = "color", color = LocalDrawColor(255, 153, 0, 76)})
				MENU.gsodraw.cursor:MenuElement({name = "Width",  id = "width", value = 3, min = 1, max = 10})
				MENU.gsodraw.cursor:MenuElement({name = "Radius",  id = "radius", value = 150, min = 1, max = 300})
		end
		function c:Draw()
			if MENU.gsodraw.cursor.enabled:Value() then
				LocalDrawCircle(mousePos, MENU.gsodraw.cursor.radius:Value(), MENU.gsodraw.cursor.width:Value(), MENU.gsodraw.cursor.color:Value())
			end
		end
		return result
	end,
	TS = function()
		local c = {}
		local result =
		{
			SelectedTarget = nil,
			LastSelTick = 0,
			LastHeroTarget = nil,
			Priorities =
			{
				["Aatrox"] = 3,
				["Ahri"] = 4,
				["Akali"] = 4,
				["Alistar"] = 1,
				["Amumu"] = 1,
				["Anivia"] = 4,
				["Annie"] = 4,
				["Ashe"] = 5,
				["AurelionSol"] = 4,
				["Azir"] = 4,
				["Bard"] = 3,
				["Blitzcrank"] = 1,
				["Brand"] = 4,
				["Braum"] = 1,
				["Caitlyn"] = 5,
				["Camille"] = 3,
				["Cassiopeia"] = 4,
				["Chogath"] = 1,
				["Corki"] = 5,
				["Darius"] = 2,
				["Diana"] = 4,
				["DrMundo"] = 1,
				["Draven"] = 5,
				["Ekko"] = 4,
				["Elise"] = 3,
				["Evelynn"] = 4,
				["Ezreal"] = 5,
				["Fiddlesticks"] = 3,
				["Fiora"] = 3,
				["Fizz"] = 4,
				["Galio"] = 1,
				["Gangplank"] = 4,
				["Garen"] = 1,
				["Gnar"] = 1,
				["Gragas"] = 2,
				["Graves"] = 4,
				["Hecarim"] = 2,
				["Heimerdinger"] = 3,
				["Illaoi"] = 3,
				["Irelia"] = 3,
				["Ivern"] = 1,
				["Janna"] = 2,
				["JarvanIV"] = 3,
				["Jax"] = 3,
				["Jayce"] = 4,
				["Jhin"] = 5,
				["Jinx"] = 5,
				["Kaisa"] = 5,
				["Kalista"] = 5,
				["Karma"] = 4,
				["Karthus"] = 4,
				["Kassadin"] = 4,
				["Katarina"] = 4,
				["Kayle"] = 4,
				["Kayn"] = 4,
				["Kennen"] = 4,
				["Khazix"] = 4,
				["Kindred"] = 4,
				["Kled"] = 2,
				["KogMaw"] = 5,
				["Leblanc"] = 4,
				["LeeSin"] = 3,
				["Leona"] = 1,
				["Lissandra"] = 4,
				["Lucian"] = 5,
				["Lulu"] = 3,
				["Lux"] = 4,
				["Malphite"] = 1,
				["Malzahar"] = 3,
				["Maokai"] = 2,
				["MasterYi"] = 5,
				["MissFortune"] = 5,
				["MonkeyKing"] = 3,
				["Mordekaiser"] = 4,
				["Morgana"] = 3,
				["Nami"] = 3,
				["Nasus"] = 2,
				["Nautilus"] = 1,
				["Nidalee"] = 4,
				["Nocturne"] = 4,
				["Nunu"] = 2,
				["Olaf"] = 2,
				["Orianna"] = 4,
				["Ornn"] = 2,
				["Pantheon"] = 3,
				["Poppy"] = 2,
				["Pyke"] = 4,
				["Quinn"] = 5,
				["Rakan"] = 3,
				["Rammus"] = 1,
				["RekSai"] = 2,
				["Renekton"] = 2,
				["Rengar"] = 4,
				["Riven"] = 4,
				["Rumble"] = 4,
				["Ryze"] = 4,
				["Sejuani"] = 2,
				["Shaco"] = 4,
				["Shen"] = 1,
				["Shyvana"] = 2,
				["Singed"] = 1,
				["Sion"] = 1,
				["Sivir"] = 5,
				["Skarner"] = 2,
				["Sona"] = 3,
				["Soraka"] = 3,
				["Swain"] = 3,
				["Syndra"] = 4,
				["TahmKench"] = 1,
				["Taliyah"] = 4,
				["Talon"] = 4,
				["Taric"] = 1,
				["Teemo"] = 4,
				["Thresh"] = 1,
				["Tristana"] = 5,
				["Trundle"] = 2,
				["Tryndamere"] = 4,
				["TwistedFate"] = 4,
				["Twitch"] = 5,
				["Udyr"] = 2,
				["Urgot"] = 2,
				["Varus"] = 5,
				["Vayne"] = 5,
				["Veigar"] = 4,
				["Velkoz"] = 4,
				["Vi"] = 2,
				["Viktor"] = 4,
				["Vladimir"] = 3,
				["Volibear"] = 2,
				["Warwick"] = 2,
				["Xayah"] = 5,
				["Xerath"] = 4,
				["XinZhao"] = 3,
				["Yasuo"] = 4,
				["Yorick"] = 2,
				["Zac"] = 1,
				["Zed"] = 4,
				["Ziggs"] = 4,
				["Zilean"] = 3,
				["Zoe"] = 4,
				["Zyra"] = 2
			},
			PriorityMultiplier =
			{
				[1] = 1.6,
				[2] = 1.45,
				[3] = 1.3,
				[4] = 1.15,
				[5] = 1
			}
		}
		-- init
			c.__index = c
			setmetatable(result, c)
		function c:GetTarget(a, dmgType, bb, validmode)
			local SelectedID = -1
			--selected:
			if MENU.ts.selected.enable:Value() and self.SelectedTarget ~= nil and Utilities:IsValidTarget(self.SelectedTarget) and not OB:IsHeroImmortal(self.SelectedTarget, false) and self.SelectedTarget.pos.onScreen then
				SelectedID = self.SelectedTarget.networkID
				if MENU.ts.selected.onlysel:Value() then
					if type(a) == "number" then
						if Utilities:GetDistanceSquared(myHero.pos, self.SelectedTarget.pos) <= a * a then
							return self.SelectedTarget
						end
					elseif type(a) == "table" then
						local x = 0
						for i = 1, #a do
							local u = a[i]
							if u then
								local dist = Utilities:GetDistanceSquared(myHero.pos, u.pos)
								if dist > x then
									x = dist
								end
							end
						end
						if Utilities:GetDistanceSquared(myHero.pos, self.SelectedTarget.pos) <= x * x then
							return self.SelectedTarget
						end
					end
					return nil
				end
			end
			--others:
			if dmdType == nil or dmgType < 0 or dmgType > 2 then
				dmgType = 1
			end
			local result = nil
			if type(a) == "table" then
				if #a == 1 then return a[1] end
				local num = 10000000
				local mode = MENU.ts.Mode:Value()
				for i = 1, #a do
					local x
					local unit = a[i]
					if SelectedID ~= -1 and SelectedID == unit.networkID then
						return self.SelectedTarget
					elseif mode == 1 then
						local unitName = unit.charName
						local priority
						if MENU.ts.priorities[unitName] then
							priority = MENU.ts.priorities[unitName]:Value()
						else
							priority = 1
						end
						local multiplier = self.PriorityMultiplier[priority]
						local def
						if dmgType == DAMAGE_TYPE_MAGICAL then
							def = multiplier * (unit.magicResist - myHero.magicPen)
						elseif dmgType == DAMAGE_TYPE_PHYSICAL then
							def = multiplier * (unit.armor - myHero.armorPen)
						else
							def = 0
						end
						if def and def > 0 then
							if dmgType == DAMAGE_TYPE_MAGICAL then
								def = myHero.magicPenPercent * def
							elseif dmgType == DAMAGE_TYPE_PHYSICAL then
								def = myHero.bonusArmorPenPercent * def
							else
								def = 0
							end
						end
						x = ( ( unit.health * multiplier * ( ( 100 + def ) / 100 ) ) - ( unit.totalDamage * unit.attackSpeed * 2 ) ) - unit.ap
					elseif mode == 2 then
						x = unit.pos:DistanceTo(myHero.pos)
					elseif mode == 3 then
						x = unit.health
					elseif mode == 4 then
						local unitName = unit.charName
						if MENU.ts.priorities[unitName] then
							x = MENU.ts.priorities[unitName]:Value()
						else
							x = 1
						end
					end
					if x < num then
						num = x
						result = unit
					end
				end
			else
				local bbox = false
				if bb ~= nil and bb == true then bbox = true end
				local vmode = validmode or 0
				if a == nil or a <= 0 then
					a = 20000
				end
				return self:GetTarget(OB:GetEnemyHeroes(a, bbox, vmode), dmgType)
			end
			return result
		end
		function c:GetComboTarget()
			local targets = {}
			local range = myHero.range - 20
			local bbox = myHero.boundingRadius
			for i = 1, LocalGameHeroCount() do
				local hero = LocalGameHero(i)
				if hero and hero.team == TEAM_ENEMY and Utilities:IsValidTarget(hero) and not OB:IsHeroImmortal(hero, true) then
					local herorange = range
					if MYHERO_IS_CAITLYN and BuffManager:HasBuff(hero, "caitlynyordletrapinternal") then
						herorange = herorange + 600
					else
						herorange = herorange + bbox + hero.boundingRadius
					end
					if Utilities:GetDistanceSquared(myHero.pos, hero.pos) <= herorange * herorange then
						targets[#targets+1] = hero
					end
				end
			end
			local comboT = self:GetTarget(targets, DAMAGE_TYPE_PHYSICAL)
			if comboT ~= nil then
				self.LastHeroTarget = comboT
			end
			return comboT
		end
		function c:WndMsg(msg, wParam)
			if msg == WM_LBUTTONDOWN and MENU.ts.selected.enable:Value() and GetTickCount() > self.LastSelTick + 100 then
				self.SelectedTarget = nil
				local num = 10000000
				local enemyList = OB:GetEnemyHeroes(99999999, false, 2)
				for i = 1, #enemyList do
					local unit = enemyList[i]
					local distance = mousePos:DistanceTo(unit.pos)
					if distance < 150 and distance < num then
						self.SelectedTarget = unit
						num = distance
					end
				end
				self.LastSelTick = GetTickCount()
			end
		end
		function c:Draw()
			if MENU.gsodraw.selected.enabled:Value() then
				if self.SelectedTarget and not self.SelectedTarget.dead and self.SelectedTarget.isTargetable and self.SelectedTarget.visible and self.SelectedTarget.valid then
					LocalDrawCircle(self.SelectedTarget.pos, MENU.gsodraw.selected.radius:Value(), MENU.gsodraw.selected.width:Value(), MENU.gsodraw.selected.color:Value())
				end
			end
		end
		function c:CreatePriorityMenu(charName)
			local priority
			if self.Priorities[charName] ~= nil then
				priority = self.Priorities[charName]
			else
				priority = 1
			end
			MENU.ts.priorities:MenuElement({ id = charName, name = charName, value = priority, min = 1, max = 5, step = 1 })
		end
		function c:CreateMenu()
			MENU:MenuElement({name = "Target Selector", id = "ts", type = _G.MENU, leftIcon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/ts.png" })
				MENU.ts:MenuElement({ id = "Mode", name = "Mode", value = 1, drop = { "Auto", "Closest", "Least Health", "Highest Priority" } })
				MENU.ts:MenuElement({ id = "priorities", name = "Priorities", type = _G.MENU })
					OB:OnEnemyHeroLoad(function(hero) self:CreatePriorityMenu(hero.charName) end)
				MENU.ts:MenuElement({ id = "selected", name = "Selected Target", type = _G.MENU })
					MENU.ts.selected:MenuElement({ id = "enable", name = "Enabled", value = true })
					MENU.ts.selected:MenuElement({ id = "onlysel", name = "Only Selected", value = false })
		end
		function c:CreateDrawMenu()
			MENU.gsodraw:MenuElement({name = "Selected Target",  id = "selected", type = _G.MENU})
				MENU.gsodraw.selected:MenuElement({name = "Enabled",  id = "enabled", value = true})
				MENU.gsodraw.selected:MenuElement({name = "Color",  id = "color", color = LocalDrawColor(255, 204, 0, 0)})
				MENU.gsodraw.selected:MenuElement({name = "Width",  id = "width", value = 3, min = 1, max = 10})
				MENU.gsodraw.selected:MenuElement({name = "Radius",  id = "radius", value = 150, min = 1, max = 300})
		end
		return result
	end,
	FARM = function()
		local c = {}
		local result =
		{
			OnUnkillableC = {},
			CachedTeamEnemy = {},
			CachedTeamAlly = {},
			CachedTeamJungle = {},
			CachedAttackData = {},
			CachedAttacks = {},
			TurretHasTarget = false,
			CanCheckTurret = true,
			ShouldWaitTime = 0,
			IsLastHitable = false,
			LastHandle = 0,
			LastLCHandle = 0,
			FarmMinions = {}
		}
		-- init
			c.__index = c
			setmetatable(result, c)
		function c:CreateDrawMenu()
			MENU.gsodraw:MenuElement({name = "LastHitable Minion",  id = "lasthit", type = _G.MENU})
				MENU.gsodraw.lasthit:MenuElement({name = "Enabled",  id = "enabled", value = true})
				MENU.gsodraw.lasthit:MenuElement({name = "Color",  id = "color", color = LocalDrawColor(150, 255, 255, 255)})
				MENU.gsodraw.lasthit:MenuElement({name = "Width",  id = "width", value = 3, min = 1, max = 10})
				MENU.gsodraw.lasthit:MenuElement({name = "Radius",  id = "radius", value = 50, min = 1, max = 100})
			MENU.gsodraw:MenuElement({name = "Almost LastHitable Minion",  id = "almostlasthit", type = _G.MENU})
				MENU.gsodraw.almostlasthit:MenuElement({name = "Enabled",  id = "enabled", value = true})
				MENU.gsodraw.almostlasthit:MenuElement({name = "Color",  id = "color", color = LocalDrawColor(150, 239, 159, 55)})
				MENU.gsodraw.almostlasthit:MenuElement({name = "Width",  id = "width", value = 3, min = 1, max = 10})
				MENU.gsodraw.almostlasthit:MenuElement({name = "Radius",  id = "radius", value = 50, min = 1, max = 100})
		end
		function c:GetJungleTarget()
			local result = nil
			local health = 200000
			local targets = Linq:Join(ObjectManager:GetMonstersInAutoAttackRange(), ObjectManager:GetOtherEnemyMinionsInAutoAttackRange())
			for i = 1, #targets do
				local obj = targets[i]
				if obj and obj.health < health then
					health = obj.health
					result = obj
				end
			end
			return result
		end
		function c:GetLastHitTarget()
			local min = 10000000
			local result = nil
			for i = 1, #self.FarmMinions do
				local minion = self.FarmMinions[i]
				if not minion.Minion.dead and minion.LastHitable and minion.PredictedHP < min and Utilities:IsValidTarget(minion.Minion) and Utilities:IsInAutoAttackRange(myHero, minion.Minion) then
					min = minion.PredictedHP
					result = minion.Minion
				end
			end
			return result
		end
		function c:GetLaneClearTarget()
			local enemyTurrets = OB:GetEnemyTurrets(myHero.range+myHero.boundingRadius - 35, true)
			if #enemyTurrets >= 1 then return enemyTurrets[1] end
			if MENU.orb.lclear.laneset:Value() then
				local result = TS:GetComboTarget()
				if result then return result end
			end
			local result = nil
			if LocalGameTimer() > self.ShouldWaitTime + MENU.orb.lclear.swait:Value() * 0.001 then
				local min = 10000000
				for i = 1, #self.FarmMinions do
					local target = self.FarmMinions[i]
					if not target.Minion.dead and target.PredictedHP < min and Utilities:IsValidTarget(target.Minion) and Utilities:IsInAutoAttackRange(myHero, target.Minion) then
						min = target.PredictedHP
						result = target.Minion
					end
				end
			end
			return result
		end
		function c:SetObjects(team)
			if team == TEAM_ALLY then
				if #self.CachedTeamAlly > 0 then
					return
				end
			elseif team == TEAM_ENEMY then
				if #self.CachedTeamEnemy > 0 then
					return
				end
			elseif team == TEAM_JUNGLE then
				if #self.CachedTeamJungle > 0 then
					return
				end
			end
			for i = 1, LocalGameMinionCount() do
				local obj = LocalGameMinion(i)
				if obj and obj.team ~= team and Utilities:IsValidTarget(obj) then
					if team == TEAM_ALLY then
						self.CachedTeamAlly[#self.CachedTeamAlly+1] = obj
					elseif team == TEAM_ENEMY then
						self.CachedTeamEnemy[#self.CachedTeamEnemy+1] = obj
					else
						self.CachedTeamJungle[#self.CachedTeamJungle+1] = obj
					end
				end
			end
			for i = 1, LocalGameHeroCount() do
				local obj = LocalGameHero(i)
				if obj and obj.team ~= team and not obj.isMe and Utilities:IsValidTarget(obj) then
					if team == TEAM_ALLY then
						self.CachedTeamAlly[#self.CachedTeamAlly+1] = obj
					elseif team == TEAM_ENEMY then
						self.CachedTeamEnemy[#self.CachedTeamEnemy+1] = obj
					else
						self.CachedTeamJungle[#self.CachedTeamJungle+1] = obj
					end
				end
			end
			local turrets = Linq:Join(OBJECTS.EnemyTurrets, OBJECTS.AllyTurrets)
			for i = 1, #turrets do
				local obj = turrets[i]
				if obj and obj.team ~= team and Utilities:IsValidTarget(obj) then
					if team == TEAM_ALLY then
						self.CachedTeamAlly[#self.CachedTeamAlly+1] = obj
					elseif team == TEAM_ENEMY then
						self.CachedTeamEnemy[#self.CachedTeamEnemy+1] = obj
					else
						self.CachedTeamJungle[#self.CachedTeamJungle+1] = obj
					end
				end
			end
		end
		function c:GetObjects(team)
			if team == TEAM_ALLY then
				return self.CachedTeamAlly
			elseif team == TEAM_ENEMY then
				return self.CachedTeamEnemy
			elseif team == TEAM_JUNGLE then
				return self.CachedTeamJungle
			end
		end
		function c:SetAttacks(target)
			-- target handle
			local handle = target.handle
			-- Cached Attacks
			if self.CachedAttacks[handle] == nil then
				self.CachedAttacks[handle] = {}
				-- target team
				local team = target.team
				-- charName
				local name = target.charName
				-- set attacks
				local pos = target.pos
				-- cached objects
				self:SetObjects(team)
				local attackers = self:GetObjects(team)
				for i = 1, #attackers do
					local obj = attackers[i]
					local objname = obj.charName
					if self.CachedAttackData[objname] == nil then
						self.CachedAttackData[objname] = {}
					end
					if self.CachedAttackData[objname][name] == nil then
						self.CachedAttackData[objname][name] = { Range = Utilities:GetAutoAttackRange(obj, target), Damage = 0 }
					end
					local range = self.CachedAttackData[objname][name].Range + 250
					if Utilities:GetDistanceSquared(obj.pos, pos) < range * range then
						if self.CachedAttackData[objname][name].Damage == 0 then
							self.CachedAttackData[objname][name].Damage = Damage:GetAutoAttackDamage(obj, target)
						end
						self.CachedAttacks[handle][#self.CachedAttacks[handle]+1] = {
							Attacker = obj,
							Damage = self.CachedAttackData[objname][name].Damage,
							Type = obj.type
						}
					end
				end
			end
			return self.CachedAttacks[handle]
		end
		function c:GetPossibleDmg(target)
			local result = 0
			local handle = target.handle
			local attacks = FARM.CachedAttacks[handle]
			if #attacks == 0 then return 0 end
			local pos = target.pos
			for i = 1, #attacks do
				local attack = attacks[i]
				local attacker = attack.Attacker
				if (not self.TurretHasTarget and attack.Type == Obj_AI_Turret) or (attack.Type == Obj_AI_Minion and attacker.pathing.hasMovePath) then
					result = result + attack.Damage
				end
			end
			return result
		end
		function c:GetPrediction(target, time)
			self:SetAttacks(target)
			local handle = target.handle
			local attacks = self.CachedAttacks[handle]
			local hp = Utilities:TotalShieldHealth(target)
			if #attacks == 0 then return hp end
			local pos = target.pos
			for i = 1, #attacks do
				local attack = attacks[i]
				local attacker = attack.Attacker
				local dmg = attack.Damage
				local objtype = attack.Type
				local isTurret = objtype == Obj_AI_Turret
				local ismoving = false
				if not isTurret then ismoving = attacker.pathing.hasMovePath end
				if attacker.attackData.target == handle and not ismoving then
					if isTurret and self.CanCheckTurret then
						self.TurretHasTarget = true
					end
					local flyTime
					local time2 = time
					local projSpeed = attacker.attackData.projectileSpeed; if isTurret then projSpeed = 700; time2 = time2 - 0.1; end
					if projSpeed and projSpeed > 0 then
						flyTime = attacker.pos:DistanceTo(pos) / projSpeed
					else
						flyTime = 0
					end
					local endTime = (attacker.attackData.endTime - attacker.attackData.animationTime) + flyTime + attacker.attackData.windUpTime
					if endTime <= LocalGameTimer() then
						endTime = endTime + attacker.attackData.animationTime + flyTime
					end
					while endTime - LocalGameTimer() < time2 do
						hp = hp - dmg
						endTime = endTime + attacker.attackData.animationTime + flyTime
					end
				end
			end
			return hp
		end
		function c:SetLastHitable(target, time, damage)
			local hpPred = self:GetPrediction(target, time)
			if hpPred < 0 then
				for i = 1, #self.OnUnkillableC do
					self.OnUnkillableC[i](target)
				end
			end
			local lastHitable = hpPred - damage < 0
			if lastHitable then self.IsLastHitable = true end
			local almostLastHitable = false
			if not lastHitable then
				local dmg = self:GetPrediction(target, (myHero.attackData.animationTime * 1.5) + (time * 3)) - self:GetPossibleDmg(target)
				almostLastHitable = dmg - damage < 0
			end
			if almostLastHitable then
				self.ShouldWaitTime = LocalGameTimer()
			end
			return { LastHitable =  lastHitable, Unkillable = hpPred < 0, AlmostLastHitable = almostLastHitable, PredictedHP = hpPred, Minion = target }
		end
		function c:Tick()
			self.CachedAttackData = {}
			self.CachedAttacks = {}
			self.FarmMinions = {}
			self.CachedTeamEnemy = {}
			self.CachedTeamAlly = {}
			self.CachedTeamJungle = {}
			self.TurretHasTarget = false
			self.CanCheckTurret = true
			self.IsLastHitable = false
			if Orbwalker.IsNone or Orbwalker.Modes[ORBWALKER_MODE_COMBO] then
				self.CanCheckTurret = false
				return
			end
			local targets = OB:GetEnemyMinions(myHero.range + myHero.boundingRadius, true)
			local projectileSpeed = UTILS:GetProjSpeed()
			local winduptime = UTILS:GetWindup() - (MENU.orb.lclear.extrafarm:Value() * 0.001)
			local latency = UTILS:GetLatency(0) * 0.5
			local pos = myHero.pos
			for i = 1, #targets do
				local target = targets[i]
				local FlyTime = pos:DistanceTo(target.pos) / projectileSpeed
				self.FarmMinions[#self.FarmMinions+1] = self:SetLastHitable(target, winduptime + FlyTime + latency, Damage:GetAutoAttackDamage(myHero, target))
			end
			self.CanCheckTurret = false
		end
		function c:Draw()
			if Orbwalker.Modes[ORBWALKER_MODE_COMBO] then return end
			if MENU.gsodraw.lasthit.enabled:Value() or MENU.gsodraw.almostlasthit.enabled:Value() then
				local tm = self.FarmMinions
				for i = 1, #tm do
					local minion = tm[i]
					if minion.LastHitable and MENU.gsodraw.lasthit.enabled:Value() then
						LocalDrawCircle(minion.Minion.pos,MENU.gsodraw.lasthit.radius:Value(),MENU.gsodraw.lasthit.width:Value(),MENU.gsodraw.lasthit.color:Value())
					elseif minion.AlmostLastHitable and MENU.gsodraw.almostlasthit.enabled:Value() then
						LocalDrawCircle(minion.Minion.pos,MENU.gsodraw.almostlasthit.radius:Value(),MENU.gsodraw.almostlasthit.width:Value(),MENU.gsodraw.almostlasthit.color:Value())
					end
				end
			end
		end
		return result
	end,
	OB = function()
		local c = {}
		local result =
		{
			UndyingBuffs = { ["zhonyasringshield"] = true }
		}
		-- init
			c.__index = c
			setmetatable(result, c)
		function c:OnAllyHeroLoad(func)
			OBJECTS.OnAllyHeroLoad[#OBJECTS.OnAllyHeroLoad+1] = func
		end
		function c:OnEnemyHeroLoad(func)
			OBJECTS.OnEnemyHeroLoad[#OBJECTS.OnEnemyHeroLoad+1] = func
		end
		function c:IsHeroImmortal(unit, jaxE)
			local hp = 100 * ( unit.health / unit.maxHealth )
			if self.UndyingBuffs["JaxCounterStrike"] ~= nil then self.UndyingBuffs["JaxCounterStrike"] = jaxE end
			if self.UndyingBuffs["kindredrnodeathbuff"] ~= nil then self.UndyingBuffs["kindredrnodeathbuff"] = hp < 10 end
			if self.UndyingBuffs["UndyingRage"] ~= nil then self.UndyingBuffs["UndyingRage"] = hp < 15 end
			if self.UndyingBuffs["ChronoShift"] ~= nil then self.UndyingBuffs["ChronoShift"] = hp < 15; self.UndyingBuffs["chronorevive"] = hp < 15 end
			for i = 0, unit.buffCount do
				local buff = unit:GetBuff(i)
				if buff and buff.count > 0 and self.UndyingBuffs[buff.name] then
					return true
				end
			end
			return false
		end
		function c:GetEnemyHeroes(range, bb, state)
			local result = {}
			--state "spell" = 0
			--state "attack" = 1
			--state "immortal" = 2
			for i = 1, LocalGameHeroCount() do
				local hero = LocalGameHero(i)
				local r = bb and range + hero.boundingRadius or range
				if hero and hero.team == TEAM_ENEMY and Utilities:IsValidTarget(hero) and Utilities:GetDistanceSquared(myHero.pos, hero.pos) < r * r then
					local immortal = false
					if state == 0 then
						immortal = self:IsHeroImmortal(hero, false)
					elseif state == 1 then
						immortal = self:IsHeroImmortal(hero, true)
					end
					if not immortal then
						result[#result+1] = hero
					end
				end
			end
			return result
		end
		function c:GetEnemyTurrets(range, bb)
			local result = {}
			local turrets = OBJECTS.EnemyTurrets
			local inhibitors = OBJECTS.EnemyInhibitors
			local nexus = OBJECTS.EnemyNexus
			local br = bb and range + 270 - 30 or range --myHero.range + 270 bbox
			local nr = bb and range + 380 - 30 or range --myHero.range + 380 bbox
			for i = 1, #turrets do
				local turret = turrets[i]
				local tr = bb and range + turret.boundingRadius * 0.75 or range
				if turret and Utilities:IsValidTarget(turret) and Utilities:GetDistanceSquared(myHero.pos, turret.pos) < tr * tr then
					result[#result+1] = turret
				end
			end
			for i = 1, #inhibitors do
				local barrack = inhibitors[i]
				if barrack and barrack.isTargetable and barrack.visible and Utilities:GetDistanceSquared(myHero.pos, barrack.pos) < br * br then
					result[#result+1] = barrack
				end
			end
			if nexus and nexus.isTargetable and nexus.visible and Utilities:GetDistanceSquared(myHero.pos, nexus.pos) < nr * nr then
				result[#result+1] = nexus
			end
			return result
		end
		function c:GetAllyMinions(range, bb)
			local result = {}
			for i = 1, LocalGameMinionCount() do
				local minion = LocalGameMinion(i)
				local mr = bb and range + minion.boundingRadius or range
				if minion and minion.team == TEAM_ALLY and Utilities:IsValidTarget(minion) and Utilities:GetDistanceSquared(myHero.pos, minion.pos) < mr * mr then
					result[#result+1] = minion
				end
			end
			return result
		end
		function c:GetEnemyMinions(range, bb)
			local result = {}
			for i = 1, LocalGameMinionCount() do
				local minion = LocalGameMinion(i)
				local mr = bb and range + minion.boundingRadius or range
				if minion and minion.team ~= TEAM_ALLY and Utilities:IsValidTarget(minion) and Utilities:GetDistanceSquared(myHero.pos, minion.pos) < mr * mr then
					result[#result+1] = minion
				end
			end
			return result
		end
		return result
	end,
	ORB = function()
		local c = {}
		local result =
		{
			ChampionCanMove = {
				["Thresh"] = function()
					if myHero.pathing.isDashing then
						ORB.ThreshLastDash = LocalGameTimer()
					end
					local currentTime = LocalGameTimer()
					local lastDash = currentTime - ORB.ThreshLastDash
					if lastDash < 0.25 then
						return false
					end
					return true
				end
			},
			-- Thresh
			ThreshLastDash = 0,
			-- Attack
			ResetAttack = false,
			AttackStartTime = 0,
			AttackCastEndTime = 0,
			AttackLocalStart = 0,
			AutoAttackResets =
			{
				["Blitzcrank"] = { Slot = _E, toggle = true },
				["Camille"] = { Slot = _Q },
				["Chogath"] = { Slot = _E, toggle = true },
				["Darius"] = { Slot = _W, toggle = true },
				["DrMundo"] = { Slot = _E },
				["Elise"] = { Slot = _W, Name = "EliseSpiderW"},
				["Fiora"] = { Slot = _E },
				["Garen"] = { Slot = _Q , toggle = true },
				["Graves"] = { Slot = _E },
				["Kassadin"] = { Slot = _W, toggle = true },
				["Illaoi"] = { Slot = _W },
				["Jax"] = { Slot = _W, toggle = true },
				["Jayce"] = { Slot = _W, Name = "JayceHyperCharge"},
				["Katarina"] = { Slot = _E },
				["Kindred"] = { Slot = _Q },
				["Leona"] = { Slot = _Q, toggle = true },
				["Lucian"] = { Slot = _E },
				["MasterYi"] = { Slot = _W },
				["Mordekaiser"] = { Slot = _Q, toggle = true },
				["Nautilus"] = { Slot = _W },
				["Nidalee"] = { Slot = _Q, Name = "Takedown", toggle = true },
				["Nasus"] = { Slot = _Q, toggle = true },
				["RekSai"] = { Slot = _Q, Name = "RekSaiQ" },
				["Renekton"] = { Slot = _W, toggle = true },
				["Rengar"] = { Slot = _Q },
				["Riven"] = { Slot = _Q },
				["Sejuani"] = { Slot = _W },
				["Sivir"] = { Slot = _W },
				["Trundle"] = { Slot = _Q, toggle = true },
				["Vayne"] = { Slot = _Q, toggle = true },
				["Vi"] = { Slot = _E, toggle = true },
				["Volibear"] = { Slot = _Q, toggle = true },
				["MonkeyKing"] = { Slot = _Q, toggle = true },
				["XinZhao"] = { Slot = _Q, toggle = true },
				["Yorick"] = { Slot = _Q, toggle = true }
			},
			SpecialAutoAttacks = {
				["CaitlynHeadshotMissile"] = true,
				["GarenQAttack"] = true,
				["KennenMegaProc"] = true,
				["MordekaiserQAttack"] = true,
				["MordekaiserQAttack1"] = true,
				["MordekaiserQAttack2"] = true,
				["QuinnWEnhanced"] = true,
				["BlueCardPreAttack"] = true,
				["RedCardPreAttack"] = true,
				["GoldCardPreAttack"] = true,
				["XenZhaoThrust"] = true,
				["XenZhaoThrust2"] = true,
				["XenZhaoThrust3"] = true
			},
			-- Move
			LastMoveLocal = 0,
			LastMoveTime = 0,
			LastMovePos = myHero.pos,
			LastPostAttack = 0,
			-- Mouse
			LastMouseDown = 0,
			-- Callbacks
			OnPreAttackC = {},
			OnPostAttackC = {},
			OnPostAttackTickC = {},
			OnAttackC = {},
			OnPreMoveC = {},
			OnTickC = {},
			-- Debug
			TestCount = 0,
			TestStartTime = 0,
			-- Other
			PostAttackBool = false,
			AttackEnabled = true,
			MovementEnabled = true,
			IsTeemo = false,
			IsBlindedByTeemo = false,
			CanAttackC = function() return true end,
			CanMoveC = function() return true end
		}
		-- init
			c.__index = c
			setmetatable(result, c)
		function c:CreateMenu()
			MENU:MenuElement({name = "Orbwalker", id = "orb", type = _G.MENU, leftIcon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/orb.png" })
				MENU.orb:MenuElement({ name = "Latency", id = "clat", value = 50, min = 0, max = 150, step = 1 })
				MENU.orb:MenuElement({ name = "Extra Windup", id = "extrawindup", value = 0, min = 0, max = 30, step = 1 })
				MENU.orb:MenuElement({ name = "Extra Cursor Delay", id = "excdelay", value = 25, min = 0, max = 50, step = 5 })
				MENU.orb:MenuElement({name = "Player Attack Move Click", id = "aamoveclick", key = string.byte("U")})
				--[[MENU.orb:MenuElement({ name = "Orbwalker Timers", id = "lcore", type = _G.MENU })
					MENU.orb.lcore:MenuElement({name = "ON - Local, OFF - Server", id = "enabled", value = false })
					MENU.orb.lcore:MenuElement({ name = "Server Extra Windup", id = "extrawindup", value = 0, min = 0, max = 100, step = 1 })
					MENU.orb.lcore:MenuElement({ name = "Local Extra Windup (higher = slower kite)", id = "extraw", value = 0, min = 0, max = 150, step = 1 })
					MENU.orb.lcore:MenuElement({ name = "Local Extra Anim (higher = less dps)", id = "extraa", value = 0, min = 0, max = 100, step = 1 })--]]
				MENU.orb:MenuElement({ name = "LaneClear", id = "lclear", type = _G.MENU })
					MENU.orb.lclear:MenuElement({name = "Attack Heroes", id = "laneset", value = true })
					MENU.orb.lclear:MenuElement({name = "Extra Farm Delay", id = "extrafarm", value = 50, min = 0, max = 100, step = 1 })
					MENU.orb.lclear:MenuElement({name = "Should Wait Time", id = "swait", value = 500, min = 0, max = 1000, step = 100 })
				MENU_CHAMP = MENU.orb:MenuElement({name = LocalCharName, id = LocalCharName, type = _G.MENU})
					MENU_CHAMP:MenuElement({ name = "Spell Manager", id = "spell", type = _G.MENU })
						MENU_CHAMP.spell:MenuElement({name = "Block if is attacking", id = "isaa", value = true })
						MENU_CHAMP.spell:MenuElement({name = "Spells between attacks", id = "baa", value = false })
					MENU_CHAMP:MenuElement({ name = "Hold Radius", id = "hold", type = _G.MENU })
						MENU_CHAMP.hold:MenuElement({ id = "HoldRadius", name = "Hold Radius", value = 120, min = 100, max = 250, step = 10 })
							Orbwalker.Menu.General.HoldRadius = MENU_CHAMP.hold.HoldRadius
						MENU_CHAMP.hold:MenuElement({ id = "HoldPosButton", name = "Hold position button", key = string.byte("H"), tooltip = "Should be same in game keybinds", onKeyChange = function(kb) HoldPositionButton = kb; end });
							HoldPositionButton = MENU_CHAMP.hold.HoldPosButton:Key()
					MENU_CHAMP:MenuElement({ name = "Default Settings Key", id = "dkey", type = _G.MENU })
						MENU_CHAMP.dkey:MenuElement({name = "Hold together !", id = "space", type = SPACE})
						MENU_CHAMP.dkey:MenuElement({name = "1", id = "def1", key = string.byte("U"), callback = function() if MENU_CHAMP.dkey.def2:Value() then META1.RESET() end end})
						MENU_CHAMP.dkey:MenuElement({name = "2", id = "def2", key = string.byte("Y"), callback = function() if MENU_CHAMP.dkey.def1:Value() then META1.RESET() end end})
				MENU.orb:MenuElement({name = "Keys", id = "keys", type = _G.MENU})
					MENU.orb.keys:MenuElement({name = "Combo Key", id = "combo", key = string.byte(" ")})
						Orbwalker:RegisterMenuKey(ORBWALKER_MODE_COMBO, MENU.orb.keys.combo)
					MENU.orb.keys:MenuElement({name = "Harass Key", id = "harass", key = string.byte("C")})
						Orbwalker:RegisterMenuKey(ORBWALKER_MODE_HARASS, MENU.orb.keys.harass)
					MENU.orb.keys:MenuElement({name = "LastHit Key", id = "lasthit", key = string.byte("X")})
						Orbwalker:RegisterMenuKey(ORBWALKER_MODE_LASTHIT, MENU.orb.keys.lasthit)
					MENU.orb.keys:MenuElement({name = "LaneClear Key", id = "laneclear", key = string.byte("V")})
						Orbwalker:RegisterMenuKey(ORBWALKER_MODE_LANECLEAR, MENU.orb.keys.laneclear)
					MENU.orb.keys:MenuElement({name = "Jungle Key", id = "jungle", key = string.byte("V")})
						Orbwalker:RegisterMenuKey(ORBWALKER_MODE_JUNGLECLEAR, MENU.orb.keys.jungle)
					MENU.orb.keys:MenuElement({name = "Flee Key", id = "flee", key = string.byte("A")})
						Orbwalker:RegisterMenuKey(ORBWALKER_MODE_FLEE, MENU.orb.keys.flee)
				MENU.orb:MenuElement({ name = "Humanizer", id = "humanizer", type = _G.MENU })
					MENU.orb.humanizer:MenuElement({ name = "Random", id = "random", type = _G.MENU })
						MENU.orb.humanizer.random:MenuElement({name = "Enabled", id = "enabled", value = true })
						MENU.orb.humanizer.random:MenuElement({name = "From", id = "from", value = 150, min = 60, max = 300, step = 20 })
						MENU.orb.humanizer.random:MenuElement({name = "To", id = "to", value = 220, min = 60, max = 400, step = 20 })
					MENU.orb.humanizer:MenuElement({name = "Humanizer", id = "standard", value = 200, min = 60, max = 300, step = 10 })
						Orbwalker.Menu.General.MovementDelay = MENU.orb.humanizer.standard
		end
		function c:CreateDrawMenu(menu)
			MENU.gsodraw:MenuElement({name = "MyHero Attack Range", id = "me", type = _G.MENU})
				MENU.gsodraw.me:MenuElement({name = "Enabled",  id = "enabled", value = true})
				MENU.gsodraw.me:MenuElement({name = "Color",  id = "color", color = LocalDrawColor(150, 49, 210, 0)})
				MENU.gsodraw.me:MenuElement({name = "Width",  id = "width", value = 1, min = 1, max = 10})
			MENU.gsodraw:MenuElement({name = "Enemy Attack Range", id = "he", type = _G.MENU})
				MENU.gsodraw.he:MenuElement({name = "Enabled",  id = "enabled", value = true})
				MENU.gsodraw.he:MenuElement({name = "Color",  id = "color", color = LocalDrawColor(150, 255, 0, 0)})
				MENU.gsodraw.he:MenuElement({name = "Width",  id = "width", value = 1, min = 1, max = 10})
		end
		function c:CheckTeemoBlind()
			for i = 0, myHero.buffCount do
				local buff = myHero:GetBuff(i)
				if buff and buff.count > 0 and buff.name:lower() == "blindingdart" and buff.duration > 0 then
					return true
				end
			end
			return false
		end
		function c:IsBeforeAttack(multipier)
			if LocalGameTimer() > self.AttackLocalStart + multipier * myHero.attackData.animationTime then
				return true
			else
				return false
			end
		end
		function c:OnPreAttack(func)
			self.OnPreAttackC[#self.OnPreAttackC+1] = func
		end
		function c:OnPostAttack(func)
			self.OnPostAttackC[#self.OnPostAttackC+1] = func
		end
		function c:OnPostAttackTick(func)
			self.OnPostAttackTickC[#self.OnPostAttackTickC+1] = func
		end
		function c:OnAttack(func)
			self.OnAttackC[#self.OnAttackC+1] = func
		end
		function c:OnPreMovement(func)
			self.OnPreMoveC[#self.OnPreMoveC+1] = func
		end
		function c:OnTick(func)
			self.OnTickC[#self.OnTickC+1] = func
		end
		function c:Draw()
			if MENU.gsodraw.me.enabled:Value() and myHero.pos:ToScreen().onScreen then
				LocalDrawCircle(myHero.pos, myHero.range + myHero.boundingRadius + 35, MENU.gsodraw.me.width:Value(), MENU.gsodraw.me.color:Value())
			end
			if MENU.gsodraw.he.enabled:Value() then
				local enemyHeroes = OB:GetEnemyHeroes(99999999, false, 2)
				for i = 1, #enemyHeroes do
					local enemy = enemyHeroes[i]
					if enemy.pos:ToScreen().onScreen then
						LocalDrawCircle(enemy.pos, enemy.range + enemy.boundingRadius + 35, MENU.gsodraw.he.width:Value(), MENU.gsodraw.he.color:Value())
					end
				end
			end
		end
		function c:CanAttackEvent(func)
			self.CanAttackC = func
		end
		function c:CanMoveEvent(func)
			self.CanMoveC = func
		end
		function c:Attack(unit)
			ORB.ResetAttack = false
			local attackKey = MENU.orb.aamoveclick:Key()
			CURSOR:SetCursor(_G.cursorPos, unit, attackKey, function()
				LocalControlKeyDown(attackKey)
				LocalControlKeyUp(attackKey)
			end)
			self.LastMoveLocal = 0
			self.AttackLocalStart = LocalGameTimer()
		end
		function c:Move()
			if LocalControlIsKeyDown(2) then self.LastMouseDown = LocalGameTimer() end
			self.LastMovePos = _G.mousePos
			LocalControlMouseEvent(MOUSEEVENTF_RIGHTDOWN)
			LocalControlMouseEvent(MOUSEEVENTF_RIGHTUP)
			self.LastMoveLocal = LocalGameTimer() + UTILS:GetHumanizer()
			self.LastMoveTime = LocalGameTimer()
		end
		function c:MoveToPos(pos)
			if LocalControlIsKeyDown(2) then self.LastMouseDown = LocalGameTimer() end
			CURSOR:SetCursor(_G.cursorPos, pos, MOUSEEVENTF_RIGHTDOWN, function()
				LocalControlMouseEvent(MOUSEEVENTF_RIGHTDOWN)
				LocalControlMouseEvent(MOUSEEVENTF_RIGHTUP)
			end)
			self.LastMoveLocal = LocalGameTimer() + UTILS:GetHumanizer()
			self.LastMoveTime = LocalGameTimer()
		end
		function c:WaitingForResponseFromServer()
			if LocalGameTimer() < self.AttackLocalStart + 0.2 then
				return true
			end
			return false
		end
		function c:CanAttack()
			if not self.CanAttackC() then return false end
			if self.IsBlindedByTeemo then
				return false
			end
			if ExtLibEvade and ExtLibEvade.Evading then
				return false
			end
			if Utilities:IsChanneling(myHero) then
				return false
			end
			if Orbwalker.DisableAutoAttack[LocalCharName] ~= nil and Orbwalker.DisableAutoAttack[LocalCharName](myHero) then
				return false
			end
			if SPELLS:DisableAutoAttack() then
				return false
			end
			if LocalGameTimer() < SPELLS.SpellEndTime then
				return false
			end
			if LocalGameTimer() < SPELLS.ObjectEndTime then
				return false
			end
			--[[if MENU.orb.lcore.enabled:Value() then
				local extraAnim = MENU.orb.lcore.extraa:Value() * 0.001; extraAnim = extraAnim - UTILS:GetLatency(0.04)
				if LocalGameTimer() > self.AttackLocalStart + myHero.attackData.animationTime + extraAnim then
					return true
				end
				return false
			else--]]
				if self.AttackCastEndTime > self.AttackLocalStart then
					if LocalGameTimer() >= self.AttackStartTime + myHero.attackData.animationTime - UTILS:GetLatency(0.04) then
						return true
					end
					return false
				end
				if self:WaitingForResponseFromServer() then return false end
				return true
			--end
		end
		function c:CanMove(extraDelay)
			local onlyMove = extraDelay == 0
			if onlyMove and not self.CanMoveC() then return false end
			if ExtLibEvade and ExtLibEvade.Evading then
				return false
			end
			if LocalCharName == "Kalista" then
				return true
			end
			if not myHero.pathing.hasMovePath then
				self.LastMoveLocal = 0
			end
			if Utilities:IsChanneling(myHero) then
				if Orbwalker.AllowMovement[LocalCharName] == nil or (not Orbwalker.AllowMovement[LocalCharName](myHero)) then
					return false
				end
			end
			if self.ChampionCanMove[LocalCharName] ~= nil and not self.ChampionCanMove[LocalCharName]() then
				return false
			end
			if Utilities:GetDistanceSquared(myHero.pos, _G.mousePos) < 15000 then
				return false
			end
			--[[if MENU.orb.lcore.enabled:Value() then
				local extraWindUp = MENU.orb.lcore.extraw:Value() * 0.001; extraWindUp = extraWindUp - UTILS:GetLatency(-0.1)
				if LocalGameTimer() > self.AttackLocalStart + myHero.attackData.windUpTime + extraWindUp then
					return true
				end
				return false
			else--]]
				if self.AttackCastEndTime > self.AttackLocalStart then
					local extraWindUp = MENU.orb.extrawindup:Value() * 0.001; extraWindUp = extraWindUp - UTILS:GetLatency(0)
					if LocalGameTimer() >= self.AttackStartTime + UTILS:GetWindup() + extraDelay + extraWindUp + 0.015 then
						return true
					end
					return false
				end
				if self:WaitingForResponseFromServer() then return false end
				return true
			--end
		end
		function c:CanMoveSpell()
			--[[if MENU.orb.lcore.enabled:Value() then
				local extraWindUp = MENU.orb.lcore.extraw:Value() * 0.001; extraWindUp = extraWindUp - UTILS:GetLatency(0)
				if LocalGameTimer() > self.AttackLocalStart + myHero.attackData.windUpTime + extraWindUp + 0.01 then
					return true
				end
				return false
			else--]]
				if self.AttackCastEndTime > self.AttackLocalStart then
					if LocalGameTimer() >= self.AttackStartTime + UTILS:GetWindup() + 0.025 - UTILS:GetLatency(0) + (MENU.orb.extrawindup:Value() * 0.001) then
						return true
					end
					return false
				end
				if self:WaitingForResponseFromServer() then return false end
				return true
			--end
		end
		function c:AttackMove(unit, isLH, isLC)
			if self.AttackEnabled and unit and unit.pos:ToScreen().onScreen and self:CanAttack() then
				local args = { Target = unit, Process = true }
				for i = 1, #self.OnPreAttackC do
					self.OnPreAttackC[i](args)
				end
				if args.Process and args.Target then
					if _G.Control.Attack(args.Target) then
						self.PostAttackBool = true
						if isLH then
							FARM.LastHandle = unit.handle
						elseif isLC and unit.type == Obj_AI_Minion then
							FARM.LastLCHandle = unit.handle
						end
					end
				end
			elseif self.MovementEnabled and self:CanMove(0) then
				if self.PostAttackBool then
					for i = 1, #self.OnPostAttackC do
						self.OnPostAttackC[i]()
					end
					self.LastPostAttack = LocalGameTimer()
					self.PostAttackBool = false
				end
				if LocalGameTimer() < self.LastPostAttack + 0.15 then
					for i = 1, #self.OnPostAttackTickC do
						self.OnPostAttackTickC[i]()
					end
				end
				if LocalGameTimer() > self.LastMoveLocal then
					local args = { Target = Orbwalker.ForceMovement, Process = true }
					for i = 1, #self.OnPreMoveC do
						self.OnPreMoveC[i](args)
					end
					if args.Process then
						local toMouse = false
						local position
						if not args.Target then
							toMouse = true
							position = _G.mousePos
						elseif args.Target.x then
							position = LocalVector(args.Target)
						elseif args.Target.pos then
							position = args.Target.pos
						end
						if toMouse then position = nil end
						_G.Control.Move(position)
					end
				end
			end
		end
		function c:WndMsg(msg, wParam)
			if not CURSOR.IsReadyGlobal then
				if wParam == MENU.orb.aamoveclick:Key() then
					--if MENU.orb.lcore.enabled:Value() then self.AttackLocalStart = LocalGameTimer() end
					CURSOR.IsReadyGlobal = true
					--print("attack")
				elseif wParam == CURSOR.Key then
					CURSOR.IsReadyGlobal = true
					--print("spell")
				elseif CURSOR.Key == MOUSEEVENTF_RIGHTDOWN and wParam == 2 then
					CURSOR.IsReadyGlobal = true
					--print("mouse")
				end
			end
		end
		function c:GetTarget()
			local result = nil
			if Utilities:IsValidTarget(Orbwalker.ForceTarget) then
				result = Orbwalker.ForceTarget
			elseif Orbwalker.Modes[ORBWALKER_MODE_COMBO] then
				result = TS:GetComboTarget()
			elseif Orbwalker.Modes[ORBWALKER_MODE_HARASS] then
				if FARM.IsLastHitable then
					result = FARM:GetLastHitTarget()
				else
					result = TS:GetComboTarget()
				end
			elseif Orbwalker.Modes[ORBWALKER_MODE_LASTHIT] then
				result = FARM:GetLastHitTarget()
			elseif Orbwalker.Modes[ORBWALKER_MODE_LANECLEAR] then
				if FARM.IsLastHitable then
					result = FARM:GetLastHitTarget()
				elseif LocalGameTimer() > FARM.ShouldWaitTime + MENU.orb.lclear.swait:Value() * 0.001 then
					result = FARM:GetLaneClearTarget()
				end
			elseif Orbwalker.Modes[ORBWALKER_MODE_FLEE] then
				result = nil
			elseif Orbwalker.Modes[ORBWALKER_MODE_JUNGLECLEAR] then
				result = FARM:GetJungleTarget()
			end
			return result
		end
		function c:Orbwalk()
			Orbwalker.IsNone = Orbwalker:HasMode(ORBWALKER_MODE_NONE)
			Orbwalker.Modes = Orbwalker:GetModes()
			if Orbwalker.IsNone then
				if LocalGameTimer() < self.LastMouseDown + 1 then
					LocalControlMouseEvent(MOUSEEVENTF_RIGHTDOWN)
					self.LastMouseDown = 0
				end
				return
			end
			if LocalGameIsChatOpen() or (ExtLibEvade and ExtLibEvade.Evading) or not CURSOR.IsReady or (not LocalGameIsOnTop()) then
				return
			end
			if Utilities:IsValidTarget(Orbwalker.ForceTarget) then
				self:AttackMove(Orbwalker.ForceTarget)
			elseif Orbwalker.Modes[ORBWALKER_MODE_COMBO] then
				self:AttackMove(TS:GetComboTarget())
			elseif Orbwalker.Modes[ORBWALKER_MODE_HARASS] then
				if FARM.IsLastHitable then
					self:AttackMove(FARM:GetLastHitTarget(), true)
				else
					self:AttackMove(TS:GetComboTarget())
				end
			elseif Orbwalker.Modes[ORBWALKER_MODE_LASTHIT] then
				self:AttackMove(FARM:GetLastHitTarget())
			elseif Orbwalker.Modes[ORBWALKER_MODE_LANECLEAR] then
				if FARM.IsLastHitable then
					self:AttackMove(FARM:GetLastHitTarget(), true)
				elseif LocalGameTimer() > FARM.ShouldWaitTime + MENU.orb.lclear.swait:Value() * 0.001 then
					self:AttackMove(FARM:GetLaneClearTarget(), false, true)
				else
					self:AttackMove()
				end
			elseif Orbwalker.Modes[ORBWALKER_MODE_FLEE] then
				if self.MovementEnabled and LocalGameTimer() > self.LastMoveLocal and self:CanMove(0) then
					self:AttackMove()
				end
			elseif Orbwalker.Modes[ORBWALKER_MODE_JUNGLECLEAR] then
				self:AttackMove(FARM:GetJungleTarget())
			end
		end
		function c:Tick()
			--[[if myHero.attackData.endTime > GOSAPIBROKEN then
				GOSAPIBROKEN = myHero.attackData.endTime
				for i = 1, #self.OnAttackC do
					self.OnAttackC[i]()
				end
				self.AttackStartTime = myHero.attackData.endTime - myHero.attackData.animationTime
				self.AttackCastEndTime = Game.Timer() + 0.15
				if GAMSTERON_MODE_DMG then
					if self.TestCount == 0 then
						self.TestStartTime = LocalGameTimer()
					end
					self.TestCount = self.TestCount + 1
					if self.TestCount == 5 then
						print("5 attacks in time: " .. tostring(LocalGameTimer() - self.TestStartTime) .. "[sec]")
						self.TestCount = 0
						self.TestStartTime = 0
					end
				end
			end--]]
			local spell = myHero.activeSpell
			if spell and spell.valid and spell.castEndTime > self.AttackCastEndTime and (not myHero.isChanneling or self.SpecialAutoAttacks[spell.name]) then
				for i = 1, #self.OnAttackC do
					self.OnAttackC[i]()
				end
				self.AttackCastEndTime = spell.castEndTime
				self.AttackStartTime = spell.startTime
				if GAMSTERON_MODE_DMG then
					if self.TestCount == 0 then
						self.TestStartTime = LocalGameTimer()
					end
					self.TestCount = self.TestCount + 1
					if self.TestCount == 5 then
						print("5 attacks in time: " .. tostring(LocalGameTimer() - self.TestStartTime) .. "[sec]")
						self.TestCount = 0
						self.TestStartTime = 0
					end
				end
			end
			self:Orbwalk()
		end
		return result
	end,
	ACTIONS = function()
		local c = {}
		local result =
		{
			Jobs = {}
		}
		-- init
			c.__index = c
			setmetatable(result, c)
		function c:Add(action, delay)
			self.Jobs[#self.Jobs+1] = { action, delay + LocalGameTimer() }
		end
		function c:Tick()
			local newactions = {}
			for i = 1, #self.Jobs do
				local action = self.Jobs[i]
				if LocalGameTimer() >= action[2] then
					action[1]()
				else
					newactions[#newactions+1] = action
				end
			end
			local count = #self.Jobs
			for i = count, 1, -1 do
				self.Jobs[i] = nil
			end
			self.Jobs = newactions
		end
		return result
	end,
	UTILS = function()
		local c = {}
		local result =
		{
			IsMelee = {
				["Aatrox"] = true,
				["Ahri"] = false,
				["Akali"] = true,
				["Alistar"] = true,
				["Amumu"] = true,
				["Anivia"] = false,
				["Annie"] = false,
				["Ashe"] = false,
				["AurelionSol"] = false,
				["Azir"] = true,
				["Bard"] = false,
				["Blitzcrank"] = true,
				["Brand"] = false,
				["Braum"] = true,
				["Caitlyn"] = false,
				["Camille"] = true,
				["Cassiopeia"] = false,
				["Chogath"] = true,
				["Corki"] = false,
				["Darius"] = true,
				["Diana"] = true,
				["DrMundo"] = true,
				["Draven"] = false,
				["Ekko"] = true,
				["Elise"] = false,
				["Evelynn"] = true,
				["Ezreal"] = false,
				["Fiddlesticks"] = false,
				["Fiora"] = true,
				["Fizz"] = true,
				["Galio"] = true,
				["Gangplank"] = true,
				["Garen"] = true,
				["Gnar"] = false,
				["Gragas"] = true,
				["Graves"] = false,
				["Hecarim"] = true,
				["Heimerdinger"] = false,
				["Illaoi"] = true,
				["Irelia"] = true,
				["Ivern"] = true,
				["Janna"] = false,
				["JarvanIV"] = true,
				["Jax"] = true,
				["Jayce"] = false,
				["Jhin"] = false,
				["Jinx"] = false,
				["Kaisa"] = false,
				["Kalista"] = false,
				["Karma"] = false,
				["Karthus"] = false,
				["Kassadin"] = true,
				["Katarina"] = true,
				["Kayle"] = false,
				["Kayn"] = true,
				["Kennen"] = false,
				["Khazix"] = true,
				["Kindred"] = false,
				["Kled"] = true,
				["KogMaw"] = false,
				["Leblanc"] = false,
				["LeeSin"] = true,
				["Leona"] = true,
				["Lissandra"] = false,
				["Lucian"] = false,
				["Lulu"] = false,
				["Lux"] = false,
				["Malphite"] = true,
				["Malzahar"] = false,
				["Maokai"] = true,
				["MasterYi"] = true,
				["MissFortune"] = false,
				["MonkeyKing"] = true,
				["Mordekaiser"] = true,
				["Morgana"] = false,
				["Nami"] = false,
				["Nasus"] = true,
				["Nautilus"] = true,
				["Nidalee"] = false,
				["Nocturne"] = true,
				["Nunu"] = true,
				["Olaf"] = true,
				["Orianna"] = false,
				["Ornn"] = true,
				["Pantheon"] = true,
				["Poppy"] = true,
				["Pyke"] = true,
				["Quinn"] = false,
				["Rakan"] = true,
				["Rammus"] = true,
				["RekSai"] = true,
				["Renekton"] = true,
				["Rengar"] = true,
				["Riven"] = true,
				["Rumble"] = true,
				["Ryze"] = false,
				["Sejuani"] = true,
				["Shaco"] = true,
				["Shen"] = true,
				["Shyvana"] = true,
				["Singed"] = true,
				["Sion"] = true,
				["Sivir"] = false,
				["Skarner"] = true,
				["Sona"] = false,
				["Soraka"] = false,
				["Swain"] = false,
				["Syndra"] = false,
				["TahmKench"] = true,
				["Taliyah"] = false,
				["Talon"] = true,
				["Taric"] = true,
				["Teemo"] = false,
				["Thresh"] = true,
				["Tristana"] = false,
				["Trundle"] = true,
				["Tryndamere"] = true,
				["TwistedFate"] = false,
				["Twitch"] = false,
				["Udyr"] = true,
				["Urgot"] = true,
				["Varus"] = false,
				["Vayne"] = false,
				["Veigar"] = false,
				["Velkoz"] = false,
				["Vi"] = true,
				["Viktor"] = false,
				["Vladimir"] = false,
				["Volibear"] = true,
				["Warwick"] = true,
				["Xayah"] = false,
				["Xerath"] = false,
				["XinZhao"] = true,
				["Yasuo"] = true,
				["Yorick"] = true,
				["Zac"] = true,
				["Zed"] = true,
				["Ziggs"] = false,
				["Zilean"] = false,
				["Zoe"] = false,
				["Zyra"] = false
			},
			SpecialMelees = {
				["Elise"] = function()
					return myHero.range < 200
				end,
				["Gnar"] = function()
					return myHero.range < 200
				end,
				["Jayce"] = function()
					return myHero.range < 200
				end,
				["Kayle"] = function()
					return myHero.range < 200
				end,
				["Nidalee"] = function()
					return myHero.range < 200
				end
			}
		}
		-- init
			c.__index = c
			setmetatable(result, c)
		function c:GetProjSpeed()
			if self.IsMelee[LocalCharName] or (self.SpecialMelees[LocalCharName] ~= nil and self.SpecialMelees[LocalCharName]()) then
				return math.huge
			end
			if Utilities.SpecialMissileSpeeds[LocalCharName] ~= nil then
				local projectileSpeed = Utilities.SpecialMissileSpeeds[LocalCharName](myHero)
				if projectileSpeed then
					return projectileSpeed
				end
			end
			if myHero.attackData.projectileSpeed then
				return myHero.attackData.projectileSpeed
			end
			return math.huge
		end
		function c:GetWindup()
			if Utilities.SpecialWindUpTimes[LocalCharName] ~= nil then
				local SpecialWindUpTime = Utilities.SpecialWindUpTimes[LocalCharName](myHero)
				if SpecialWindUpTime then
					return SpecialWindUpTime
				end
			end
			if myHero.attackData.windUpTime then
				return myHero.attackData.windUpTime
			end
			return 0.25
		end
		function c:GetHumanizer()
			local humnum
			if MENU.orb.humanizer.random.enabled:Value() then
				local fromhum = MENU.orb.humanizer.random.from:Value()
				local tohum = MENU.orb.humanizer.random.to:Value()
				if tohum <= fromhum then
					humnum = fromhum * 0.001
				else
					humnum = LocalMathRandom(fromhum, tohum) * 0.001
				end
			else
				humnum = MENU.orb.humanizer.standard:Value() * 0.001
			end
			return humnum
		end
		function c:GetDistance(a,b)
			local x = a.x - b.x
			local z = (a.z or a.y) - (b.z or b.y)
			return x * x + z * z
		end
		function c:GetLatency(extra)
			return extra + (MENU.orb.clat:Value() * 0.001)
		end
		function c:IsImmobile(unit, delay)
			-- http://leagueoflegends.wikia.com/wiki/Types_of_Crowd_Control
				--ok
				--STUN = 5
				--SNARE = 11
				--SUPRESS = 24
				--KNOCKUP = 29
				--good
				--FEAR = 21 -> fiddle Q, ...
				--CHARM = 22 -> ahri E, ...
				--not good
				--TAUNT = 8 -> rammus E, ... can move too fast + anyway will detect attack
				--SLOW = 10 -> can move too fast -> nasus W, zilean E are ok. Rylai item, ... not good
				--KNOCKBACK = 30 -> alistar W, lee sin R, ... - no no
			for i = 0, unit.buffCount do
				local buff = unit:GetBuff(i)
				if buff and buff.count > 0 and buff.duration > delay then
					local bType = buff.type
					if bType == 5 or bType == 11 or bType == 21 or bType == 22 or bType == 24 or bType == 29 or buff.name == "recall" then
						return true
					end
				end
			end
			return false
		end
		return result
	end,
	OBJECTS = function()
		local c = {}
		local result =
		{
			Loaded = false,
			EnemyInhibitors = {},
			EnemyTurrets = {},
			EnemyNexus = nil,
			AllyInhibitors = {},
			AllyTurrets = {},
			AllyNexus = nil,
			OnEnemyHeroLoad =
			{
				function(hero)
					if hero.charName == "Teemo" then
						ORB.IsTeemo = true
					end
				end
			},
			OnAllyHeroLoad = {},
			OnEnemyNexusLoad = {},
			OnAllyNexusLoad = {},
			OnEnemyBarracksLoad = {},
			OnAllyBarracksLoad = {},
			OnAllyTurretLoad = {},
			OnEnemyTurretLoad = {}
		}
		-- init
			c.__index = c
			setmetatable(result, c)
		function c:SetBuffs(obj)
			local name = obj.charName
			if name == "Kayle" then OB.UndyingBuffs["JudicatorIntervention"] = true
			elseif name == "Taric" then OB.UndyingBuffs["TaricR"] = true
			elseif name == "Kindred" then OB.UndyingBuffs["kindredrnodeathbuff"] = true
			elseif name == "Zilean" then OB.UndyingBuffs["ChronoShift"] = true; OB.UndyingBuffs["chronorevive"] = true
			elseif name == "Tryndamere" then OB.UndyingBuffs["UndyingRage"] = true
			elseif name == "Jax" then OB.UndyingBuffs["JaxCounterStrike"] = true
			elseif name == "Fiora" then OB.UndyingBuffs["FioraW"] = true
			elseif name == "Aatrox" then OB.UndyingBuffs["aatroxpassivedeath"] = true
			elseif name == "Vladimir" then OB.UndyingBuffs["VladimirSanguinePool"] = true
			elseif name == "KogMaw" then OB.UndyingBuffs["KogMawIcathianSurprise"] = true
			elseif name == "Karthus" then OB.UndyingBuffs["KarthusDeathDefiedBuff"] = true
			end
		end
		function c:Buildings()
			local c2 = {}
			local result2 =
			{
				loaded = false,
				count = 0,
				allynexus = nil,
				enemynexus = nil,
				allybarracks = {},
				enemybarracks = {},
				allyturrets = {},
				enemyturrets = {},
				timer = LocalGameTimer(),
				performance = LocalGameTimer()
			}
			-- init
				c2.__index = c2
				setmetatable(result2, c2)
			function c2:DoWork()
				if LocalGameTimer() < self.performance + 0.5 then return end
				local function DoEvent(obj1, obj2, obj3, isally)
					if isally then
						if obj1 ~= nil then
							for i = 1, #OBJECTS.OnAllyNexusLoad do
								OBJECTS.OnAllyNexusLoad[i](obj1)
							end
							OBJECTS.AllyNexus = obj1
						elseif obj2 ~= nil then
							for i = 1, #OBJECTS.OnAllyBarracksLoad do
								OBJECTS.OnAllyBarracksLoad[i](obj2)
							end
							OBJECTS.AllyInhibitors[#OBJECTS.AllyInhibitors+1] = obj2
						else
							for i = 1, #OBJECTS.OnAllyTurretLoad do
								OBJECTS.OnAllyTurretLoad[i](obj3)
							end
							OBJECTS.AllyTurrets[#OBJECTS.AllyTurrets+1] = obj3
						end
					else
						if obj1 ~= nil then
							for i = 1, #OBJECTS.OnEnemyNexusLoad do
								OBJECTS.OnEnemyNexusLoad[i](obj1)
							end
							OBJECTS.EnemyNexus = obj1
						elseif obj2 ~= nil then
							for i = 1, #OBJECTS.OnEnemyBarracksLoad do
								OBJECTS.OnEnemyBarracksLoad[i](obj2)
							end
							OBJECTS.EnemyInhibitors[#OBJECTS.EnemyInhibitors+1] = obj2
						else
							for i = 1, #OBJECTS.OnEnemyTurretLoad do
								OBJECTS.OnEnemyTurretLoad[i](obj3)
							end
							OBJECTS.EnemyTurrets[#OBJECTS.EnemyTurrets+1] = obj3
						end
					end
					self.count = self.count + 1
				end
				for i = 1, LocalGameObjectCount() do
					local obj = LocalGameObject(i)
					if obj and obj.name and #obj.name > 0 then
						local isnew = true
						local isally = obj.team == TEAM_ALLY
						if obj.type == Obj_AI_Barracks then
							local array
							if isally then
								array = self.allybarracks
							else
								array = self.enemybarracks
							end
							for j = 1, #array do
								if obj == array[j] then
									isnew = false
									break
								end
							end
							if isnew then
								if isally then
									self.allybarracks[#self.allybarracks+1] = obj
								else
									self.enemybarracks[#self.enemybarracks+1] = obj
								end
								DoEvent(nil, obj, nil, isally)
							end
						elseif obj.type == Obj_AI_Turret then
							local array
							if isally then
									array = self.allyturrets
							else
									array = self.enemyturrets
							end
							for j = 1, #array do
									if obj == array[j] then
										isnew = false
										break
									end
							end
							if isnew then
									if isally then
										self.allyturrets[#self.allyturrets+1] = obj
									else
										self.enemyturrets[#self.enemyturrets+1] = obj
									end
									DoEvent(nil, nil, obj, isally)
							end
						elseif obj.type == Obj_AI_Nexus then
							if isally and self.allynexus == obj then
									isnew = false
							elseif not isally and self.enemynexus == obj then
									isnew = false
							end
							if isnew then
									if isally then
										self.allynexus = obj
									else
										self.enemynexus = obj
									end
									DoEvent(obj, nil, nil, isally)
							end
						end
					end
				end
				if LocalGameTimer() > self.timer + 2 then
					self.loaded = true
					--print("Buildings Loaded in: " .. tostring(LocalGameTimer() - self.timer) .. " " .. tostring(self.count))
				else
					self.performance = LocalGameTimer()
				end
			end
			return result2
		end
		function c:Heroes()
			local c2 = {}
			local result2 =
			{
				loaded = false,
				count = 0,
				allies = {},
				enemies = {},
				timer = LocalGameTimer(),
				performance = LocalGameTimer()
			}
			-- init
				c2.__index = c2
				setmetatable(result2, c2)
			function c2:DoWork()
				if LocalGameTimer() < self.timer + 3 then return end
				if LocalGameTimer() < self.performance + 0.5 then return end
				local function DoEvent(obj, isally)
					if isally then
						for i = 1, #OBJECTS.OnAllyHeroLoad do
							OBJECTS.OnAllyHeroLoad[i](obj)
						end
					else
						for i = 1, #OBJECTS.OnEnemyHeroLoad do
							OBJECTS.OnEnemyHeroLoad[i](obj)
						end
					end
					self.count = self.count + 1
				end
				for i = 1, LocalGameHeroCount() do
					local obj = LocalGameHero(i)
					if obj and obj.charName and #obj.charName > 0 then
						local array
						local isnew = true
						local isally = obj.team == myHero.team
						if isally then
							array = self.allies
						else
							array = self.enemies
						end
						for j = 1, #array do
							if obj == array[j] then
								isnew = false
								break
							end
						end
						if isnew then
							if isally then
								self.allies[#self.allies+1] = obj
							else
								self.enemies[#self.enemies+1] = obj
								OBJECTS:SetBuffs(obj)
							end
							DoEvent(obj, isally)
						end
					end
				end
				local success = false
				if Game.mapID == TWISTED_TREELINE and self.count >= 6 then success = true end
				if Game.mapID == HOWLING_ABYSS or Game.mapID == SUMMONERS_RIFT and self.count >= 10 then success = true end
				if LocalGameTimer() > self.timer + 60 then success = true end
				if success then
					self.loaded = true
					--print("Heroes Loaded in: " .. tostring(LocalGameTimer() - self.timer))
				else
					self.performance = LocalGameTimer()
				end
			end
			return result2
		end
		return result
	end,
	SPELLS = function()
		local c = {}
		local result =
		{
			Work = nil,
			WorkEndTime = 0,
			ObjectEndTime = 0,
			SpellEndTime = 0,
			CanNext = true,
			StartTime = 0,
			DelayedSpell = {}
		}
		-- init
			result.WindupList = {
				["VayneCondemn"] = 0.6,
				["UrgotE"] = 1,
				["TristanaW"] = 0.9,
				["TristanaE"] = 0.15,
				["ThreshQInternal"] = 1.25,
				["ThreshE"] = 0.75,
				["ThreshRPenta"] = 0.75
			}
			result.WorkList = {
				["UrgotE"] =
				{
					1.5,
					function()
						for i = 1, LocalGameParticleCount() do
							local obj = LocalGameParticle(i)
							if obj ~= nil and obj.name == "Urgot_Base_E_tar" then
								SPELLS.ObjectEndTime = LocalGameTimer() + 0.75
								SPELLS.Work = nil
								break
							end
						end
					end
				},
				["ThreshQInternal"] =
				{
					3,
					function()
						for i = 1, LocalGameParticleCount() do
							local obj = LocalGameParticle(i)
							if obj ~= nil and obj.name == "Thresh_Base_Q_stab_tar" then
								SPELLS.ObjectEndTime = LocalGameTimer() + 1
								SPELLS.Work = nil
								break
							end
						end
					end
				}
			}
			c.__index = c
			setmetatable(result, c)
		function c:DisableAutoAttack()
			local a = myHero.activeSpell
			if a and a.valid and a.startTime > self.StartTime and myHero.isChanneling and not ORB.SpecialAutoAttacks[a.name] then
				local name = a.name
				if self.Work == nil and LocalGameTimer() > self.WorkEndTime and self.WorkList[name] ~= nil then
					self.WorkEndTime = LocalGameTimer() + self.WorkList[name][1]
					self.Work = self.WorkList[name][2]
				end
				local twindup = self.WindupList[name]
				local windup = twindup ~= nil and twindup or a.windup
				local t = a.startTime + windup
				t = t - UTILS:GetLatency(0)
				self.SpellEndTime = t
				self.StartTime = a.startTime
				if LocalGameTimer() < ORB.AttackLocalStart + UTILS:GetWindup() - 0.09 or LocalGameTimer() < ORB.AttackCastEndTime - 0.1 then
					Orbwalker:__OnAutoAttackReset()
				end
				return true
			end
			return false
		end
		function c:WndMsg(msg, wParam)
			local manualNum = -1
			local currentTime = LocalGameTimer()
			if wParam == HK_Q and currentTime > Gamsteron.LastQk + 0.33 and LocalGameCanUseSpell(_Q) == 0 then
				  Gamsteron.LastQk = currentTime
				  manualNum = 0
			elseif wParam == HK_W and currentTime > Gamsteron.LastWk + 0.33 and LocalGameCanUseSpell(_W) == 0 then
				  Gamsteron.LastWk = currentTime
				  manualNum = 1
			elseif wParam == HK_E and currentTime > Gamsteron.LastEk + 0.33 and LocalGameCanUseSpell(_E) == 0 then
				  Gamsteron.LastEk = currentTime
				  manualNum = 2
			elseif wParam == HK_R and currentTime > Gamsteron.LastRk + 0.33 and LocalGameCanUseSpell(_R) == 0 then
				  Gamsteron.LastRk = currentTime
				  manualNum = 3
			end
			if manualNum > -1 and not self.DelayedSpell[manualNum] and not _G.SDK.Orbwalker.IsNone then
				self.DelayedSpell[manualNum] =
				{
					function()
						ControlKeyDown(wParam)
						ControlKeyUp(wParam)
						ControlKeyDown(wParam)
						ControlKeyUp(wParam)
						ControlKeyDown(wParam)
						ControlKeyUp(wParam)
					end,
					currentTime
				}
			end
		  end
		return result
	end
}
META2 =
{
	Linq = function()
		local c = {}
		local result = {}
		-- init
			c.__index = c
			setmetatable(result, c)
		function c:Add(t, value)
			t[#t + 1] = value
		end
		function c:Join(t1, t2, t3, t4, t5, t6)
			local t = {}
			local c = 1
			for i = 1, #t1 do
				t[c] = t1[i]
				c = c + 1
			end
			for i = 1, #t2 do
				t[c] = t2[i]
				c = c + 1
			end
			if t3 then
				for i = 1, #t3 do
					t[c] = t3[i]
					c = c + 1
				end
			end
			if t4 then
				for i = 1, #t4 do
					t[c] = t4[i]
					c = c + 1
				end
			end
			if t5 then
				for i = 1, #t5 do
					t[c] = t5[i]
					c = c + 1
				end
			end
			if t6 then
				for i = 1, #t6 do
					t[c] = t6[i]
					c = c + 1
				end
			end
			return t
		end
		return result
	end,
	BuffManager = function()
		local c = {}
		local result =
		{
			CachedBuffStacks = {}
		}
		-- init
			c.__index = c
			setmetatable(result, c)
		function c:BuffIsValid(buff)
			if buff ~= nil and buff.count > 0 then
				local CurrentTime = LocalGameTimer();
				return buff.startTime <= CurrentTime and buff.expireTime >= CurrentTime;
			end
			return false;
		end
		function c:CacheBuffs(unit)
			if self.CachedBuffStacks[unit.networkID] == nil then
				local t = {};
				for i = 0, unit.buffCount do
					local buff = unit:GetBuff(i);
					if self:BuffIsValid(buff) then
						t[buff.name] = buff.count;
					end
				end
				self.CachedBuffStacks[unit.networkID] = t;
			end
		end
		function c:HasBuff(unit, name)
			self:CacheBuffs(unit)
			return self.CachedBuffStacks[unit.networkID][name] ~= nil
		end
		function c:GetBuffCount(unit, name)
			self:CacheBuffs(unit)
			local count = self.CachedBuffStacks[unit.networkID][name]
			return count ~= nil and count or -1
		end
		return result
	end,
	ItemManager = function()
		local c = {}
		local result =
		{
			ItemSlots =
			{
				ITEM_1,
				ITEM_2,
				ITEM_3,
				ITEM_4,
				ITEM_5,
				ITEM_6,
				ITEM_7
			},
			CachedItems = {}
		}
		-- init
			c.__index = c
			setmetatable(result, c)
		function c:HasItem(unit, id)
			if self.CachedItems[unit.networkID] == nil then
				local t = {};
				for i = 1, #self.ItemSlots do
					local slot = self.ItemSlots[i];
					local item = unit:GetItemData(slot);
					if item ~= nil and item.itemID > 0 then
						t[item.itemID] = item;
					end
				end
				self.CachedItems[unit.networkID] = t;
			end
			return self.CachedItems[unit.networkID][id] ~= nil
		end
		return result
	end,
	Utilities = function()
		local c = {}
		local result =
		{
			ChannelingBuffs = {
				["Caitlyn"] = function(unit)
					return BuffManager:HasBuff(unit, "CaitlynAceintheHole");
				end,
				["Fiddlesticks"] = function(unit)
					return BuffManager:HasBuff(unit, "Drain") or BuffManager:HasBuff(unit, "Crowstorm");
				end,
				["Galio"] = function(unit)
					return BuffManager:HasBuff(unit, "GalioIdolOfDurand");
				end,
				["Janna"] = function(unit)
					return BuffManager:HasBuff(unit, "ReapTheWhirlwind");
				end,
				["Kaisa"] = function(unit)
					return BuffManager:HasBuff(unit, "KaisaE");
				end,
				["Karthus"] = function(unit)
					return BuffManager:HasBuff(unit, "karthusfallenonecastsound");
				end,
				["Katarina"] = function(unit)
					return BuffManager:HasBuff(unit, "katarinarsound");
				end,
				["Lucian"] = function(unit)
					return BuffManager:HasBuff(unit, "LucianR");
				end,
				["Malzahar"] = function(unit)
					return BuffManager:HasBuff(unit, "alzaharnethergraspsound");
				end,
				["MasterYi"] = function(unit)
					return BuffManager:HasBuff(unit, "Meditate");
				end,
				["MissFortune"] = function(unit)
					return BuffManager:HasBuff(unit, "missfortunebulletsound");
				end,
				["Nunu"] = function(unit)
					return BuffManager:HasBuff(unit, "AbsoluteZero");
				end,
				["Pantheon"] = function(unit)
					return BuffManager:HasBuff(unit, "pantheonesound") or BuffManager:HasBuff(unit, "PantheonRJump");
				end,
				["Shen"] = function(unit)
					return BuffManager:HasBuff(unit, "shenstandunitedlock");
				end,
				["TwistedFate"] = function(unit)
					return BuffManager:HasBuff(unit, "Destiny");
				end,
				["Urgot"] = function(unit)
					return BuffManager:HasBuff(unit, "UrgotSwap2");
				end,
				["Varus"] = function(unit)
					return BuffManager:HasBuff(unit, "VarusQ");
				end,
				["VelKoz"] = function(unit)
					return BuffManager:HasBuff(unit, "VelkozR");
				end,
				["Vi"] = function(unit)
					return BuffManager:HasBuff(unit, "ViQ");
				end,
				["Vladimir"] = function(unit)
					return BuffManager:HasBuff(unit, "VladimirE");
				end,
				["Warwick"] = function(unit)
					return BuffManager:HasBuff(unit, "infiniteduresssound");
				end,
				["Xerath"] = function(unit)
					return BuffManager:HasBuff(unit, "XerathArcanopulseChargeUp") or BuffManager:HasBuff(unit, "XerathLocusOfPower2");
				end,
			},
			SpecialAutoAttackRanges = {
				["Caitlyn"] = function(target)
					if target ~= nil and BuffManager:HasBuff(target, "caitlynyordletrapinternal") then
						return 650;
					end
					return 0;
				end
			},
			SpecialWindUpTimes = {
				["TwistedFate"] = function(unit, target)
					if BuffManager:HasBuff(unit, "BlueCardPreAttack") or BuffManager:HasBuff(unit, "RedCardPreAttack") or BuffManager:HasBuff(unit, "GoldCardPreAttack") then
						return 0.125;
					end
					return nil;
				end,
			},
			SpecialMissileSpeeds = {
				["Caitlyn"] = function(unit, target)
					if BuffManager:HasBuff(unit, "caitlynheadshot") then
						return 3000;
					end
					return nil;
				end,
				["Graves"] = function(unit, target)
					return 3800;
				end,
				["Illaoi"] = function(unit, target)
					if BuffManager:HasBuff(unit, "IllaoiW") then
						return 1600;
					end
					return nil;
				end,
				["Jayce"] = function(unit, target)
					if BuffManager:HasBuff(unit, "jaycestancegun") then
						return 2000;
					end
					return nil;
				end,
				["Jhin"] = function(unit, target)
					if BuffManager:HasBuff(unit, "jhinpassiveattackbuff") then
						return 3000;
					end
					return nil;
				end,
				["Jinx"] = function(unit, target)
					if BuffManager:HasBuff(unit, "JinxQ") then
						return 2000;
					end
					return nil;
				end,
				["Poppy"] = function(unit, target)
					if BuffManager:HasBuff(unit, "poppypassivebuff") then
						return 1600;
					end
					return nil;
				end,
				["Twitch"] = function(unit, target)
					if BuffManager:HasBuff(unit, "TwitchFullAutomatic") then
						return 4000;
					end
					return nil;
				end,
			},
			SpecialMelees = {
				["Azir"] = function(unit) return true end,
				["Thresh"] = function(unit) return true end,
				["Velkoz"] = function(unit) return true end,
				["Viktor"] = function(unit) return BuffManager:HasBuff(unit, "ViktorPowerTransferReturn") end,
			},
			UndyingBuffs = {
				["Aatrox"] = function(target, addHealthCheck)
					return BuffManager:HasBuff(target, "aatroxpassivedeath");
				end,
				["Fiora"] = function(target, addHealthCheck)
					return BuffManager:HasBuff(target, "FioraW");
				end,
				["Tryndamere"] = function(target, addHealthCheck)
					return BuffManager:HasBuff(target, "UndyingRage") and (not addHealthCheck or target.health <= 30);
				end,
				["Vladimir"] = function(target, addHealthCheck)
					return BuffManager:HasBuff(target, "VladimirSanguinePool");
				end,
			},
			SpecialAutoAttacks = {
				["GarenQAttack"] = true,
				["KennenMegaProc"] = true,
				["CaitlynHeadshotMissile"] = true,
				["MordekaiserQAttack"] = true,
				["MordekaiserQAttack1"] = true,
				["MordekaiserQAttack2"] = true,
				["QuinnWEnhanced"] = true,
				["XenZhaoThrust"] = true,
				["XenZhaoThrust2"] = true,
				["XenZhaoThrust3"] = true,
				["BlueCardPreAttack"] = true,
				["RedCardPreAttack"] = true,
				["GoldCardPreAttack"] = true,
				["ViktorQBuff"] = true,
				["MasterYiDoubleStrike"] = true,
				["QuinnWEnhanced"] = true,
			},
			NoAutoAttacks = {
				["GravesAutoAttackRecoil"] = true,
			},
			BaseTurrets = {
				["SRUAP_Turret_Order3"] = true,
				["SRUAP_Turret_Order4"] = true,
				["SRUAP_Turret_Chaos3"] = true,
				["SRUAP_Turret_Chaos4"] = true,
			},
			Obj_AI_Bases = {
				[Obj_AI_Hero] = true,
				[Obj_AI_Minion] = true,
				[Obj_AI_Turret] = true,
			},
			Structures = {
				[Obj_AI_Barracks] = true,
				[Obj_AI_Turret] = true,
				[Obj_HQ] = true,
			},
			SlotToHotKeys = {
				[_Q]			= function() return _G.HK_Q end,
				[_W]			= function() return _G.HK_W end,
				[_E]			= function() return _G.HK_E end,
				[_R]			= function() return _G.HK_R end,
				[ITEM_1]		= function() return _G.HK_ITEM_1 end,
				[ITEM_2]		= function() return _G.HK_ITEM_2 end,
				[ITEM_3]		= function() return _G.HK_ITEM_3 end,
				[ITEM_4]		= function() return _G.HK_ITEM_4 end,
				[ITEM_5]		= function() return _G.HK_ITEM_5 end,
				[ITEM_6]		= function() return _G.HK_ITEM_6 end,
				[ITEM_7]		= function() return _G.HK_ITEM_7 end,
				[SUMMONER_1]	= function() return _G.HK_SUMMONER_1 end,
				[SUMMONER_2]	= function() return _G.HK_SUMMONER_2 end,
			},
			DisableSpellWindUpTime = {
				["Kalista"] = true,
				["Thresh"] = true,
			},
			DisableSpellAnimationTime = {
				["TwistedFate"] = true,
				["XinZhao"] = true,
				["Mordekaiser"] = true
			},
			Slots = {
				_Q,
				_W,
				_E,
				_R,
				ITEM_1,
				ITEM_2,
				ITEM_3,
				ITEM_4,
				ITEM_5,
				ITEM_6,
				ITEM_7,
				SUMMONER_1,
				SUMMONER_2,
			},
			MinionsRange =
			{
			},
			CachedValidTargets =
			{
			}
		}
		-- init
			for i = 1, #ObjectManager.MinionTypesDictionary["Melee"] do
				local charName = ObjectManager.MinionTypesDictionary["Melee"][i];
				result.SpecialMelees[charName] = function(target) return true end;
			end
			for i = 1, #ObjectManager.MinionTypesDictionary["Melee"] do
				result.MinionsRange[ObjectManager.MinionTypesDictionary["Melee"][i]] = 110;
			end
			for i = 1, #ObjectManager.MinionTypesDictionary["Ranged"] do
				result.MinionsRange[ObjectManager.MinionTypesDictionary["Ranged"][i]] = 550;
			end
			for i = 1, #ObjectManager.MinionTypesDictionary["Siege"] do
				result.MinionsRange[ObjectManager.MinionTypesDictionary["Siege"][i]] = 300;
			end
			for i = 1, #ObjectManager.MinionTypesDictionary["Super"] do
				result.MinionsRange[ObjectManager.MinionTypesDictionary["Super"][i]] = 170;
			end
			c.__index = c
			setmetatable(result, c)
		function c:CanControl()
			if ExtLibEvade and ExtLibEvade.Evading then
				return false, false
			end
			local canattack,canmove = true,true
			for i = 0, myHero.buffCount do
				local buff = myHero:GetBuff(i);
				if buff.count > 0 and buff.duration>=0.1 then
					if (buff.type == 5 --stun
					or buff.type == 8 --taunt
					or buff.type == 21 --Fear
					or buff.type == 22 --charm
					or buff.type == 24 --supression
					or buff.type == 29) --knockup
					then
						return false,false -- block everything
					end
					if (buff.type == 25 --blind
					or buff.type == 9) --polymorph
					then -- cant attack
						canattack = false
					end
					if (buff.type == 11) then -- cant move 
						canmove = false
					end
				end
			end
			return canattack,canmove
		end
		function c:__GetAutoAttackRange(from)		
			local range = from.range;
			if from.type == Obj_AI_Minion then
				range = self.MinionsRange[from.charName] ~= nil and self.MinionsRange[from.charName] or 0;
			elseif from.type == Obj_AI_Turret then
				range = 775;
			end
			return range;
		end
		function c:GetAutoAttackRange(from, target)
			local result = self:__GetAutoAttackRange(from) + from.boundingRadius + (target ~= nil and (target.boundingRadius - 20) or 35);
			if target.type == Obj_AI_Hero and self.SpecialAutoAttackRanges[from.charName] ~= nil then
				result = result + self.SpecialAutoAttackRanges[from.charName](target);
			end
			return result;
		end
		function c:IsMelee(unit)
			if LocalMathAbs(unit.attackData.projectileSpeed) < EPSILON then
				return true;
			end
			if self.SpecialMelees[unit.charName] ~= nil then
				return self.SpecialMelees[unit.charName](unit);
			end
			return self:__GetAutoAttackRange(unit) <= 275;
		end
		function c:IsRanged(unit)
			return not self:IsMelee(unit);
		end
		function c:IsMonster(unit)
			return unit.team == 300;
		end
		function c:IsOtherMinion(unit)
			return unit.maxHealth <= 6;
		end
		function c:IsBaseTurret(turret)
			return self.BaseTurrets[turret.charName] ~= nil;
		end
		function c:IsSiegeMinion(minion)
			return minion.charName:find("Siege");
		end
		function c:IsObj_AI_Base(obj)
			return self.Obj_AI_Bases[obj.type] ~= nil;
		end
		function c:IsStructure(obj)
			return self.Structures[obj.type] ~= nil;
		end
		function c:IdEquals(a, b)
			if a == nil or b == nil then
				return false;
			end
			return a.networkID == b.networkID;
		end
		function c:GetDistance2DSquared(a, b)
			local x = (a.x - b.x);
			local y = (a.y - b.y);
			return x * x + y * y;
		end
		function c:GetDistanceSquared(a, b, includeY)
			if a.pos ~= nil then
				a = a.pos;
			end
			if b.pos ~= nil then
				b = b.pos;
			end
			if a.z ~= nil and b.z ~= nil then
				if includeY then
					local x = (a.x - b.x);
					local y = (a.y - b.y);
					local z = (a.z - b.z);
					return x * x + y * y + z * z;
				else
					local x = (a.x - b.x);
					local z = (a.z - b.z);
					return x * x + z * z;
				end
			else
				local x = (a.x - b.x);
				local y = (a.y - b.y);
				return x * x + y * y;
			end
		end
		function c:GetDistance(a, b, includeY)
			return LocalMathSqrt(self:GetDistanceSquared(a, b, includeY));
		end
		function c:IsInRange(from, target, range, includeY)
			if range == nil then
				return true;
			end
			return self:GetDistanceSquared(from, target, includeY) <= range * range;
		end
		function c:IsInAutoAttackRange(from, target, includeY)
			return self:IsInRange(from, target, self:GetAutoAttackRange(from, target, includeY));
		end
		function c:TotalShield(target)
			local result = target.shieldAD + target.shieldAP;
			if target.charName == "Blitzcrank" then
				if not BuffManager:HasBuff(target, "manabarriercooldown") and not BuffManager:HasBuff(target, "manabarrier") then
					result = result + target.mana * 0.5;
				end
			end
			return result;
		end
		function c:TotalShieldHealth(target)
			return target.health + self:TotalShield(target);
		end
		function c:TotalShieldMaxHealth(target)
			return target.maxHealth + self:TotalShield(target);
		end
		function c:GetLatency()
			return UTILS:GetLatency(0)
		end
		function c:GetHealthPercent(unit)
			return 100 * unit.health / unit.maxHealth;
		end
		function c:__IsValidTarget(target)
			if self:IsObj_AI_Base(target) then
				if not target.valid then
					return false;
				end
			end
			if target.dead or (not target.visible) or (not target.isTargetable) then
				return false;
			end
			return true;
		end
		function c:IsValidTarget(target)
			if target == nil or target.networkID == nil then
				return false;
			end
			if self.CachedValidTargets[target.networkID] == nil then
				self.CachedValidTargets[target.networkID] = self:__IsValidTarget(target);
			end
			return self.CachedValidTargets[target.networkID];
		end
		function c:IsValidMissile(missile)
			if missile == nil then
				return false;
			end
			if missile.dead then
				return false;
			end
			return true;
		end
		function c:GetHotKeyFromSlot(slot)
			if slot ~= nil and self.SlotToHotKeys[slot] ~= nil then
				return self.SlotToHotKeys[slot]();
			end
			return nil;
		end
		function c:IsChanneling(unit)
			if self.ChannelingBuffs[unit.charName] ~= nil then
				return self.ChannelingBuffs[unit.charName](unit);
			end
			return false;
		end
		function c:GetSpellLevel(unit, slot)
			return self:GetSpellDataFromSlot(unit, slot).level;
		end
		function c:GetLevel(unit)
			return unit.levelData.lvl;
		end
		function c:IsWindingUp(unit)
			return unit.activeSpell.valid;
		end
		function c:StringEndsWith(str, word)
			return LocalStringSub(str, - LocalStringLen(word)) == word;
		end
		function c:IsAutoAttack(name)
			return (self.NoAutoAttacks[name] == nil and name:lower():find("attack")) or self.SpecialAutoAttacks[name] ~= nil;
		end
		function c:IsAutoAttacking(unit)
			if self:IsWindingUp(unit) then
				if self:GetActiveSpellTarget(unit) > 0 then
					return self:IsAutoAttack(self:GetActiveSpellName(unit));
				end
			end
			return false;
		end
		function c:IsCastingSpell(unit)
			if self:IsWindingUp(unit) then
				--return not self:IsAutoAttacking(unit);
				return unit.isChanneling;
			end
			return false;
		end
		function c:GetActiveSpellTarget(unit)
			return unit.activeSpell.target;
		end
		function c:GetActiveSpellWindUpTime(unit)
			if self.DisableSpellWindUpTime[unit.charName] then
				return self:GetAttackDataWindUpTime(unit);
			end
			return unit.activeSpell.windup;
		end
		function c:GetActiveSpellAnimationTime(unit)
			if self.DisableSpellAnimationTime[unit.charName] then
				return self:GetAttackDataAnimationTime(unit);
			end
			return unit.activeSpell.animation;
		end
		function c:GetActiveSpellSlot(unit)
			return unit.activeSpellSlot;
		end
		function c:GetActiveSpellName(unit)
			return unit.activeSpell.name;
		end
		function c:GetAttackDataWindUpTime(unit)
			if self.SpecialWindUpTimes[unit.charName] ~= nil then
				local SpecialWindUpTime = self.SpecialWindUpTimes[unit.charName](unit);
				if SpecialWindUpTime then
					return SpecialWindUpTime;
				end
			end
			return unit.attackData.windUpTime;
		end
		function c:GetAttackDataAnimationTime(unit)
			return unit.attackData.animationTime;
		end
		function c:GetAttackDataEndTime(unit)
			return unit.attackData.endTime;
		end
		function c:GetAttackDataState(unit)
			return unit.attackData.state;
		end
		function c:GetAttackDataTarget(unit)
			return unit.attackData.target;
		end
		function c:GetAttackDataProjectileSpeed(unit)
			if self.SpecialMissileSpeeds[unit.charName] ~= nil then
				local projectileSpeed = self.SpecialMissileSpeeds[unit.charName](unit);
				if projectileSpeed then
					return projectileSpeed;
				end
			end
			if Utilities:IsMelee(unit) then
				return LocalMathHuge;
			end
			return unit.attackData.projectileSpeed;
		end
		function c:GetSlotFromName(unit, name)
			for i = 1, #self.Slots do
				local slot = self.Slots[i];
				local spellData = self:GetSpellDataFromSlot(unit, slot);
				if spellData ~= nil and spellData.name == name then
					return slot;
				end
			end
			return nil;
		end
		function c:GetSpellDataFromSlot(unit, slot)
			return unit:GetSpellData(slot);
		end
		return result
	end,
	Damage = function()
		local c = {}
		local result =
		{
			StaticChampionDamageDatabase = {
				["Caitlyn"] = function(args)
					if BuffManager:HasBuff(args.From, "caitlynheadshot") then
						if args.TargetIsMinion then
							args.RawPhysical = args.RawPhysical + args.From.totalDamage * 1.5;
						else
							--TODO
						end
					end
				end,
				["Corki"] = function(args)
					args.RawTotal = args.RawTotal * 0.5;
					args.RawMagical = args.RawTotal;
				end,
				["Diana"] = function(args)
					if BuffManager:GetBuffCount(args.From, "dianapassivemarker") == 2 then
						local level = Utilities:GetLevel(args.From);
						args.RawMagical = args.RawMagical + LocalMathMax(15 + 5 * level, -10 + 10 * level, -60 + 15 * level, -125 + 20 * level, -200 + 25 * level) + 0.8 * args.From.ap;
					end
				end,
				["Draven"] = function(args)
					if BuffManager:HasBuff(args.From, "DravenSpinningAttack") then
						local level = Utilities:GetSpellLevel(args.From, _Q);
						args.RawPhysical = args.RawPhysical + 25 + 5 * level + (0.55 + 0.1 * level) * args.From.bonusDamage; 
					end
					
				end,
				["Graves"] = function(args)
					local t = { 70, 71, 72, 74, 75, 76, 78, 80, 81, 83, 85, 87, 89, 91, 95, 96, 97, 100 };
					args.RawTotal = args.RawTotal * t[Damage:GetMaxLevel(args.From)] * 0.01;
				end,
				["Jinx"] = function(args)
					if BuffManager:HasBuff(args.From, "JinxQ") then
						args.RawPhysical = args.RawPhysical + args.From.totalDamage * 0.1;
					end
				end,
				["Kalista"] = function(args)
					args.RawPhysical = args.RawPhysical - args.From.totalDamage * 0.1;
				end,
				["Kayle"] = function(args)
					local level = Utilities:GetSpellLevel(args.From, _E);
					if level > 0 then
						if BuffManager:HasBuff(args.From, "JudicatorRighteousFury") then
							args.RawMagical = args.RawMagical + 10+ 10* level + 0.3 * args.From.ap;
						else
							args.RawMagical = args.RawMagical + 5+ 5* level + 0.15 * args.From.ap;
						end
					end
				end,
				["Nasus"] = function(args)
					if BuffManager:HasBuff(args.From, "NasusQ") then
						args.RawPhysical = args.RawPhysical + LocalMathMax(BuffManager:GetBuffCount(args.From, "NasusQStacks"), 0) + 10 + 20 * Utilities:GetSpellLevel(args.From, _Q);
					end
				end,
				["Thresh"] = function(args)
					local level = Utilities:GetSpellLevel(args.From, _E);
					if level > 0 then
						local damage = LocalMathMax(BuffManager:GetBuffCount(args.From, "threshpassivesouls"), 0) + (0.5 + 0.3 * level) * args.From.totalDamage;
						if BuffManager:HasBuff(args.From, "threshqpassive4") then
							damage = damage * 1;
						elseif BuffManager:HasBuff(args.From, "threshqpassive3") then
							damage = damage * 0.5;
						elseif BuffManager:HasBuff(args.From, "threshqpassive2") then
							damage = damage * 1/3;
						else
							damage = damage * 0.25;
						end
						args.RawMagical = args.RawMagical + damage;
					end
				end,
				["TwistedFate"] = function(args)
					if BuffManager:HasBuff(args.From, "cardmasterstackparticle") then
						args.RawMagical = args.RawMagical + 30 + 25 * Utilities:GetSpellLevel(args.From, _E) + 0.5 * args.From.ap;
					end
					if BuffManager:HasBuff(args.From, "BlueCardPreAttack") then
						args.DamageType = DAMAGE_TYPE_MAGICAL;
						args.RawMagical = args.RawMagical + 20 + 20 * Utilities:GetSpellLevel(args.From, _W) + 0.5 * args.From.ap;
					elseif BuffManager:HasBuff(args.From, "RedCardPreAttack") then
						args.DamageType = DAMAGE_TYPE_MAGICAL;
						args.RawMagical = args.RawMagical + 15 + 15 * Utilities:GetSpellLevel(args.From, _W) + 0.5 * args.From.ap;
					elseif BuffManager:HasBuff(args.From, "GoldCardPreAttack") then
						args.DamageType = DAMAGE_TYPE_MAGICAL;
						args.RawMagical = args.RawMagical + 7.5 + 7.5 * Utilities:GetSpellLevel(args.From, _W) + 0.5 * args.From.ap;
					end
				end,
				["Varus"] = function(args)
					local level = Utilities:GetSpellLevel(args.From, _W);
					if level > 0 then
						args.RawMagical = args.RawMagical + 6 + 4 * level + 0.25 * args.From.ap;
					end
				end,
				["Viktor"] = function(args)
					if BuffManager:HasBuff(args.From, "ViktorPowerTransferReturn") then
						args.DamageType = DAMAGE_TYPE_MAGICAL;
						args.RawMagical = args.RawMagical + 20 * Utilities:GetSpellLevel(args.From, _Q) + 0.5 * args.From.ap;
					end
				end,
				["Vayne"] = function(args)
					if BuffManager:HasBuff(args.From, "vaynetumblebonus") then
						args.RawPhysical = args.RawPhysical + (0.25 + 0.05 * Utilities:GetSpellLevel(args.From, _Q)) * args.From.totalDamage;
					end
				end
			},
			VariableChampionDamageDatabase = {
				["Jhin"] = function(args)
					if BuffManager:HasBuff(args.From, "jhinpassiveattackbuff") then
						args.CriticalStrike = true;
						args.RawPhysical = args.RawPhysical + LocalMathMin(0.25, 0.1 + 0.05 * LocalMathCeil(Utilities:GetLevel(args.From) / 5)) * (args.Target.maxHealth - args.Target.health);
					end
				end,
				["Lux"] = function(args)
					if BuffManager:HasBuff(args.Target, "LuxIlluminatingFraulein") then
						args.RawMagical = 20 + args.From.levelData.lvl * 10 + args.From.ap * 0.2;
					end
				end,
				["Orianna"] = function(args)
					local level = LocalMathCeil(Utilities:GetLevel(args.From) / 3);
					args.RawMagical = args.RawMagical + 2 + 8 * level + 0.15 * args.From.ap;
					if args.Target.handle == Utilities:GetAttackDataTarget(args.From) then
						args.RawMagical = args.RawMagical + LocalMathMax(BuffManager:GetBuffCount(args.From, "orianapowerdaggerdisplay"), 0) * (0.4 + 1.6 * level + 0.03 * args.From.ap);
					end
				end,
				["Quinn"] = function(args)
					if BuffManager:HasBuff(args.Target, "QuinnW") then
						local level = Utilities:GetLevel(args.From);
						args.RawPhysical = args.RawPhysical + 10 + level * 5 + (0.14 + 0.02 * level) * args.From.totalDamage;
					end
				end,
				["Vayne"] = function(args)
					if BuffManager:GetBuffCount(args.Target, "VayneSilveredDebuff") == 2 then
						local level = Utilities:GetSpellLevel(args.From, _W);
						args.CalculatedTrue = args.CalculatedTrue + LocalMathMax((0.045 + 0.015 * level) * args.Target.maxHealth, 20 + 20 * level);
					end
				end,
				["Zed"] = function(args)
					if Utilities:GetHealthPercent(args.Target) <= 50 and not BuffManager:HasBuff(args.From, "zedpassivecd") then
						args.RawMagical = args.RawMagical + args.Target.maxHealth * (4 + 2 * LocalMathCeil(Utilities:GetLevel(args.From) / 6)) * 0.01;
					end
				end
			},
			StaticItemDamageDatabase = {
				[1043] = function(args)
					args.RawPhysical = args.RawPhysical + 15;
				end,
				[2015] = function(args)
					if BuffManager:GetBuffCount(args.From, "itemstatikshankcharge") == 100 then
						args.RawMagical = args.RawMagical + 40;
					end
				end,
				[3057] = function(args)
					if BuffManager:HasBuff(args.From, "sheen") then
						args.RawPhysical = args.RawPhysical + 1 * args.From.baseDamage;
					end
				end,
				[3078] = function(args)
					if BuffManager:HasBuff(args.From, "sheen") then
						args.RawPhysical = args.RawPhysical + 2 * args.From.baseDamage;
					end
				end,
				[3085] = function(args)
					args.RawPhysical = args.RawPhysical + 15;
				end,
				[3087] = function(args)
					if BuffManager:GetBuffCount(args.From, "itemstatikshankcharge") == 100 then
						local t = { 50, 50, 50, 50, 50, 56, 61, 67, 72, 77, 83, 88, 94, 99, 104, 110, 115, 120 };
						args.RawMagical = args.RawMagical + (1 + (args.TargetIsMinion and 1.2 or 0)) * t[Damage:GetMaxLevel(args.From)];
					end
				end,
				[3091] = function(args)
					args.RawMagical = args.RawMagical + 40;
				end,
				[3094] = function(args)
					if BuffManager:GetBuffCount(args.From, "itemstatikshankcharge") == 100 then
						local t = { 50, 50, 50, 50, 50, 58, 66, 75, 83, 92, 100, 109, 117, 126, 134, 143, 151, 160 };
						args.RawMagical = args.RawMagical + t[Damage:GetMaxLevel(args.From)];
					end
				end,
				[3100] = function(args)
					if BuffManager:HasBuff(args.From, "lichbane") then
						args.RawMagical = args.RawMagical + 0.75 * args.From.baseDamage + 0.5 * args.From.ap;
					end
				end,
				[3115] = function(args)
					args.RawMagical = args.RawMagical + 15 + 0.15 * args.From.ap;
				end,
				[3124] = function(args)
					args.CalculatedMagical = args.CalculatedMagical + 15;
				end
			},
			VariableItemDamageDatabase = {
				[1041] = function(args)
					if Utilities:IsMonster(args.Target) then
						args.CalculatedPhysical = args.CalculatedPhysical + 25;
					end
				end
			},
			TurretToMinionPercentMod =
			{
			}
		}
		-- init
			for i = 1, #ObjectManager.MinionTypesDictionary["Melee"] do
				local charName = ObjectManager.MinionTypesDictionary["Melee"][i];
				result.TurretToMinionPercentMod[charName] = 0.43;
			end
			for i = 1, #ObjectManager.MinionTypesDictionary["Ranged"] do
				local charName = ObjectManager.MinionTypesDictionary["Ranged"][i];
				result.TurretToMinionPercentMod[charName] = 0.68;
			end
			for i = 1, #ObjectManager.MinionTypesDictionary["Siege"] do
				local charName = ObjectManager.MinionTypesDictionary["Siege"][i];
				result.TurretToMinionPercentMod[charName] = 0.14;
			end
			for i = 1, #ObjectManager.MinionTypesDictionary["Super"] do
				local charName = ObjectManager.MinionTypesDictionary["Super"][i];
				result.TurretToMinionPercentMod[charName] = 0.05;
			end
			c.__index = c
			setmetatable(result, c)
		function c:GetMaxLevel(hero)
			return LocalMathMax(LocalMathMin(Utilities:GetLevel(hero), 18), 1);
		end
		function c:CalculateDamage(from, target, damageType, rawDamage, isAbility, isAutoAttackOrTargetted)
			if from == nil or target == nil then
				return 0;
			end
			if isAbility == nil then
				isAbility = true;
			end
			if isAutoAttackOrTargetted == nil then
				isAutoAttackOrTargetted = false;
			end
			local fromIsMinion = from.type == Obj_AI_Minion;
			local targetIsMinion = target.type == Obj_AI_Minion;
			local baseResistance = 0;
			local bonusResistance = 0;
			local penetrationFlat = 0;
			local penetrationPercent = 0;
			local bonusPenetrationPercent = 0;
			if damageType == DAMAGE_TYPE_PHYSICAL then
				baseResistance = LocalMathMax(target.armor - target.bonusArmor, 0);
				bonusResistance = target.bonusArmor;
				penetrationFlat = from.armorPen;
				penetrationPercent = from.armorPenPercent;
				bonusPenetrationPercent = from.bonusArmorPenPercent;
				-- Minions return wrong percent values.
				if fromIsMinion then
					penetrationFlat = 0;
					penetrationPercent = 0;
					bonusPenetrationPercent = 0;
				elseif from.type == Obj_AI_Turret then
					penetrationPercent = (not Utilities:IsBaseTurret(from)) and 0.3 or 0.75;
					penetrationFlat = 0;
					bonusPenetrationPercent = 0;
				end
			elseif damageType == DAMAGE_TYPE_MAGICAL then
				baseResistance = LocalMathMax(target.magicResist - target.bonusMagicResist, 0);
				bonusResistance = target.bonusMagicResist;
				penetrationFlat = from.magicPen;
				penetrationPercent = from.magicPenPercent;
				bonusPenetrationPercent = 0;
			elseif damageType == DAMAGE_TYPE_TRUE then
				return rawDamage;
			end
			local resistance = baseResistance + bonusResistance;
			if resistance > 0 then
				if penetrationPercent > 0 then
					baseResistance = baseResistance * penetrationPercent;
					bonusResistance = bonusResistance * penetrationPercent;
				end
				if bonusPenetrationPercent > 0 then
					bonusResistance = bonusResistance * bonusPenetrationPercent;
				end
				resistance = baseResistance + bonusResistance;
				resistance = resistance - penetrationFlat;
			end
			local percentMod = 1;
			-- Penetration cant reduce resistance below 0.
			if resistance >= 0 then
				percentMod = percentMod * (100 / (100 + resistance));
			else
				percentMod = percentMod * (2 - 100 / (100 - resistance));
			end
			local flatPassive = 0;
			local percentPassive = 1;
			if fromIsMinion and targetIsMinion then
				percentPassive = percentPassive * (1 + from.bonusDamagePercent);
			end
			local flatReceived = 0;
			if not isAbility and targetIsMinion then
				flatReceived = flatReceived - target.flatDamageReduction;
			end
			return LocalMathMax(percentPassive * percentMod * (rawDamage + flatPassive) + flatReceived, 0);
		end
		function c:GetStaticAutoAttackDamage(from, targetIsMinion)
			local args = {
				From = from,
				RawTotal = from.totalDamage,
				RawPhysical = 0,
				RawMagical = 0,
				CalculatedTrue = 0,
				CalculatedPhysical = 0,
				CalculatedMagical = 0,
				DamageType = DAMAGE_TYPE_PHYSICAL,
				TargetIsMinion = targetIsMinion
			}
			if self.StaticChampionDamageDatabase[args.From.charName] ~= nil then
				self.StaticChampionDamageDatabase[args.From.charName](args)
			end
			local HashSet = {}
			for i = 1, #ItemManager.ItemSlots do
				local slot = ItemManager.ItemSlots[i]
				local item = args.From:GetItemData(slot)
				if item ~= nil and item.itemID > 0 then
					if HashSet[item.itemID] == nil then
						if self.StaticItemDamageDatabase[item.itemID] ~= nil then
							self.StaticItemDamageDatabase[item.itemID](args)
						end
						HashSet[item.itemID] = true
					end
				end
			end
			return args
		end
		function c:GetHeroAutoAttackDamage(from, target, static)
			local args = {
				From = from,
				Target = target,
				RawTotal = static.RawTotal,
				RawPhysical = static.RawPhysical,
				RawMagical = static.RawMagical,
				CalculatedTrue = static.CalculatedTrue,
				CalculatedPhysical = static.CalculatedPhysical,
				CalculatedMagical = static.CalculatedMagical,
				DamageType = static.DamageType,
				TargetIsMinion = target.type == Obj_AI_Minion,
				CriticalStrike = false,
			};
			if args.TargetIsMinion and Utilities:IsOtherMinion(args.Target) then
				return 1;
			end
			if self.VariableChampionDamageDatabase[args.From.charName] ~= nil then
				self.VariableChampionDamageDatabase[args.From.charName](args);
			end
			if args.DamageType == DAMAGE_TYPE_PHYSICAL then
				args.RawPhysical = args.RawPhysical + args.RawTotal;
			elseif args.DamageType == DAMAGE_TYPE_MAGICAL then
				args.RawMagical = args.RawMagical + args.RawTotal;
			elseif args.DamageType == DAMAGE_TYPE_TRUE then
				args.CalculatedTrue = args.CalculatedTrue + args.RawTotal;
			end
			if args.RawPhysical > 0 then
				args.CalculatedPhysical = args.CalculatedPhysical + self:CalculateDamage(from, target, DAMAGE_TYPE_PHYSICAL, args.RawPhysical, false, args.DamageType == DAMAGE_TYPE_PHYSICAL);
			end
			if args.RawMagical > 0 then
				args.CalculatedMagical = args.CalculatedMagical + self:CalculateDamage(from, target, DAMAGE_TYPE_MAGICAL, args.RawMagical, false, args.DamageType == DAMAGE_TYPE_MAGICAL);
			end
			local percentMod = 1;
			if LocalMathAbs(args.From.critChance - 1) < EPSILON or args.CriticalStrike then
				percentMod = percentMod * self:GetCriticalStrikePercent(args.From);
			end
			return percentMod * args.CalculatedPhysical + args.CalculatedMagical + args.CalculatedTrue;
		end
		function c:GetAutoAttackDamage(from, target, respectPassives)
			if respectPassives == nil then
				respectPassives = true;
			end
			if from == nil or target == nil then
				return 0;
			end
			local targetIsMinion = target.type == Obj_AI_Minion;
			if respectPassives and from.type == Obj_AI_Hero then
				return self:GetHeroAutoAttackDamage(from, target, self:GetStaticAutoAttackDamage(from, targetIsMinion));
			end
			if targetIsMinion then
				if Utilities:IsOtherMinion(target) then
					return 1;
				end
				if from.type == Obj_AI_Turret and not Utilities:IsBaseTurret(from) then
					local percentMod = self.TurretToMinionPercentMod[target.charName];
					if percentMod ~= nil then
						return target.maxHealth * percentMod;
					end
				end
			end
			return self:CalculateDamage(from, target, DAMAGE_TYPE_PHYSICAL, from.totalDamage, false, true);
		end
		function c:GetCriticalStrikePercent(from)
			local baseCriticalDamage = 2 + (ItemManager:HasItem(from, 3031) and 0.5 or 0);
			local percentMod = 1;
			local fixedMod = 0;
			if from.charName == "Jhin" then
				percentMod = 0.75;
			elseif from.charName == "XinZhao" then
				baseCriticalDamage = baseCriticalDamage - (0.875 - 0.125 * Utilities:GetSpellLevel(from, _W));
			elseif from.charName == "Yasuo" then
				percentMod = 0.9;
			end
			return baseCriticalDamage * percentMod;
		end
		return result
	end,
	ObjectManager = function()
		local c = {}
		local result =
		{
			MinionNames = {},
			MinionTypesDictionary = {}
		}
		-- init
			local MinionMaps = { "SRU", "HA" }
			local MinionTeams = { "Chaos", "Order" }
			local MinionTypes = { "Melee", "Ranged", "Siege", "Super" }
			for i = 1, #MinionMaps do
				local map = MinionMaps[i]
				for j = 1, #MinionTeams do
					local team = MinionTeams[j]
					for k = 1, #MinionTypes do
						local t = MinionTypes[k]
						if result.MinionTypesDictionary[t] == nil then
							result.MinionTypesDictionary[t] = {}
						end
						local charName = map .. "_" .. team .. "Minion" .. t
						Linq:Add(result.MinionTypesDictionary[t], charName)
						Linq:Add(result.MinionNames, charName)
					end
				end
			end
			c.__index = c
			setmetatable(result, c)
		function c:GetMinionType(minion)
			if Utilities:IsMonster(minion) then
				return MINION_TYPE_MONSTER;
			elseif Utilities:IsOtherMinion(minion) then
				return MINION_TYPE_OTHER_MINION;
			else
				return MINION_TYPE_LANE_MINION;
			end
		end
		function c:GetMinions(range)
			local result = {};
			for i = 1, LocalGameMinionCount() do
				local minion = LocalGameMinion(i);
				if Utilities:IsValidTarget(minion) and self:GetMinionType(minion) == MINION_TYPE_LANE_MINION then
					if Utilities:IsInRange(myHero, minion, range) then
						Linq:Add(result, minion);
					end
				end
			end
			return result;
		end
		function c:GetAllyMinions(range)
			local result = {};
			for i = 1, LocalGameMinionCount() do
				local minion = LocalGameMinion(i);
				if Utilities:IsValidTarget(minion) and minion.isAlly and self:GetMinionType(minion) == MINION_TYPE_LANE_MINION then
					if Utilities:IsInRange(myHero, minion, range) then
						Linq:Add(result, minion);
					end
				end
			end
			return result;
		end
		function c:GetEnemyMinions(range)
			local result = {};
			for i = 1, LocalGameMinionCount() do
				local minion = LocalGameMinion(i);
				if Utilities:IsValidTarget(minion) and minion.isEnemy and self:GetMinionType(minion) == MINION_TYPE_LANE_MINION then
					if Utilities:IsInRange(myHero, minion, range) then
						Linq:Add(result, minion);
					end
				end
			end
			return result;
		end
		function c:GetEnemyMinionsInAutoAttackRange()
			local result = {};
			for i = 1, LocalGameMinionCount() do
				local minion = LocalGameMinion(i);
				if Utilities:IsValidTarget(minion) and minion.isEnemy and self:GetMinionType(minion) == MINION_TYPE_LANE_MINION then
					if Utilities:IsInAutoAttackRange(myHero, minion) then
						Linq:Add(result, minion);
					end
				end
			end
			return result;
		end
		function c:GetOtherMinions(range)
			local result = {};
			for i = 1, LocalGameWardCount() do
				local minion = LocalGameWard(i);
				if Utilities:IsValidTarget(minion) and self:GetMinionType(minion) == MINION_TYPE_OTHER_MINION then
					if Utilities:IsInRange(myHero, minion, range) then
						Linq:Add(result, minion);
					end
				end
			end
			return result;
		end
		function c:GetOtherAllyMinions(range)
			local result = {};
			for i = 1, LocalGameWardCount() do
				local minion = LocalGameWard(i);
				if Utilities:IsValidTarget(minion) and minion.isAlly and self:GetMinionType(minion) == MINION_TYPE_OTHER_MINION then
					if Utilities:IsInRange(myHero, minion, range) then
						Linq:Add(result, minion);
					end
				end
			end
			return result;
		end
		function c:GetOtherEnemyMinions(range)
			local result = {};
			for i = 1, LocalGameWardCount() do
				local minion = LocalGameWard(i);
				if Utilities:IsValidTarget(minion) and minion.isEnemy and self:GetMinionType(minion) == MINION_TYPE_OTHER_MINION then
					if Utilities:IsInRange(myHero, minion, range) then
						Linq:Add(result, minion);
					end
				end
			end
			return result;
		end
		function c:GetOtherEnemyMinionsInAutoAttackRange()
			local result = {};
			for i = 1, LocalGameWardCount() do
				local minion = LocalGameWard(i);
				if Utilities:IsValidTarget(minion) and minion.isEnemy and self:GetMinionType(minion) == MINION_TYPE_OTHER_MINION then
					if Utilities:IsInAutoAttackRange(myHero, minion) then
						Linq:Add(result, minion);
					end
				end
			end
			return result;
		end
		function c:GetMonsters(range)
			local result = {};
			for i = 1, LocalGameMinionCount() do
				local minion = LocalGameMinion(i);
				if Utilities:IsValidTarget(minion) and self:GetMinionType(minion) == MINION_TYPE_MONSTER then
					if Utilities:IsInRange(myHero, minion, range) then
						Linq:Add(result, minion);
					end
				end
			end
			return result;
		end
		function c:GetMonstersInAutoAttackRange()
			local result = {};
			for i = 1, LocalGameMinionCount() do
				local minion = LocalGameMinion(i);
				if Utilities:IsValidTarget(minion) and self:GetMinionType(minion) == MINION_TYPE_MONSTER then
					if Utilities:IsInAutoAttackRange(myHero, minion) then
						Linq:Add(result, minion);
					end
				end
			end
			return result;
		end
		function c:GetHeroes(range)
			local result = {};
			for i = 1, LocalGameHeroCount() do
				local hero = LocalGameHero(i);
				if Utilities:IsValidTarget(hero) then
					if Utilities:IsInRange(myHero, hero, range) then
						Linq:Add(result, hero);
					end
				end
			end
			return result;
		end
		function c:GetAllyHeroes(range)
			local result = {};
			for i = 1, LocalGameHeroCount() do
				local hero = LocalGameHero(i);
				if Utilities:IsValidTarget(hero) and hero.isAlly then
					if Utilities:IsInRange(myHero, hero, range) then
						Linq:Add(result, hero);
					end
				end
			end
			return result;
		end
		function c:GetEnemyHeroes(range)
			local result = {};
			for i = 1, LocalGameHeroCount() do
				local hero = LocalGameHero(i);
				if Utilities:IsValidTarget(hero) and hero.isEnemy then
					if Utilities:IsInRange(myHero, hero, range) then
						Linq:Add(result, hero);
					end
				end
			end
			return result;
		end
		function c:GetEnemyHeroesInAutoAttackRange()
			local result = {};
			for i = 1, LocalGameHeroCount() do
				local hero = LocalGameHero(i);
				if Utilities:IsValidTarget(hero) and hero.isEnemy then
					if Utilities:IsInAutoAttackRange(myHero, hero) then
						Linq:Add(result, hero);
					end
				end
			end
			return result;
		end
		function c:GetTurrets(range)
			return Linq:Join(self:GetAllyTurrets(range), self:GetEnemyTurrets(range))
		end
		function c:GetAllyTurrets(range)
			local result = {};
			local turrets = OBJECTS.AllyTurrets
			for i = 1, #turrets do
				local turret = turrets[i];
				if Utilities:IsValidTarget(turret) then
					if Utilities:IsInRange(myHero, turret, range) then
						Linq:Add(result, turret);
					end
				end
			end
			return result;
		end
		function c:GetEnemyTurrets(range)
			local result = {};
			local turrets = OBJECTS.EnemyTurrets
			for i = 1, #turrets do
				local turret = turrets[i];
				if Utilities:IsValidTarget(turret) then
					if Utilities:IsInRange(myHero, turret, range) then
						Linq:Add(result, turret);
					end
				end
			end
			return result;
		end
		return result
	end,
	TargetSelector = function()
		local c = {}
		local result =
		{
			SelectedTarget = nil
		}
		-- init
			c.__index = c
			setmetatable(result, c)
		function c:GetPriority(target)
			local x = TS.Priorities[target.charName]
			if x ~= nil then
				return x
			end
			return 1
		end
		function c:GetTarget(a, damageType, bb, validmode)
			return TS:GetTarget(a, damageType, bb, validmode)
		end
		return result
	end,
	HealthPrediction = function()
		local c = {}
		local result = {}
		-- init
			c.__index = c
			setmetatable(result, c)
		function c:GetPrediction(target, time)
			return FARM:GetPrediction(target, time)
		end
		return result
	end,
	Orbwalker = function()
		local c = {}
		local result =
		{
			Menu =
			{
				General =
				{
					HoldRadius = nil,
					MovementDelay = nil
				}
			},
			LastHoldPosition = 0,
			HoldPosition == nil,
			AutoAttackResetted = false,
			IsNone = true,
			ForceMovement = nil,
			ForceTarget = nil,
			MenuKeys = {
				[ORBWALKER_MODE_COMBO] = {},
				[ORBWALKER_MODE_HARASS] = {},
				[ORBWALKER_MODE_LANECLEAR] = {},
				[ORBWALKER_MODE_JUNGLECLEAR] = {},
				[ORBWALKER_MODE_LASTHIT] = {},
				[ORBWALKER_MODE_FLEE] = {}
			},
			Modes = {
				[ORBWALKER_MODE_COMBO] = false,
				[ORBWALKER_MODE_HARASS] = false,
				[ORBWALKER_MODE_LANECLEAR] = false,
				[ORBWALKER_MODE_JUNGLECLEAR] = false,
				[ORBWALKER_MODE_LASTHIT] = false,
				[ORBWALKER_MODE_FLEE] = false
			},
			AllowMovement = {
				["Kaisa"] = function(unit)
					return BuffManager:HasBuff(unit, "KaisaE");
				end,
				["Lucian"] = function(unit)
					return BuffManager:HasBuff(unit, "LucianR");
				end,
				["Varus"] = function(unit)
					return BuffManager:HasBuff(unit, "VarusQ");
				end,
				["Vi"] = function(unit)
					return BuffManager:HasBuff(unit, "ViQ");
				end,
				["Vladimir"] = function(unit)
					return BuffManager:HasBuff(unit, "VladimirE");
				end,
				["Xerath"] = function(unit)
					return BuffManager:HasBuff(unit, "XerathArcanopulseChargeUp");
				end
			},
			DisableAutoAttack = {
				["Urgot"] = function(unit)
					return BuffManager:HasBuff(unit, "UrgotW")
				end,
				["Darius"] = function(unit)
					return BuffManager:HasBuff(unit, "dariusqcast");
				end,
				["Graves"] = function(unit)
					if LocalMathAbs(unit.hudAmmo) < EPSILON then
						return true;
					end
					return false;
				end,
				["Jhin"] = function(unit)
					if BuffManager:HasBuff(unit, "JhinPassiveReload") then
						return true;
					end
					if LocalMathAbs(unit.hudAmmo) < EPSILON then
						return true;
					end
					return false;
				end
			}
		}
		-- init
			c.__index = c
			setmetatable(result, c)
		function c:RegisterMenuKey(mode, key)
			Linq:Add(self.MenuKeys[mode], key);
		end
		function c:HasMode(mode)
			if mode == ORBWALKER_MODE_NONE then
				for _, value in pairs(self:GetModes()) do
					if value then
						return false;
					end
				end
				return true;
			end
			for i = 1, #self.MenuKeys[mode] do
				local key = self.MenuKeys[mode][i];
				if key:Value() then
					return true;
				end
			end
			return false;
		end
		function c:GetModes()
			return {
				[ORBWALKER_MODE_COMBO] 			= self:HasMode(ORBWALKER_MODE_COMBO),
				[ORBWALKER_MODE_HARASS] 		= self:HasMode(ORBWALKER_MODE_HARASS),
				[ORBWALKER_MODE_LANECLEAR] 		= self:HasMode(ORBWALKER_MODE_LANECLEAR),
				[ORBWALKER_MODE_JUNGLECLEAR] 	= self:HasMode(ORBWALKER_MODE_JUNGLECLEAR),
				[ORBWALKER_MODE_LASTHIT] 		= self:HasMode(ORBWALKER_MODE_LASTHIT),
				[ORBWALKER_MODE_FLEE] 			= self:HasMode(ORBWALKER_MODE_FLEE)
			}
		end
		function c:OnPreMovement(cb)
			ORB:OnPreMovement(cb)
		end
		function c:OnPreAttack(cb)
			ORB:OnPreAttack(cb)
		end
		function c:OnAttack(cb)
			ORB:OnAttack(cb)
		end
		function c:OnUnkillableMinion(cb)
			FARM.OnUnkillableC[#FARM.OnUnkillableC+1] = cb
		end
		function c:OnPostAttack(cb)
			ORB:OnPostAttack(cb)
		end
		function c:OnPostAttackTick(cb)
			ORB:OnPostAttackTick(cb)
		end
		function c:SetMovement(boolean)
			ORB.MovementEnabled = boolean
		end
		function c:SetAttack(boolean)
			ORB.AttackEnabled = boolean
		end
		function c:ShouldWait()
			return LocalGameTimer() <= FARM.ShouldWaitTime + MENU.orb.lclear.swait:Value() * 0.001
		end
		function c:GetTarget()
			return ORB:GetTarget()
		end
		function c:IsEnabled()
			return true
		end
		function c:Orbwalk()
			ORB:Orbwalk()
		end
		function c:IsAutoAttacking(unit)
			local me = unit or myHero
			if me.isMe then
				return not ORB:CanMoveSpell()
			end
			return LocalGameTimer() < unit.attackData.endTime - unit.attackData.windDownTime
		end
		function c:CanMove(unit)
			local result = true
			unit = unit or myHero
			if self:IsAutoAttacking(unit) then
				result = false
			end
			if result and Utilities:IsChanneling(unit) then
				if self.AllowMovement[unit.charName] == nil or (not self.AllowMovement[unit.charName](unit)) then
					result = false
				end
			end
			return result
		end
		function c:CanAttack(unit)
			local result = true
			unit = unit or myHero
			if unit.isMe then
				return ORB:CanAttack()
			end
			if result and Utilities:IsChanneling(unit) then
				result = false;
			end
			if result and self.DisableAutoAttack[unit.charName] ~= nil and self.DisableAutoAttack[unit.charName](unit) then
				result = false;
			end
			return result
		end
		function c:__OnAutoAttackReset()
			ACTIONS:Add(function()
				ORB.ResetAttack = true
				ORB.AttackLocalStart = 0
				ORB.AttackStartTime = 0
			end, 0.05)
		end
		return result
	end,
	Gamsteron = function()
		local c = {}
		local _init =
		{
			LastQ = 0,
			LastW = 0,
			LastE = 0,
			LastR = 0,
			LastQk = 0,
			LastWk = 0,
			LastEk = 0,
			LastRk = 0,
			StunBuffs =
			{
				["recall"]						= true,
				-- Aatrox
				["AatroxQ"]						= true,
				["AatroxE"]						= true,
				-- Ahri
				["AhriSeduce"] 					= true,
				-- Alistar
				["Pulverize"] 					= true,
				-- Amumu
				["BandageToss"] 				= true,
				["CurseoftheSadMummy"] 			= true,
				-- Anivia
				["FlashFrostSpell"] 			= true,
				-- Ashe
				["EnchantedCrystalArrow"] 		= true,
				-- Bard
				["BardQ"] 						= true,
				-- Blitzcrank
				["RocketGrab"] 					= true,
				-- Braum
				["BraumQ"] 						= true,
				["BraumRWrapper"] 				= true,
				-- Cassiopeia
				["CassiopeiaPetrifyingGaze"]	= true,
				-- Chogath
				["Rupture"] 					= true,
				-- Darius
				["DariusAxeGrabCone"] 			= true,
				-- Diana
				["DianaVortex"] 				= true,
				-- DrMundo
				["InfectedCleaverMissileCast"] 	= true,
				-- Draven
				["DravenDoubleShot"] 			= true,
				-- Elise
				["EliseHumanE"] 				= true,
				-- Evelynn
				["EvelynnR"] 					= true,
				-- FiddleSticks
				["Terrify"] 					= true,
				-- Fizz
				["FizzMarinerDoom"] 			= true,
				-- Galio
				["GalioResoluteSmite"] 			= true,
				["GalioIdolOfDurand"] 			= true,
				-- Gnar
				["gnarbigq"] 					= true,
				["GnarQ"] 						= true,
				["gnarbigw"] 					= true,
				["GnarR"] 						= true,
				-- Gragas
				["GragasE"] 					= true,
				["GragasR"] 					= true,
				-- Hecarim
				["HecarimUlt"] 					= true,
				-- Heimerdinger
				["HeimerdingerE"] 				= true,
				-- Irelia
				["IreliaEquilibriumStrike"] 	= true,
				-- Janna
				["HowlingGale"] 				= true,
				["SowTheWind"] 					= true,
				-- JarvanIV
				["JarvanIVDragonStrike2"] 		= true,
				-- Jayce
				["JayceToTheSkies"] 			= true,
				["JayceThunderingBlow"] 		= true,
				-- Karma
				["KarmaQMissileMantra"] 		= true,
				["KarmaQ"] 						= true,
				["KarmaW"] 						= true,
				-- Kassadin
				["ForcePulse"] 					= true,
				-- Kayle
				["JudicatorReckoning"] 			= true,
				-- KhaZix
				["KhazixW"] 					= true,
				["khazixwlong"] 				= true,
				-- KogMaw
				["KogMawVoidOoze"] 				= true,
				-- LeBlanc
				["LeblancSoulShackle"] 			= true,
				["LeblancSoulShackleM"] 		= true,
				-- LeeSin
				["BlindMonkQOne"] 				= true,
				["BlindMonkRKick"] 				= true,
				-- Leona
				["LeonaSolarFlare"] 			= true,
				-- Lissandra
				["LissandraW"] 					= true,
				["LissandraR"] 					= true,
				-- Lulu
				["LuluQ"] 						= true,
				["LuluW"] 						= true,
				-- Lux
				["LuxLightBinding"] 			= true,
				-- Malphite
				["SeismicShard"] 				= true,
				["UFSlash"] 					= true,
				-- Malzahar
				["AlZaharNetherGrasp"] 			= true,
				-- Maokai
				["MaokaiTrunkLine"] 			= true,
				["MaokaiW"] 					= true,
				-- Morgana
				["DarkBindingMissile"] 			= true,
				["SoulShackles"] 				= true,
				["Stun"]						= true,
				-- Nami
				["NamiQ"] 						= true,
				["NamiR"] 						= true,
				-- Nasus
				["NasusW"] 						= true,
				-- Nautilus
				["NautilusAnchorDrag"] 			= true,
				["NautilusR"] 					= true,
				-- Nocturne
				["NocturneUnspeakableHorror"]	= true,
				-- Nunu
				["IceBlast"]					= true,
				-- Olaf
				["OlafAxeThrowCast"]			= true,
				-- Orianna
				--0
				-- Pantheon
				["PantheonW"]					= true,
				-- Poppy
				["PoppyHeroicCharge"]			= true,
				-- Quinn
				["QuinnQ"]						= true,
				["QuinnE"]						= true,
				-- Rammus
				["PuncturingTaunt"]				= true,
				-- Rengar
				["RengarE"]						= true,
				-- Riven
				["RivenMartyr"]					= true,
				-- Rumble
				["RumbleGrenade"]				= true,
				-- Ryze
				["RyzeW"]						= true,
				-- Sejuani
				["SejuaniArcticAssault"]		= true,
				["SejuaniGlacialPrisonCast"]	= true,
				-- Shaco
				["TwoShivPoison"]				= true,
				-- Shen
				["ShenShadowDash"]				= true,
				-- Shyvana
				["ShyvanaTransformCast"]		= true,
				-- Singed
				["Fling"]						= true,
				-- Skarner
				["SkarnerFracture"]				= true,
				["SkarnerImpale"]				= true,
				-- Sona
				["SonaR"]						= true,
				-- Swain
				["SwainQ"]						= true,
				["SwainShadowGrasp"]			= true,
				-- Syndra
				["syndrawcast"]					= true,
				["SyndraE"]						= true,
				-- TahmKench
				["TahmKenchQ"]					= true,
				["TahmKenchE"]					= true,
				-- Taric
				["Dazzle"]						= true,
				-- Teemo
				["BlindingDart"]				= true,
				-- Thresh
				["ThreshQ"]						= true,
				["ThreshE"]						= true,
				-- Tristana
				["TristanaR"]					= true,
				-- Tryndamere
				["MockingShout"] 				= true,
				-- Urgot
				["UrgotR"]						= true,
				-- Varus
				["VarusR"]						= true,
				-- Vayne
				["VayneCondemn"]				= true,
				-- Veigar
				["VeigarEventHorizon"]			= true,
				-- VelKoz
				["VelkozQMissile"]				= true,
				["VelkozQMissileSplit"]			= true,
				["VelkozE"]						= true,
				-- Vi
				["ViQMissile"]					= true,
				["ViR"]							= true,
				-- Viktor
				["ViktorGravitonField"]			= true,
				-- Warwick
				["InfiniteDuress"]				= true,
				-- Xerath
				["XerathArcaneBarrage2"]		= true,
				["XerathMageSpear"]				= true,
				-- Yasou
				["yasuoq3w"]					= true,
				-- Zac
				["ZacQ"]						= true,
				["ZacE"]						= true,
				-- Ziggs
				["ZiggsW"]						= true,
				-- Zilean
				["ZileanQ"]						= true,
				["TimeWarp"]					= true,
				-- Zyra
				["ZyraGraspingRoots"]			= true,
				["ZyraBrambleZone"]				= true
			}
		}
		-- [ init ]
			c.__index = c
			setmetatable(_init, c)
		function c:GetComboTarget()
			return TS:GetComboTarget()
		end
		function c:OnTick(cb)
			ORB:OnTick(cb)
		end
		function c:GetEnemyHeroes(range, bb, state)
			return OB:GetEnemyHeroes(range, bb, state)
		end
		function c:IsReady(spell, delays)
			delays = delays or { q = 0.25, w = 0.25, e = 0.25, r = 0.25 }
			local currentTime = LocalGameTimer()
			if not CURSOR.IsReady or CONTROLL ~= nil or currentTime <= NEXT_CONTROLL + 0.05 then
				return false
			end
			if currentTime < self.LastQ + delays.q or currentTime < self.LastQk + delays.q then
				return false
			end
			if currentTime < self.LastW + delays.w or currentTime < self.LastWk + delays.w then
				return false
			end
			if currentTime < self.LastE + delays.e or currentTime < self.LastEk + delays.e then
				return false
			end
			if currentTime < self.LastR + delays.r or currentTime < self.LastRk + delays.r then
				return false
			end
			if LocalGameCanUseSpell(spell) ~= 0 then
				return false
			end
			return true
		end
		function c:CastManualSpell(spell, delays)
			if self:IsReady(spell, delays) then
				local kNum = 0
				if spell == _W then
					  kNum = 1
				elseif spell == _E then
					  kNum = 2
				elseif spell == _R then
					  kNum = 3
				end
				local currentTime = LocalGameTimer()
				for k,v in pairs(SPELLS.DelayedSpell) do
					if currentTime - v[2] > 0.125 then
						SPELLS.DelayedSpell[k] = nil
					elseif k == kNum then
						v[1]()
						if k == 0 then
							self.LastQ = currentTime
						elseif k == 1 then
							self.LastW = currentTime
						elseif k == 2 then
							self.LastE = currentTime
						elseif k == 3 then
							self.LastR = currentTime
						end
						SPELLS.DelayedSpell[k] = nil
						break
					end
				end
			end
		end
		function c:GetBuffDuration(unit, bName)
			bName = bName:lower()
			for i = 0, unit.buffCount do
				local buff = unit:GetBuff(i)
				if buff and buff.count > 0 and buff.name:lower() == bName then
					return buff.duration
				end
			end
			return 0
		end
		function c:IsImmobile(unit, delay)
			for i = 0, unit.buffCount do
				local buff = unit:GetBuff(i)
				if buff and buff.count > 0 and buff.duration > delay and self.StunBuffs[buff.name] then
					return true
				end
			end
			return false
		end
		function c:IsSlowed(unit, delay)
			for i = 0, unit.buffCount do
				local buff = unit:GetBuff(i)
				if from and buff.count > 0 and buff.type == 10 and buff.duration >= delay then
					return true
				end
			end
			return false
		end
		function c:HasBuff(unit, bName)
			bName = bName:lower()
			for i = 0, unit.buffCount do
				local buff = unit:GetBuff(i)
				if buff and buff.count > 0 and buff.name:lower() == bName then
					return true
				end
			end
			return false
		end
		function c:GetBuffCount(unit, bName)
			bName = bName:lower()
			for i = 0, unit.buffCount do
				local buff = unit:GetBuff(i)
				if buff and buff.count > 0 and buff.name:lower() == bName then
					return buff.count
				end
			end
			return 0
		end
		function c:GetEnemyMinions(range, bb)
			return OB:GetEnemyMinions(range, bb)
		end
		function c:OnEnemyHeroLoad(cb)
			OB:OnEnemyHeroLoad(cb)
		end
		function c:GetClosestEnemy(enemyList, maxDistance)
			local result = nil
			for i = 1, #enemyList do
				local hero = enemyList[i]
				local distance = myHero.pos:DistanceTo(hero.pos)
				if distance < maxDistance then
					maxDistance = distance
					result = hero
				end
			end
			return result
		end
		function c:GetLastSpellTimers()
			return self.LastQ, self.LastQk, self.LastW, self.LastWk, self.LastE, self.LastEk, self.LastR, self.LastRk
		end
		function c:GetLatency()
			return UTILS:GetLatency(0)
		end
		function c:CustomIsReady(spell, cd)
			local passT
			if spell == _Q then
				passT = LocalGameTimer() - self.LastQk
			elseif spell == _W then
				passT = LocalGameTimer() - self.LastWk
			elseif spell == _E then
				passT = LocalGameTimer() - self.LastEk
			elseif spell == _R then
				passT = LocalGameTimer() - self.LastRk
			end
			local cdr = 1 - myHero.cdr
			cd = cd * cdr
			local latency = UTILS:GetLatency(0)
			if passT - latency - 0.15 > cd then
				return true
			end
			return false
		end
		function c:GetImmobileEnemy(enemyList, maxDistance)
			local result = nil
			local num = 0
			for i = 1, #enemyList do
				local hero = enemyList[i]
				local distance = myHero.pos:DistanceTo(hero.pos)
				local iT = self:ImmobileTime(hero)
				if distance < maxDistance and iT > num then
					num = iT
					result = hero
				end
			end
			return result
		end
		function c:ImmobileTime(unit)
			local iT = 0
			for i = 0, unit.buffCount do
				local buff = unit:GetBuff(i)
				if buff and buff.count > 0 then
					local bType = buff.type
					if bType == 5 or bType == 11 or bType == 21 or bType == 22 or bType == 24 or bType == 29 or buff.name == "recall" then
						local bDuration = buff.duration
						if bDuration > iT then
							iT = bDuration
						end
					end
				end
			end
			return iT
		end
		function c:IsBeforeAttack(multipier)
			if LocalGameTimer() > ORB.AttackLocalStart + multipier * myHero.attackData.animationTime then
				return true
			else
				return false
			end
		end
		function c:CanAttack(cb)
			ORB.CanAttackC = cb
		end
		function c:CanMove(cb)
			ORB.CanMoveC = cb
		end
		function c:CheckSpellDelays(delays)
			local currentTime = LocalGameTimer()
			if currentTime < self.LastQ + delays.q or currentTime < self.LastQk + delays.q then
				return false
			end
			if currentTime < self.LastW + delays.w or currentTime < self.LastWk + delays.w then
				return false
			end
			if currentTime < self.LastE + delays.e or currentTime < self.LastEk + delays.e then
				return false
			end
			if currentTime < self.LastR + delays.r or currentTime < self.LastRk + delays.r then
				return false
			end
			return true
		end
		function c:GetLastHitHandle()
			return FARM.LastHandle
		end
		function c:GetClearHandle()
			return FARM.LastLCHandle
		end
		function c:SpellClear(spell, spelldata, damagefunc)
			local c = {}
			local result =
			{
				Delay = spelldata.delay,
				Speed = spelldata.speed,
				Range = spelldata.range,
				TurretHasTarget = false,
				CanCheckTurret = true,
				ShouldWaitTime = 0,
				IsLastHitable = false,
				LastHandle = 0,
				LastLCHandle = 0,
				FarmMinions = {}
			}
			-- init
				c.__index = c
				setmetatable(result, c)
			function c:GetLastHitTargets()
				local result = {}
				if self.IsLastHitable and not Orbwalker.IsNone and not Orbwalker.Modes[ORBWALKER_MODE_COMBO] then
					for i = 1, #self.FarmMinions do
						local minion = self.FarmMinions[i]
						if minion.LastHitable then
							local unit = minion.Minion
							if unit.handle ~= FARM.LastHandle and not unit.dead then
								result[#result+1] = unit
							end
						end
					end
				end
				return result
			end
			function c:GetLaneClearTargets()
				local result = {}
				if ORB.Modes[ORBWALKER_MODE_LANECLEAR] and self:CanLaneClear() then
					for i = 1, #self.FarmMinions do
						local minion = self.FarmMinions[i]
						local unit = minion.Minion
						if unit.handle ~= FARM.LastLCHandle and not unit.dead then
							result[#result+1] = unit
						end
					end
				end
				return result
			end
			function c:GetObjects(team)
				if team == TEAM_ALLY then
					return FARM.CachedTeamAlly
				elseif team == TEAM_ENEMY then
					return FARM.CachedTeamEnemy
				elseif team == TEAM_JUNGLE then
					return FARM.CachedTeamJungle
				end
			end
			function c:SetAttacks(target)
				-- target handle
				local handle = target.handle
				-- Cached Attacks
				if FARM.CachedAttacks[handle] == nil then
					FARM.CachedAttacks[handle] = {}
					-- target team
					local team = target.team
					-- charName
					local name = target.charName
					-- set attacks
					local pos = target.pos
					-- cached objects
					FARM:SetObjects(team)
					local attackers = self:GetObjects(team)
					for i = 1, #attackers do
						local obj = attackers[i]
						local objname = obj.charName
						if FARM.CachedAttackData[objname] == nil then
							FARM.CachedAttackData[objname] = {}
						end
						if FARM.CachedAttackData[objname][name] == nil then
							FARM.CachedAttackData[objname][name] = { Range = Utilities:GetAutoAttackRange(obj, target), Damage = 0 }
						end
						local range = FARM.CachedAttackData[objname][name].Range + 100
						if Utilities:GetDistanceSquared(obj.pos, pos) < range * range then
							if FARM.CachedAttackData[objname][name].Damage == 0 then
								FARM.CachedAttackData[objname][name].Damage = Damage:GetAutoAttackDamage(obj, target)
							end
							FARM.CachedAttacks[handle][#FARM.CachedAttacks[handle]+1] = {
								Attacker = obj,
								Damage = FARM.CachedAttackData[objname][name].Damage,
								Type = obj.type
							}
						end
					end
				end
				return FARM.CachedAttacks[handle]
			end
			function c:GetPossibleDmg(target)
				local result = 0
				local handle = target.handle
				local attacks = FARM.CachedAttacks[handle]
				if #attacks == 0 then return 0 end
				local pos = target.pos
				for i = 1, #attacks do
					local attack = attacks[i]
					local attacker = attack.Attacker
					if (not self.TurretHasTarget and attack.Type == Obj_AI_Turret) or (attack.Type == Obj_AI_Minion and attacker.pathing.hasMovePath) then
						result = result + attack.Damage
					end
				end
				return result
			end
			function c:GetPrediction(target, time)
				self:SetAttacks(target)
				local handle = target.handle
				local attacks = FARM.CachedAttacks[handle]
				local hp = Utilities:TotalShieldHealth(target)
				if #attacks == 0 then return hp end
				local pos = target.pos
				for i = 1, #attacks do
					local attack = attacks[i]
					local attacker = attack.Attacker
					local dmg = attack.Damage
					local objtype = attack.Type
					local isTurret = objtype == Obj_AI_Turret
					local ismoving = false
					if not isTurret then ismoving = attacker.pathing.hasMovePath end
					if attacker.attackData.target == handle and not ismoving then
						if isTurret and self.CanCheckTurret then
							self.TurretHasTarget = true
						end
						local flyTime
						local time2 = time
						local projSpeed = attacker.attackData.projectileSpeed; if isTurret then projSpeed = 700; time2 = time2 - 0.1; end
						if projSpeed and projSpeed > 0 then
							flyTime = attacker.pos:DistanceTo(pos) / projSpeed
						else
							flyTime = 0
						end
						local endTime = (attacker.attackData.endTime - attacker.attackData.animationTime) + flyTime + attacker.attackData.windUpTime
						if endTime <= LocalGameTimer() then
							endTime = endTime + attacker.attackData.animationTime + flyTime
						end
						while endTime - LocalGameTimer() < time2 do
							hp = hp - dmg
							endTime = endTime + attacker.attackData.animationTime + flyTime
						end
					end
				end
				return hp
			end
			function c:ShouldWait()
				return LocalGameTimer() <= self.ShouldWaitTime + MENU.orb.lclear.swait:Value() * 0.001
			end
			function c:SetLastHitable(target, time, damage)
				local hpPred = self:GetPrediction(target, time)
				local lastHitable = hpPred - damage < 0
				if lastHitable then self.IsLastHitable = true end
				local almostLastHitable = false
				if not lastHitable then
					local dmg = self:GetPrediction(target, myHero:GetSpellData(spell).cd + (time * 3)) - self:GetPossibleDmg(target)
					almostLastHitable = dmg - damage < 0
				end
				if almostLastHitable then
					self.ShouldWaitTime = LocalGameTimer()
				end
				return { LastHitable =  lastHitable, Unkillable = hpPred < 0, Time = time, AlmostLastHitable = almostLastHitable, PredictedHP = hpPred, Minion = target }
			end
			function c:Tick()
				self.FarmMinions = {}
				self.TurretHasTarget = false
				self.CanCheckTurret = true
				self.IsLastHitable = false
				if myHero:GetSpellData(spell).level == 0 then
					return
				end
				if myHero.mana < myHero:GetSpellData(spell).mana then
					return
				end
				if LocalGameCanUseSpell(spell) ~= 0 and myHero:GetSpellData(spell).currentCd > 0.5 then
					return
				end
				if Orbwalker.Modes[ORBWALKER_MODE_COMBO] or Orbwalker.IsNone then
					return
				end
				local targets = OB:GetEnemyMinions(self.Range - 35, false)
				local projectileSpeed = self.Speed
				local winduptime = self.Delay
				local latency = UTILS:GetLatency(0) * 0.5
				local pos = myHero.pos
				for i = 1, #targets do
					local target = targets[i]
					local FlyTime = pos:DistanceTo(target.pos) / projectileSpeed
					self.FarmMinions[#self.FarmMinions+1] = self:SetLastHitable(target, winduptime + FlyTime + latency, damagefunc())
				end
				self.CanCheckTurret = false
			end
			return result
		end
		function c:DelayedAction(func, delay)
			ACTIONS:Add(func, delay)
		end
		function c:OnAllyHeroLoad(func)
			OBJECTS.OnAllyHeroLoad[#OBJECTS.OnAllyHeroLoad+1] = func
		end
		return _init
	end
}
-- get classes
-- local
CURSOR = META1.CURSOR()
TS = META1.TS()
FARM = META1.FARM()
OB = META1.OB()
ORB = META1.ORB()
ACTIONS = META1.ACTIONS()
UTILS = META1.UTILS()
OBJECTS = META1.OBJECTS()
SPELLS = META1.SPELLS()
-- global
Linq = META2.Linq()
ObjectManager = META2.ObjectManager()
Utilities = META2.Utilities()
BuffManager = META2.BuffManager()
ItemManager = META2.ItemManager()
Damage = META2.Damage()
TargetSelector = META2.TargetSelector()
HealthPrediction = META2.HealthPrediction()
Orbwalker = META2.Orbwalker()
Gamsteron = META2.Gamsteron()
_G.SDK =
{
	DAMAGE_TYPE_PHYSICAL = 0,
	DAMAGE_TYPE_MAGICAL = 1,
	DAMAGE_TYPE_TRUE = 2,
	ORBWALKER_MODE_NONE = -1,
	ORBWALKER_MODE_COMBO = 0,
	ORBWALKER_MODE_HARASS = 1,
	ORBWALKER_MODE_LANECLEAR = 2,
	ORBWALKER_MODE_JUNGLECLEAR = 3,
	ORBWALKER_MODE_LASTHIT = 4,
	ORBWALKER_MODE_FLEE = 5
}
_G.SDK.Linq = Linq
_G.SDK.ObjectManager = ObjectManager
_G.SDK.Utilities = Utilities
_G.SDK.BuffManager = BuffManager
_G.SDK.ItemManager = ItemManager
_G.SDK.Damage = Damage
_G.SDK.TargetSelector = TargetSelector
_G.SDK.HealthPrediction = HealthPrediction
_G.SDK.Orbwalker = Orbwalker
_G.SDK.Gamsteron = Gamsteron
-- replicate control
_G.Control.Attack = function(target)
	if CONTROLL == nil and LocalGameTimer() > NEXT_CONTROLL + 0.05 then
		CONTROLL = function()
			if CURSOR.IsReady then
				ORB:Attack(target)
				NEXT_CONTROLL = LocalGameTimer()
				return true
			end
			return false
		end
		return true
	end
	return false
end
_G.Control.Move = function(a, b, c)
	if CONTROLL == nil and LocalGameTimer() > NEXT_CONTROLL + 0.05 then
		local position
		if a and b and c then
			position = LocalVector(a, b, c)
		elseif a and b then
			position = LocalVector({ x = a, y = b})
		elseif a then
			if a.pos then
				position = a.pos
			else
				position = a
			end
		end
		CONTROLL = function()
			if position then
				if CURSOR.IsReady then
					ORB:MoveToPos(position)
					SPELLS.CanNext = true
					return true
				end
			else
				ORB:Move()
				SPELLS.CanNext = true
				return true
			end
			return false
		end
		return true
	end
	return false
end
_G.Control.CastSpell = function(key, a, b, c)
	if CONTROLL == nil and LocalGameTimer() > NEXT_CONTROLL + 0.05 then
		local position
		if a and b and c then
			position = LocalVector(a, b, c)
		elseif a and b then
			position = LocalVector({ x = a, y = b})
		elseif a then
			if a.pos then
				position = a.pos
			else
				position = a
			end
		end
		local spell
		if key == HK_Q then
			spell = _Q
		elseif key == HK_W then
			spell = _W
		elseif key == HK_E then
			spell = _E
		elseif key == HK_R then
			spell = _R
		end
		if spell ~= nil and LocalGameCanUseSpell(spell) ~= 0 then
			return false
		end
		if spell ~= nil and not SPELLS.CanNext then
			return false
		end
		if position ~= nil and not CURSOR.IsReady then
			return false
		end
		if position ~= nil and MENU_CHAMP.spell.isaa:Value() and Orbwalker:IsAutoAttacking(myHero) then
			return false
		end
		if spell == _Q then
			if LocalGameTimer() < Gamsteron.LastQ + 0.25 then
				return false
			else
				Gamsteron.LastQ = LocalGameTimer()
			end
		elseif spell == _W then
			if LocalGameTimer() < Gamsteron.LastW + 0.25 then
				return false
			else
				Gamsteron.LastW = LocalGameTimer()
			end
		elseif spell == _E then
			if LocalGameTimer() < Gamsteron.LastE + 0.25 then
				return false
			else
				Gamsteron.LastE = LocalGameTimer()
			end
		elseif spell == _R then
			if LocalGameTimer() < Gamsteron.LastR + 0.25 then
				return false
			else
				Gamsteron.LastR = LocalGameTimer()
			end
		end
		NEXT_CONTROLL = LocalGameTimer()
		CONTROLL = function()
			if position then
				if spell ~= nil and MENU_CHAMP.spell.baa:Value() then
					SPELLS.CanNext = false
				end
				CURSOR:SetCursor(_G.cursorPos, position, key, function()
					LocalControlKeyDown(key)
					LocalControlKeyUp(key)
				end)
				ORB.LastMoveLocal = 0
				return true
			else
				LocalControlKeyDown(key)
				LocalControlKeyUp(key)
				return true
			end
		end
	end
	return false
end
LocalCallbackAdd('Draw', function()
	if LocalGameTimer() < 2 then return end
	TargetSelector.SelectedTarget = TS.SelectedTarget
	ORB:Tick()
	CURSOR:Tick()
	ACTIONS:Tick()
	if CONTROLL ~= nil and CONTROLL() == true then
		CONTROLL = nil
	end
end)

-- load
-- Load Menu
	MENU = MenuElement({name = "gsoOrbwalker", id = "lul", type = _G.MENU, leftIcon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/rsz_gsoorbwalker.png" })
	TS:CreateMenu()
	ORB:CreateMenu()
	MENU:MenuElement({name = "Drawings", id = "gsodraw", leftIcon = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/circles.png", type = _G.MENU })
	MENU.gsodraw:MenuElement({name = "Enabled",  id = "enabled", value = true})
	TS:CreateDrawMenu()
	FARM:CreateDrawMenu()
	CURSOR:CreateDrawMenu()
	ORB:CreateDrawMenu()
-- Load Objects
	local classbuildings = OBJECTS:Buildings()
	local classheroes = OBJECTS:Heroes()
	local function loadobjects()
		local heroesloaded = true
		local buildingsloaded = true
		if not classheroes.loaded then
			classheroes:DoWork()
			heroesloaded = false
		end
		if not classbuildings.loaded then
			classbuildings:DoWork()
			buildingsloaded = false
		end
		if heroesloaded and buildingsloaded then
			OBJECTS.Loaded = true
		end
	end
LocalCallbackAdd('Tick', function()
	local status, err = pcall(function ()
		if LocalGameTimer() < 2 then return end
		if _G.Orbwalker.Enabled:Value() then _G.Orbwalker.Enabled:Value(false) end
		if ORB.IsTeemo then
			ORB.IsBlindedByTeemo = ORB:CheckTeemoBlind()
		end
		if not OBJECTS.Loaded then loadobjects() end
		BuffManager.CachedBuffStacks = {}
		ItemManager.CachedItems = {}
		Utilities.CachedValidTargets = {}
		FARM:Tick()
		SPELLS:DisableAutoAttack()
		if SPELLS.Work ~= nil then
			if LocalGameTimer() < SPELLS.WorkEndTime then
				SPELLS.Work()
				return
			end
			SPELLS.Work = nil
		end
		for i = 1, #ORB.OnTickC do
			ORB.OnTickC[i](args)
		end
	end)
	if not status then print("gsoOrbwalker OnTick " .. tostring(err)) end
end)
LocalCallbackAdd('WndMsg', function(msg, wParam)
	local status, err = pcall(function ()
		TS:WndMsg(msg, wParam)
		ORB:WndMsg(msg, wParam)
		SPELLS:WndMsg(msg, wParam)
	end)
	if not status then print("gsoOrbwalker OnWndMsg " .. tostring(err)) end
end)
LocalCallbackAdd('Draw', function()
	local status, err = pcall(function ()
		if LocalGameTimer() < 2 then return end
		if not MENU.gsodraw.enabled:Value() then return end
		TS:Draw()
		FARM:Draw()
		CURSOR:Draw()
		ORB:Draw()
	end)
	if not status then print("gsoOrbwalker OnDraw " .. tostring(err)) end
end)
