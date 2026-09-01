-- name: [CS] Mischa Kofe
-- description: KOFE BREAK!!!! Straight from 1998, Mischa Kofe is a character from the N64 Arcade-Platformer game "Kofe Break 64" which is about brewing as much coffee as possible under a time limit. His moveset is built from the ground up, which gives his moveset a more unique experience.

function on_char_select_load()
  
CT_MISCHA = charSelect.character_add(
        "Mischa Kofe",
        {'KOFE BREAK!!!!'},
        "Kristall",
        "aa0000", 
        E_MODEL_MISCHA,
        CT_MARIO, 
        nil,
        1.5
    )
    
    anims_mischa = {
    [CHAR_ANIM_IDLE_HEAD_LEFT] = 'mischa_idle',
    [CHAR_ANIM_IDLE_HEAD_RIGHT] = 'mischa_idle',
    [CHAR_ANIM_IDLE_HEAD_CENTER] = 'mischa_idle',
		[MISCHA_ANIM_IDLE] = "mischa_idle",
    [MISCHA_ANIM_SLAP_IDLE] = "mischa_slapidle",
    [MISCHA_ANIM_SLAP_MOVE] = "mischa_slapmove",
    [MISCHA_ANIM_TORNADO] = "mischa_spin",
    [MISCHA_ANIM_KAZOTSKY] = "mischa_kazotsky",
    [MISCHA_ANIM_RUN] = "mischa-walk",
		[MISCHA_ANIM_SLAP_POUND] = "mischa-slap-pound",
		[0xD2] = "mischa_kazotsky"
  }
  
local PALETTE_MISCHA = {
  	[PANTS] = "b3b3b3", 
  	[SHIRT] = "f73c2c", 
  	[GLOVES] = "ffffff", 
  	[SHOES] = "522f19", 
  	[HAIR] = "321e1e", 
  	[SKIN] = "ffdca8", 
  	[CAP] = "f73c2c", 
  	[EMBLEM] = "1c1c1c"
}
charSelect.character_add_palette_preset(E_MODEL_MISCHA, PALETTE_MISCHA, "Attire of Grace")

local PALETTE_BLUE_ALLIANCE = {
  	[PANTS] = "3a3334", 
  	[SHIRT] = "4848ff", 
  	[GLOVES] = "afafaf", 
  	[SHOES] = "2b3ba2", 
  	[HAIR] = "ffd959", 
  	[SKIN] = "ffc796", 
  	[CAP] = "4848ff", 
  	[EMBLEM] = "ffe539"
}
charSelect.character_add_palette_preset(E_MODEL_MISCHA, PALETTE_BLUE_ALLIANCE, "Blue Alliance")

local PALETTE_DESTINY_FOREST = {
  	[PANTS] = "13101e", 
  	[SHIRT] = "85bd81", 
  	[GLOVES] = "d2cabd", 
  	[SHOES] = "729750", 
  	[HAIR] = "790613", 
  	[SKIN] = "ffb284", 
  	[CAP] = "85bd81", 
  	[EMBLEM] = "780c28"
}
charSelect.character_add_palette_preset(E_MODEL_MISCHA, PALETTE_DESTINY_FOREST, "Destiny Forest")

local PALETTE_EASTERN_CAVERNS = {
  	[PANTS] = "33394d", 
  	[SHIRT] = "4d1677", 
  	[GLOVES] = "916cca", 
  	[SHOES] = "271c45", 
  	[HAIR] = "090c09", 
  	[SKIN] = "ffdca8", 
  	[CAP] = "390e52", 
  	[EMBLEM] = "2e1f42"
}
charSelect.character_add_palette_preset(E_MODEL_MISCHA, PALETTE_EASTERN_CAVERNS, "Eastern Caverns")

local PALETTE_FRIENDLY_COLLEAGUE = {
  	[PANTS] = "ff44ff", 
  	[SHIRT] = "930090", 
  	[GLOVES] = "ff99ff", 
  	[SHOES] = "aa2c66", 
  	[HAIR] = "f365da", 
  	[SKIN] = "ffdbbf", 
  	[CAP] = "930090", 
  	[EMBLEM] = "812b8b"
}
charSelect.character_add_palette_preset(E_MODEL_MISCHA, PALETTE_FRIENDLY_COLLEAGUE, "Friendly Colleague")

charSelect.character_add_animations(E_MODEL_MISCHA, anims_mischa)
    
    voice_mischa = {
      [SOUND_ACTION_READ_SIGN] = SOUND_BOUNCE_WALL
      
    }
    
    charSelect.character_add_voice(E_MODEL_MISCHA, voice_mischa)
    
    MISCHA_KOFECAM = charSelect.add_option("Camera of Mischa Kofe", 0, 1, {"Vanilla Cam", "Kofe Kamepa"}, true)
    
    charSelect.character_add_texture_replacement(CT_MISCHA, "texture_font_aliased", get_texture_info("font-red-guy"))
    
		--charSelect.character_add_menu_instrumental(CT_MISCHA, SOUND_THEME)
		
    moveset_mischa()
    
end

hook_event(HOOK_ON_MODS_LOADED, on_char_select_load)