 -- Ringslinger Revolution - MobjInfo Table

local RSR = RingslingerRev

if not RSR.MOBJ_INFO then
	RSR.MOBJ_INFO = {}
end

-- MOBJ_INFO Variables
-- health - Health of the object
-- damage - Damage dealt to the player on contact

-- Enemies/Bosses
RSR.MOBJ_INFO[MT_BLUECRAWLA] = {health = 40, damage = 10}
RSR.MOBJ_INFO[MT_REDCRAWLA] = {health = 55, damage = 15}
RSR.MOBJ_INFO[MT_GFZFISH] = {health = 15, damage = 10}
RSR.MOBJ_INFO[MT_GOLDBUZZ] = {health = 40, damage = 10}
RSR.MOBJ_INFO[MT_REDBUZZ] = {health = 55, damage = 15}
RSR.MOBJ_INFO[MT_DETON] = {health = 1, damage = 40}
RSR.MOBJ_INFO[MT_POPUPTURRET] = {health = 1, damage = 10}
RSR.MOBJ_INFO[MT_SPRINGSHELL] = {health = 55, damage = 10}
RSR.MOBJ_INFO[MT_YELLOWSHELL] = {health = 85, damage = 15}
RSR.MOBJ_INFO[MT_SKIM] = {health = 25, damage = 10}
RSR.MOBJ_INFO[MT_JETJAW] = {health = 90, damage = 20}
RSR.MOBJ_INFO[MT_CRUSHSTACEAN] = {health = 125, damage = 20}
RSR.MOBJ_INFO[MT_BANPYURA] = {health = 140, damage = 1}
RSR.MOBJ_INFO[MT_ROBOHOOD] = {health = 30, damage = 5}
RSR.MOBJ_INFO[MT_FACESTABBER] = {health = 250, damage = 45}
RSR.MOBJ_INFO[MT_EGGGUARD] = {health = 15, damage = 25}
RSR.MOBJ_INFO[MT_VULTURE] = {health = 65, damage = 25}
RSR.MOBJ_INFO[MT_GSNAPPER] = {health = 125, damage = 20}
RSR.MOBJ_INFO[MT_MINUS] = {health = 40, damage = 30}
RSR.MOBJ_INFO[MT_CANARIVORE] = {health = 125, damage = 10}
RSR.MOBJ_INFO[MT_UNIDUS] = {health = 117, damage = 10}
RSR.MOBJ_INFO[MT_PTERABYTE] = {health = 65, damage = 15}
RSR.MOBJ_INFO[MT_PYREFLY] = {health = 105, damage = 25}
RSR.MOBJ_INFO[MT_DRAGONBOMBER] = {health = 190, damage = 20}
RSR.MOBJ_INFO[MT_JETTBOMBER] = {health = 80, damage = 15}
RSR.MOBJ_INFO[MT_JETTGUNNER] = {health = 50, damage = 15}
RSR.MOBJ_INFO[MT_SPINCUSHION] = {health = 85, damage = 25}
RSR.MOBJ_INFO[MT_SNAILER] = {health = 125, damage = 10}
RSR.MOBJ_INFO[MT_PENGUINATOR] = {health = 55, damage = 20}
RSR.MOBJ_INFO[MT_POPHAT] = {health = 65, damage = 10}
RSR.MOBJ_INFO[MT_CRAWLACOMMANDER] = {health = 190, damage = 15}
RSR.MOBJ_INFO[MT_SPINBOBERT] = {health = 1, damage = 10}
RSR.MOBJ_INFO[MT_CACOLANTERN] = {health = 145, damage = 30}
RSR.MOBJ_INFO[MT_HANGSTER] = {health = 65, damage = 40}
RSR.MOBJ_INFO[MT_HIVEELEMENTAL] = {health = 225, damage = 10}
RSR.MOBJ_INFO[MT_BUMBLEBORE] = {health = 1, damage = 35}
RSR.MOBJ_INFO[MT_BUGGLE] = {health = 85, damage = 20}
RSR.MOBJ_INFO[MT_POINTY] = {health = 110, damage = 25}
RSR.MOBJ_INFO[MT_EGGMOBILE] = {health = 3000, damage = 15}
RSR.MOBJ_INFO[MT_EGGMOBILE2] = {health = 3000, damage = 15}
RSR.MOBJ_INFO[MT_EGGMOBILE3] = {health = 3000, damage = 15}
RSR.MOBJ_INFO[MT_FAKEMOBILE] = {health = 130, damage = 15}
RSR.MOBJ_INFO[MT_EGGMOBILE4] = {health = 3000, damage = 15}
RSR.MOBJ_INFO[MT_FANG] = {health = 1850, damage = 25}
RSR.MOBJ_INFO[MT_METALSONIC_BATTLE] = {health = 1850, damage = 40}
RSR.MOBJ_INFO[MT_BLACKEGGMAN] = {health = 6250, damage = 20}
RSR.MOBJ_INFO[MT_CYBRAKDEMON] = {health = 5500, damage = 30}
RSR.MOBJ_INFO[MT_CYBRAK2016] = {health = 4500, damage = 40}

