--      Variables
local playerClass = UnitClass("player");
local runOnce = 1;
local show_power      = true;
local show_crit       = true;
local specDecision = "0";
local specDecisionN = "Undecided";
local tempVals;
-- Font
local font_outline    = true;
local font_size       = 14;
-- Colors
local power_color     = "ffef00";
local crit_color      = "ffffff";
local shadow_color    = "660099";
local fire_color      = "ff0000";
local frost_color     = "Bfeaf5";
local holy_color      = "ffffff";
local nature_color    = "00cc00";
local arcane_color    = "ff00ff";
--  Frame Definition
local toonframe = CreateFrame("Frame","toonframe",UIParent)
toonframe:SetWidth(100); toonframe:SetHeight(40);
toonframe:SetMovable(1); toonframe:EnableMouse(1);
toonframe:SetPoint("CENTER", UIParent, "CENTER", -100, -100);
toonframe:RegisterEvent("PLAYER_ALIVE");
toonframe:RegisterEvent("PLAYER_LEVEL_UP");
toonframe:RegisterEvent("CHARACTER_POINTS_CHANGED");
toonframe:RegisterEvent("UNIT_RANGED_ATTACK_POWER");
toonframe:RegisterEvent("UNIT_RANGEDDAMAGE");
toonframe:RegisterEvent("UNIT_DAMAGE");
toonframe:RegisterEvent("UNIT_ATTACK_POWER");
toonframe:RegisterEvent("UNIT_STATS");
toonframe:RegisterEvent("UNIT_AURA");
toonframe:SetScript("OnEvent", function() ToonStats_OnEvent(event, arg1) end)
toonframe:SetScript("OnMouseDown", function() toonframe:StartMoving() end);
toonframe:SetScript("OnMouseUp", function() toonframe:StopMovingOrSizing() end);
toonframe:SetScript("OnDragStop", function() toonframe:StopMovingOrSizing() end);
--  Font String
local toonstr = toonframe:CreateFontString();
toonstr:SetFontObject(GameFontNormal);
toonstr:SetPoint("CENTER", toonframe);
toonstr:SetJustifyH("CENTER"); toonstr:SetJustifyV("MIDDLE");
toonstr:SetText(""..specDecisionN.." - still loading...");
local font, size, flags = GameFontNormal:GetFont();

	if (font_outline) then
		toonstr:SetFont(font, font_size, "OUTLINE");
	else
		toonstr:SetFont(font, font_size);
	end

function ToonStats_OnLoad()
	-- Register events
	this:RegisterEvent("ADDON_LOADED");
	this:RegisterEvent("PLAYER_ALIVE");
	this:RegisterEvent("PLAYER_LEVEL_UP");
	this:RegisterEvent("CHARACTER_POINTS_CHANGED");
	this:RegisterEvent("UNIT_RANGED_ATTACK_POWER");
	this:RegisterEvent("UNIT_RANGEDDAMAGE");
	this:RegisterEvent("UNIT_DAMAGE");
	this:RegisterEvent("UNIT_ATTACK_POWER");
	this:RegisterEvent("UNIT_STATS");
	this:RegisterEvent("UNIT_AURA");
        this:RegisterEvent("UNIT_MANA");
end

