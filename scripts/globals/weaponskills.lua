--Contains all common weaponskill calculations including but not limited to:
-- fSTR
-- Alpha
-- Ratio -> cRatio
-- min/max cRatio
-- applications of fTP
-- applications of critical hits ('Critical hit rate varies with TP.')
-- applications of accuracy mods ('Accuracy varies with TP.')
-- applications of damage mods ('Damage varies with TP.')
-- performance of the actual WS (rand numbers, etc)

function doPhysicalWeaponskill(attacker,target, numHits,  str_wsc,dex_wsc,vit_wsc,agi_wsc,int_wsc,mnd_wsc,chr_wsc,  canCrit,crit100,crit200,crit300,  acc100,acc200,acc300,   atkmulti)
	--get fstr
	fstr = fSTR(attacker:getStat(MOD_STR),target:getStat(MOD_VIT),attacker:getWeaponDmg());
	
	--apply WSC
	local base = attacker:getWeaponDmg() + fstr + 
		(attacker:getStat(MOD_STR) * str_wsc + attacker:getStat(MOD_DEX) * dex_wsc + 
		 attacker:getStat(MOD_VIT) * vit_wsc + attacker:getStat(MOD_AGI) * agi_wsc + 
		 attacker:getStat(MOD_INT) * int_wsc + attacker:getStat(MOD_MND) * mnd_wsc + 
		 attacker:getStat(MOD_CHR) * chr_wsc) * getAlpha(attacker:getMainLvl());
		 
	--Applying fTP multiplier
	ftp = fTP(attacker:getTP(),ftp100,ftp200,ftp300);
	
	--get cratio min and max
	cratio = cRatio( ((attacker:getMod(MOD_ATT)*atkmulti)/target:getMod(MOD_DEF)),attacker:getMainLvl(),target:getMainLvl());
	ccmin = 0;
	ccmax = 0;
	if(canCrit) then --work out critical hit ratios, by +1ing 
		--ccritratio = cCritRatio( ((attacker:getMod(MOD_ATT)*atkmulti)/target:getMod(MOD_DEF))+1,attacker:getMainLvl(),target:getMainLvl());
	end
	
	
	dmg = base * ftp;  
	
	--Applying pDIF
	local double pdif = math.random((cratio[1]*1000),(cratio[2]*1000)); 
	pdif = pdif/1000; --multiplier set.
	
	--First hit has 95% acc always. Second hit + affected by hit rate.
	local double firsthit = math.random();
	local finaldmg = 0;
	hitrate = 0.95; --first hit only
	if(acc100~=0) then
		--ACCURACY VARIES WITH TP, APPLIED TO ALL HITS.
		--print("Accuracy varies with TP.");
		hr = accVariesWithTP(getHitRate(attacker,target,false),attacker:getMod(MOD_ACC),attacker:getTP(),acc100,acc200,acc300);
		hitrate = hr;
	end
	
	local hitslanded = 0; --used for debug
	if (firsthit <= hitrate) then
		finaldmg = dmg * pdif;
		hitslanded = 1;
	end
	
	if(numHits>1) then
		if(acc100==0) then
			--work out acc since we actually need it now
			hitrate = getHitRate(attacker,target,true);
		end
		
		hitsdone = 1;
		while (hitsdone < numHits) do 
			chance = math.random();
			if (chance<=hitrate) then --it hit
				pdif = math.random((cratio[1]*1000),(cratio[2]*1000));  --generate random PDIF
				pdif = pdif/1000; --multiplier set.
				finaldmg = finaldmg + base * pdif; --NOTE: not using 'dmg' since fTP is 1.0 for subsequent hits!!
				hitslanded = hitslanded + 1;
			end
			hitsdone = hitsdone + 1;
		end
	end
	
	print("Landed " .. hitslanded .. "/" .. numHits .. " hits with pdif range " .. cratio[1] .. " to " .. cratio[2] .. "and hitrate " .. hitrate .. "!");
	
	return finaldmg;
end;

function accVariesWithTP(hitrate,acc,tp,a1,a2,a3)
	--sadly acc varies with tp ALL apply an acc PENALTY, the acc at various %s are given as a1 a2 a3
	accpct = fTP(tp,a1,a2,a3);
	acclost = acc - (acc*accpct);
	hrate = hitrate - (0.005*acclost);
	--cap it
	if (hrate>0.95) then
		hrate = 0.95;
	end
	if (hrate<0.2) then
		hrate = 0.2;
	end
	return hrate;
end;

