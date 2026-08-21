-- name: [CS] Mischa Kofe
-- description: KOFE BREAK!!!! Straight from 1998, Mischa Kofe is a character from the N64 Arcade-Platformer game "Kofe Break 64" which is about brewing as much coffee as possible under a time limit. His moveset is built from the ground up, which gives his moveset a more unique experience.

function on_char_select_load()
  
CT_MISCHA = charSelect.character_add(
        "Mischa Kofe",
        {'KOFE BREAK!!!! Straight from 1998, Mischa Kofe is a character from the N64 Arcade-Platformer game "Kofe Break 64" which is about brewing as much coffee as possible under a time limit. His moveset is built from the ground up, which gives his moveset a more unique experience.'},
        "Kristall",
        "ff0000", 
        E_MODEL_MISCHA,
        CT_MARIO, 
        nil,
        0.9
    )
    
    anims_mischa = {
    [CHAR_ANIM_IDLE_HEAD_LEFT] = 'mischa_idle',
    [CHAR_ANIM_IDLE_HEAD_RIGHT] = 'mischa_idle',
    [CHAR_ANIM_IDLE_HEAD_CENTER] = 'mischa_idle',
    [CHAR_ANIM_FIRST_PUNCH] = "mischa_slapidle",
    [CHAR_ANIM_SECOND_PUNCH] = "mischa_slapmove",
    [CHAR_ANIM_START_TWIRL] = "mischa_spin",
    [CHAR_ANIM_BREAKDANCE] = "mischa_kazotsky",
    [CHAR_ANIM_RUNNING] = "mischa-walk",
		[CHAR_ANIM_START_GROUND_POUND] = "mischa-slap-pound"
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
charSelect.character_add_palette_preset(E_MODEL_MISCHA, PALETTE_MISCHA, "Mischa")

local PALETTE_PURPLE = {
  	[PANTS] = "33394d", 
  	[SHIRT] = "9975d4", 
  	[GLOVES] = "9975d4", 
  	[SHOES] = "271c45", 
  	[HAIR] = "090c09", 
  	[SKIN] = "ffdca8", 
  	[CAP] = "390e52", 
  	[EMBLEM] = "916cca"
}
--charSelect.character_add_palette_preset(E_MODEL_MISCHA, PALETTE_PURPLE, "a")

local PALETTE_LUKYAN = {
  	[PANTS] = "586359", 
  	[SHIRT] = "3cf32c", 
  	[GLOVES] = "ffffff", 
  	[SHOES] = "528119", 
  	[HAIR] = "000000", 
  	[SKIN] = "ffdecc", 
  	[CAP] = "3cf72c", 
  	[EMBLEM] = "1c1c1c"
}
charSelect.character_add_palette_preset(E_MODEL_MISCHA, PALETTE_LUKYAN, "Lukyan")
  
local PALETTE_KINDNESS = {
 	  [PANTS] = "ff44ff", 
  	[SHIRT] = "930090", 
  	[GLOVES] = "ff99ff", 
  	[SHOES] = "aa2c66", 
  	[HAIR] = "f365da", 
  	[SKIN] = "c86b9d", 
  	[CAP] = "ef2bea", 
  	[EMBLEM] = "ef2bea"
}
charSelect.character_add_palette_preset(E_MODEL_MISCHA, PALETTE_KINDNESS, "Kind")

charSelect.character_add_animations(E_MODEL_MISCHA, anims_mischa)
    
    voice_mischa = {
      [SOUND_ACTION_READ_SIGN] = SOUND_BOUNCE_WALL
      
    }
    
    charSelect.character_add_voice(E_MODEL_MISCHA, voice_mischa)
    
    MISCHA_KOFECAM = charSelect.add_option("Camera of Mischa Kofe", 0, 1, {"Vanilla Cam", "Kofe Kamepa"}, true)
    
    charSelect.character_add_texture_replacement(CT_MISCHA, "texture_font_aliased", get_texture_info("font-red-guy"))
    
    moveset_mischa()
    
end

hook_event(HOOK_ON_MODS_LOADED, on_char_select_load)