function ToonStats_OnEvent()

	if (runOnce == 1) then
		local id, name, icon, pointsSpent, background, previewPointsSpent, isUnlocked = GetTalentTabInfo(1);
		local is1 = pointsSpent;
		local is1n = name;
		local id, name, icon, pointsSpent, background, previewPointsSpent, isUnlocked = GetTalentTabInfo(2);
		local is2 = pointsSpent;
		local is2n = name;
		local id, name, icon, pointsSpent, background, previewPointsSpent, isUnlocked = GetTalentTabInfo(3);
		local is3 = pointsSpent;
		local is3n = name;

		if (is1 >= is2) then
			tempVals = is1;
			specDecision = "1";
			specDecisionN = is1n;
		else
			tempVals = is2;
			specDecision = "2";
			specDecisionN = is2n;
		end
			if (tempVals <= is3) then
			specDecision = "3";
			specDecisionN = is3n;
		end
		runOnce = 0;
	end

	if (playerClass == "Hunter") then
		doRanged();
	end
	if (playerClass == "Death Knight") then
		if (specDecision == "1" or specDecision == "3") then
			doDPS();
		end	
		if (specDecision == "2") then
			doTank();
		end
	end
	if (playerClass == "Warrior") then
		if (specDecision == "1" or specDecision == "2") then
			doDPS();
		end	
		if (specDecision == "3") then
			doTank();
		end
	end
	if (playerClass == "Rogue") then
		doDPS();
	end
	if (playerClass == "Warlock" or playerClass == "Mage") then
		doCaster();
	end
	if (playerClass == "Shaman") then
		if (specDecision == "1" or specDecision == "2") then
			doCaster();
		end	
		if (specDecision == "3") then
			doHeals();
		end
	end
	if (playerClass == "Priest") then
		if (specDecision == "1" or specDecision == "3") then
			doCaster();
		end	
		if (specDecision == "2") then
			doHeals();
		end
	end
	if (playerClass == "Druid") then
		if (specDecision == "1") then
			doCaster();
		end
		if (specDecision == "2") then
			doTank();
		end
		if (specDecision == "3") then
			doHeals();
		end
	end
	if (playerClass == "Paladin") then
		if (specDecision == "1") then
			doHeals();
		end
		if (specDecision == "2") then
			doTank();
		end
		if (specDecision == "3") then
			doDPS();
		else	
			toonstr:SetText("Spec Detection Issue - "..specDecision..is1..is2..is3.." ");
		end
	end

end

function doTank()
	local lowDmg, hiDmg = UnitDamage("player"); 
	local speed = UnitAttackSpeed("player");
	local totalDmg = (lowDmg + hiDmg);
	local averageDmg = (totalDmg / 2);
	local avgDps = (averageDmg / speed);
	local pBaseDefense, pArmorDefense = UnitDefense("player");
	local totalDefense = (pBaseDefense + pArmorDefense);
	local pBaseArmor, effArmor, pArmor, pArmorPosBuff, pArmorNegBuff = UnitArmor("player");
	base, posBuff, negBuff = UnitAttackPower("player");
	pow = base + posBuff + negBuff;
	toonstr:SetText(""..specDecisionN.." (Tank)\r(Attack) - |cff"..crit_color..pow.."|cff"..power_color.."AP / |cff"..crit_color..string.format("%.2f", GetCritChance("player")).."|cff"..power_color.."%CRIT / |cff"..crit_color..string.format("%.1f", avgDps).."|cff"..power_color.."DPS / |cff"..crit_color..string.format("%.2f", speed).."|cff"..power_color.."SPD\r(Defense) - |cff"..crit_color..totalDefense.."|cff"..power_color.."DEF / |cff"..crit_color..effArmor.."|cff"..power_color.."ARMR / |cff"..crit_color..string.format("%.2f", GetBlockChance("player")).."|cff"..power_color.."%BLK / |cff"..crit_color..string.format("%.2f", GetDodgeChance("player")).."|cff"..power_color.."%DGD / |cff"..crit_color..string.format("%.2f", GetParryChance("player")).."|cff"..power_color.."%PAR");
end

function doRanged()
	local speed, lowDmg, hiDmg = UnitRangedDamage("player"); 
	local totalDmg = (lowDmg + hiDmg);
	local averageDmg = (totalDmg / 2);
	local avgDps = (averageDmg / speed);
	base, buff, debuff = UnitRangedAttackPower("player");
	pow = base + buff + debuff;
	toonstr:SetText(""..specDecisionN.." (Ranged)\r(Ranged Attack) - |cff"..crit_color..pow.."|cff"..power_color.."RAP / |cff"..crit_color..string.format("%.2f", GetRangedCritChance("player")).."|cff"..power_color.."% / |cff"..crit_color..string.format("%.1f", avgDps).."|cff"..power_color.."RDPS / |cff"..crit_color..string.format("%.2f", speed).."|cff"..power_color.."SPD\r(Defense) - |cff"..crit_color..string.format("%.2f", GetDodgeChance("player")).."|cff"..power_color.."%DGD / |cff"..crit_color..string.format("%.2f", GetParryChance("player")).."|cff"..power_color.."% Parry");