-- Ringslinger Projectiles
RSR.MOBJ_INFO[MT_RSR_PROJECTILE_BASIC] = {knockback = 3*FRACUNIT}
RSR.MOBJ_INFO[MT_RSR_PROJECTILE_SCATTER] = {knockback = 6*FRACUNIT}
RSR.MOBJ_INFO[MT_RSR_PROJECTILE_AUTO] = {knockback = 1*FRACUNIT}
RSR.MOBJ_INFO[MT_RSR_PROJECTILE_BOUNCE] = {knockback = 6*FRACUNIT}
RSR.MOBJ_INFO[MT_RSR_PROJECTILE_GRENADE] = {knockback = 6*FRACUNIT}
RSR.MOBJ_INFO[MT_RSR_PROJECTILE_BOMB] = {knockback = 3*FRACUNIT}
RSR.MOBJ_INFO[MT_RSR_PROJECTILE_HOMING] = {knockback = 3*FRACUNIT}
RSR.MOBJ_INFO[MT_RSR_PROJECTILE_RAIL] = {knockback = 12*FRACUNIT}

-- Enemy Projectiles
RSR.MOBJ_INFO[MT_JETTBULLET] = {damage = 10}
RSR.MOBJ_INFO[MT_MINE] = {damage = 20}
RSR.MOBJ_INFO[MT_TURRETLASER] = {damage = 5}
RSR.MOBJ_INFO[MT_CRUSHCLAW] = {damage = 35}
RSR.MOBJ_INFO[MT_ARROW] = {damage = 30}
RSR.MOBJ_INFO[MT_UNIBALL] = {damage = 25}
RSR.MOBJ_INFO[MT_POINTYBALL] = {damage = 25}
RSR.MOBJ_INFO[MT_DRAGONMINE] = {damage = 65}
RSR.MOBJ_INFO[MT_ROCKET] = {damage = 15}
RSR.MOBJ_INFO[MT_POPSHOT] = {damage = 25}
RSR.MOBJ_INFO[MT_SPINBOBERT_FIRE1] = {damage = 30}
RSR.MOBJ_INFO[MT_SPINBOBERT_FIRE2] = {damage = 30}
RSR.MOBJ_INFO[MT_LASER] = {damage = 30}
RSR.MOBJ_INFO[MT_EGGMOBILE_FIRE] = {damage = 15}
RSR.MOBJ_INFO[MT_GOOP] = {damage = 30}
RSR.MOBJ_INFO[MT_EGGMOBILE2_POGO] = {damage = 45}
RSR.MOBJ_INFO[MT_TORPEDO] = {damage = 35}
RSR.MOBJ_INFO[MT_TORPEDO2] = {damage = 35}
RSR.MOBJ_INFO[MT_EGGMOBILE4_MACE] = {damage = 40}
RSR.MOBJ_INFO[MT_CORK] = {damage = 15}
RSR.MOBJ_INFO[MT_FBOMB] = {damage = 45}
RSR.MOBJ_INFO[MT_ENERGYBALL] = {damage = 45}
RSR.MOBJ_INFO[MT_CYBRAK2016_SLUG] = {damage = 65}
RSR.MOBJ_INFO[MT_CYBRAK2016_SPARK] = {damage = 40}
RSR.MOBJ_INFO[MT_CYBRAK2016_SLASH] = {damage = 15}
RSR.MOBJ_INFO[MT_CYBRAKDEMON_MISSILE] = {damage = 20}
RSR.MOBJ_INFO[MT_CYBRAKDEMON_NAPALM_BOMB_LARGE] = {damage = 20}
RSR.MOBJ_INFO[MT_CYBRAKDEMON_NAPALM_BOMB_SMALL] = {damage = 10}
RSR.MOBJ_INFO[MT_CYBRAKDEMON_NAPALM_FLAMES] = {damage = 5}
RSR.MOBJ_INFO[MT_CYBRAKDEMON_FLAMESHOT] = {damage = 15}
RSR.MOBJ_INFO[MT_CYBRAKDEMON_FLAMEREST] = {damage = 5}
RSR.MOBJ_INFO[MT_CYBRAKDEMON_VILE_EXPLOSION] = {damage = 40}
RSR.MOBJ_INFO[MT_SMALLMACE] = {damage = 10}
RSR.MOBJ_INFO[MT_BIGMACE] = {damage = 20}
RSR.MOBJ_INFO[MT_SMALLFIREBAR] = {damage = 10}
RSR.MOBJ_INFO[MT_BIGFIREBAR] = {damage = 20}
RSR.MOBJ_INFO[MT_SPIKE] = {damage = 10}
RSR.MOBJ_INFO[MT_WALLSPIKE] = {damage = 10}