function getHitRate(attacker,target,capHitRate)
	local int acc = attacker:getMod(MOD_ACC);
	local int eva = target:getMod(MOD_EVA);
	
	if(attacker:getMainLvl() > target:getMainLvl()) then --acc bonus!
		acc = acc + ((attacker:getMainLvl()-target:getMainLvl())*4);
	elseif(attacker:getMainLvl() < target:getMainLvl()) then --acc penalty :(
		acc = acc - ((target:getMainLvl()-attacker:getMainLvl())*4);
	end
	
	local double hitdiff = 0;
	local double hitrate = 75;
	if (acc>eva) then
	hitdiff = (acc-eva)/2;
	end
	if (eva>acc) then
	hitdiff = ((-1)*(eva-acc))/2;
	end
	
	hitrate = hitrate+hitdiff;
	hitrate = hitrate/100;
	
	
	--Applying hitrate caps
	if(capHitRate) then --this isn't capped for when acc varies with tp, as more penalties are due
		if (hitrate>0.95) then
			hitrate = 0.95;
		end
		if (hitrate<0.2) then
			hitrate = 0.2;
		end
	end
	return hitrate;
end;

function fTP(tp,ftp1,ftp2,ftp3)
	if(tp>=100 and tp<200) then
		return ftp1 + ( ((ftp2-ftp1)/100) * (tp-100));
	elseif(tp>=200 and tp<=300) then
		--generate a straight line between ftp2 and ftp3 and find point @ tp
		return ftp2 + ( ((ftp3-ftp2)/100) * (tp-200));
	else
		print("fTP error: TP value is not between 100-300!");
	end
	return 1; --no ftp mod
end;

--Given the raw ratio value (atk/def) and levels, returns the cRatio (min then max)
function cRatio(ratio,atk_lvl,def_lvl)
	--Level penalty...
	local double levelcor = 0;
	if (atk_lvl < def_lvl) then
		levelcor = 0.05 * (def_lvl - atk_lvl);
	end
	ratio = ratio - levelcor;
	
	--apply caps
	if(ratio<0) then
		ratio = 0;
	elseif(ratio>2) then
		ratio = 2;
	end
	
	--Obtaining cRatio_MIN
	local double cratiomin = 0;
	if (ratio<1.25) then
		cratiomin = 1.2 * ratio - 0.5;
	elseif (ratio>=1.25 and ratio<=1.5) then
		cratiomin = 1;
	elseif (ratio>1.5 and ratio<=2) then
		cratiomin = 1.2 * ratio - 0.8;
	end
	
	--Obtaining cRatio_MAX
	local double cratiomax = 0;
	if (ratio<0.5) then
		cratiomax = 0.4 + 1.2 * ratio;
	elseif (ratio<=0.833 and ratio>=0.5) then
		cratiomax = 1;
	elseif (ratio<=2 and ratio>0.833) then
		cratiomax = 1.2 * ratio;
	end
	cratio = {};
	cratio[1] = cratiomin;
	cratio[2] = cratiomax;
	return cratio;
end;

--Given the attacker's str and the mob's vit, fSTR is calculated
function fSTR(atk_str,def_vit,base_dmg)
	local dSTR = atk_str - def_vit;
	if (dSTR >= 12) then
		fSTR2 = ((dSTR+4)/2);
	elseif (dSTR >= 6) then
		fSTR2 = ((dSTR+6)/2);
	elseif (dSTR >= 1) then
		fSTR2 = ((dSTR+7)/2);
	elseif (dSTR >= -2) then
		fSTR2 = ((dSTR+8)/2);
	elseif (dSTR >= -7) then
		fSTR2 = ((dSTR+9)/2);
	elseif (dSTR >= -15) then
		fSTR2 = ((dSTR+10)/2);
	elseif (dSTR >= -21) then
		fSTR2 = ((dSTR+12)/2);
	else
		fSTR2 = ((dSTR+13)/2);
	end
	--Apply fSTR caps.
	if (fSTR2<((base_dmg/9)*(-1))) then
		fSTR2 = (base_dmg/9)*(-1);
	elseif (fSTR2>((base_dmg/9)+8)) then
		fSTR2 = (base_dmg/9)+8;
	end 
	return fSTR2;
end;

--obtains alpha, used for working out WSC
function getAlpha(level)
alpha = 1.00; 
if (level <= 5) then
	alpha = 1.00;
elseif (level <= 11) then
	alpha = 0.99;
elseif (level <= 17) then
	alpha = 0.98;
elseif (level <= 23) then
	alpha = 0.97;
elseif (level <= 29) then
	alpha = 0.96;
elseif (level <= 35) then
	alpha = 0.95;
elseif (level <= 41) then
	alpha = 0.94;
elseif (level <= 47) then
	alpha = 0.93;
elseif (level <= 53) then
	alpha = 0.92;
elseif (level <= 59) then
	alpha = 0.91;
elseif (level <= 61) then
	alpha = 0.90;
elseif (level <= 63) then
	alpha = 0.89;
elseif (level <= 65) then
	alpha = 0.88;
elseif (level <= 67) then
	alpha = 0.87;
elseif (level <= 69) then
	alpha = 0.86;
elseif (level <= 71) then
	alpha = 0.85;
elseif (level <= 73) then
	alpha = 0.84;
elseif (level <= 75) then
	alpha = 0.83;
elseif (level <= 99) then
	alpha = 0.85;
end
return alpha;
 end; 