end

function doDPS()
	local lowDmg, hiDmg = UnitDamage("player"); 
	local speed = UnitAttackSpeed("player");
	local totalDmg = (lowDmg + hiDmg);
	local averageDmg = (totalDmg / 2);
	local avgDps = (averageDmg / speed);
	base, posBuff, negBuff = UnitAttackPower("player");
	pow = base + posBuff + negBuff;
	toonstr:SetText(""..specDecisionN.." (DPS)\r(Attack) - |cff"..crit_color..pow.."|cff"..power_color.."AP / |cff"..crit_color..string.format("%.2f", GetCritChance("player")).."|cff"..power_color.."% / |cff"..crit_color..string.format("%.1f", avgDps).."|cff"..power_color.."DPS / |cff"..crit_color..string.format("%.2f", speed).."|cff"..power_color.."SPD\r(Defense) - |cff"..crit_color..string.format("%.2f", GetDodgeChance("player")).."|cff"..power_color.."%DGD / |cff"..crit_color..string.format("%.2f", GetParryChance("player")).."|cff"..power_color.."% Parry");
end

function doCaster()
local var3 = GetSpellBonusDamage(3);
local var4 = GetSpellBonusDamage(4);
local var5 = GetSpellBonusDamage(5);
local var6 = GetSpellBonusDamage(6);
local var7 = GetSpellBonusDamage(7);

if (var3 == var4 and var4 == var5 and var5 == var6 and var6 == var7) then
	toonstr:SetText(""..specDecisionN.." (Caster)\r(Spell) - |cff"..crit_color..string.format("%.2f", GetSpellCritChance(1)).."% |cff"..power_color.." Spell Crit / |cff"..crit_color.."+"..GetSpellBonusDamage(3).."|cff"..power_color.." SpellDmg (All Schools)");
else
	toonstr:SetText(""..specDecisionN.." (Caster)\r(Spell) - |cff"..string.format("%.2f", GetSpellCritChance(1)).."% |cff"..power_color.." Spell Crit / |cff"..fire_color.."+"..GetSpellBonusDamage(3).." FireDmg|cff"..power_color.." / |cff"..nature_color.."+"..GetSpellBonusDamage(4).." NatDmg |cff"..power_color.." / |cff"..frost_color.."+"..GetSpellBonusDamage(5).." FroDmg|cff"..power_color.." / |cff"..shadow_color.."+"..GetSpellBonusDamage(6).." ShaDmg|cff"..power_color.." / |cff"..arcane_color.."+"..GetSpellBonusDamage(7).." ArcDmg");
end

end

function doHeals()
	local holySchool = 2;
	local minModifier = GetSpellBonusDamage(holySchool);
	local bonusDamage;
	bonusDamage = GetSpellBonusDamage(3);
	minModifier = min(minModifier, bonusDamage);
	toonstr:SetText(""..specDecisionN.." (Heals)\r (Healing) - |cff"..crit_color..string.format("%.2f", GetSpellCritChance(2)).."% |cff"..power_color.." Heal Crit / |cff"..holy_color.."+"..GetSpellBonusHealing().." Healing|cff"..power_color.." / |cff"..crit_color..string.format("%.2f", GetSpellCritChance(2)).."% Holy Crit|cff"..power_color.." / |cff"..crit_color.."+"..GetSpellBonusDamage(2).." HolyDmg");
end

-- Stolen shamelessly from wowwiki.com examples (which in turn was taken from default char frame)...why reinvent the wheel
-- code not working ATM due to 4.0.1 releaseÉupdated caster calcs to simplify without this for now

function GetRealSpellCrit()
	local holySchool=2
	local minCrit = GetSpellCritChance(holySchool);
	local spellCrit;
	
	this.spellCrit = {};
	this.spellCrit[holySchool] = minCrit;
	
	for i=(holySchool+1), 7 do
		spellCrit = GetSpellCritChance(i);
		minCrit = min(minCrit, spellCrit);
		this.spellCrit[i] = spellCrit;
	end

	minCrit = format("%.2f%%", minCrit);
	return minCrit;	
end