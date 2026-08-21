
--unfortunately has to be regular hook and not cs hook, if not the icon will not move while not playing as mischa (-500 cool points)
function update_life_icon_anim()
  MISCHA_LIVES_ANIM_TIMER = MISCHA_LIVES_ANIM_TIMER + 1
  if (MISCHA_LIVES_ANIM_TIMER > 2) then
    MISCHA_LIVES_ANIM_TIMER = 0
    MISCHA_LIVES_ANIM = MISCHA_LIVES_ANIM + 1
    if (MISCHA_LIVES_ANIM > 7) then
      MISCHA_LIVES_ANIM = 0
    end
  end
	
	charSelect.character_edit(CT_MISCHA, nil, nil, nil, nil, nil, nil, get_cur_mischa_icon())
	
end

hook_event(HOOK_UPDATE, update_life_icon_anim)

function mischa_update(m)
  e = gMischaStates[0]
  l = gLakituState
  update_variables(m)
	
  if (m.action == ACT_MISCHA_WALK or m.action == ACT_IDLE or m.action == ACT_MISCHA_TORNADO) then 
  interact_w_door(m, e)
  end
	
	if (m.action & ACT_GROUP_MASK) == ACT_GROUP_AIRBORNE and m.controller.buttonDown & Z_TRIG ~= 0 then
		if (m.action == ACT_MISCHA_JUMP and m.actionTimer > 5) or (m.action ~= ACT_MISCHA_JUMP) then
		  local horizVel = math.sqrt(m.vel.x^2 + m.vel.z^2)
	  
			local ledge = collision_find_surface_on_ray(m.pos.x + sins(m.intendedYaw)*(200), m.pos.y + 250, m.pos.z + coss(m.intendedYaw)*(200), 0, -200, 0)
		  
		  if ledge.surface and ledge.surface ~= m.floor and math.abs(m.pos.y - m.floorHeight) > 50 then
				set_mario_action(m, ACT_MISCHA_LEDGE, 0)
			  m.pos.y = ledge.hitPos.y - 75
		  end
		end	
	end
 
 if (m.action & ACT_GROUP_MASK) == ACT_GROUP_MOVING and (math.abs(m.pos.y - m.floorHeight) < 10) then
   local floorace = atan2s(m.floor.normal.z, m.floor.normal.x)
   
   m.vel.x = m.vel.x + (MISCHA_SLOPE_DECEL*(1 - m.floor.normal.y))*sins(floorace)
   m.vel.z = m.vel.z + (MISCHA_SLOPE_DECEL*(1 - m.floor.normal.y))*coss(floorace)
  end
  
  if (m.action == ACT_IDLE and m.controller.buttonDown & A_BUTTON ~= 0) then
    mischa_jump(m)
  end
	
	if m.playerIndex ~= 0 then return end
  
	m.area.camera.yaw = cam.yaw
  
  --fov update
  MISCHA_GOAL_FOV = (math.sqrt(m.vel.x^2 + m.vel.y^2 + m.vel.z^2))
  
  MISCHA_FOV = math.lerp(MISCHA_FOV, math.min(MISCHA_GOAL_FOV, MISCHA_MAX_FOV), 0.1)
  
  --set_override_fov(MISCHA_MIN_FOV + MISCHA_FOV)
  
  --easter egg
  if gNetworkPlayers[0].currLevelNum == 16 and math.random(1, 4000000) == 1 then
    audio_stream_play(SOUND_THEME, false, 0.5)
  end
	
	if m.action ~= ACT_MISCHA_LEDGE then
	  audio_stream_stop(MISCHA_FANFARE)
	end
  
  --He uses custom dialog system, hide vanilla one
  --set_dialog_override_pos(-200, -200)
	
end

function mischa_before_act(m, nextAct)
  MISCHA_COYOTE_TIMER = MISCHA_COYOTE
  
  if (nextAct & ACT_GROUP_AIRBORNE == 0) then
    MISCHA_WALL_SLAPS = 0
  end
  
  if (nextAct == ACT_WALKING) then
    return ACT_MISCHA_WALK
  end
  
  if (nextAct == ACT_JUMP or nextAct == ACT_FREEFALL) then
    if nextAct ~= ACT_FREEFALL then
      mischa_jump(m)
    end
    return ACT_MISCHA_JUMP
  end
  
  if (nextAct == ACT_PUNCHING or nextAct == ACT_MOVE_PUNCHING) then
    return ACT_MISCHA_SLAP
  end
  
  if (nextAct == ACT_MISCHA_LUNGE) then
    camera_config_set_aggression(0)
  end
  
  if (nextAct == ACT_MISCHA_TORNADO or (nextAct == ACT_MISCHA_TORNADO_AIR and m.action ~= ACT_MISCHA_TORNADO)) then
    if (m.action == ACT_MISCHA_TORNADO_AIR) or m.playerIndex ~= 0 then return end
		
    local tornado = spawn_non_sync_object(id_bhvMischaTornado, E_MODEL_DL_WHIRLPOOL, m.pos.x, m.pos.y, m.pos.z, function(o)
      end)
  end
  
  if ((nextAct & ACT_GROUP_MASK) == ACT_GROUP_SUBMERGED) then
	--[[
	  set_sound_bank_override(0x14)
		local seq = get_current_background_music()
		
		fadeout_background_music(seq, 240)
		play_music(SEQ_PLAYER_LEVEL, seq, 240)
		]]
		if (nextAct ~= ACT_MISCHA_SWIM and nextAct ~= ACT_DROWNING) then
      return ACT_MISCHA_SWIM
		end
	else
	--[[
		if (m.action & ACT_GROUP_MASK) == ACT_GROUP_SUBMERGED then
		  set_sound_bank_override(-1)
		  local seq = get_current_background_music()
		
		  fadeout_background_music(seq, 240)
		  play_music(SEQ_PLAYER_LEVEL, seq, 240)
		end
		]]
  end
  
end

function mischa_physics(m, step)
  if (m.playerIndex ~= 0) then return end
  
  --[[
  if (step == STEP_TYPE_AIR) then
   local forwardOffsetZ = 60
    local forwardOffsetX = 60
    
    local rayForward = collision_find_surface_on_ray(m.pos.x, m.pos.y + 35, m.pos.z, forwardOffsetX, 0, forwardOffsetZ)
    local rayFloor = collision_find_surface_on_ray(m.pos.x + sins(m.faceAngle.y) * forwardOffsetX, m.pos.y + 200, m.pos.z + coss(m.faceAngle.y) * forwardOffsetZ, 0, -80, 0)
    
    if (rayForward.surface ~= nil and rayFloor.surface ~= nil ) then
      --djui_chat_message_create(tostring(rayFloor.hitPos.y))
      MISCHA_LEDGE_Y = rayFloor.hitPos.y
      MISCHA_LEDGE_X = rayForward.hitPos.x
      MISCHA_LEDGE_Z = rayForward.hitPos.z
      set_mario_action(m, ACT_MISCHA_LEDGE, 0)
      return AIR_STEP_GRABBED_LEDGE
      end
    
    end
    --]]

end

function on_transition(t)
  if gNetworkPlayers[0] then
    if (t == WARP_TRANSITION_FADE_INTO_CIRCLE or t == WARP_TRANSITION_FADE_INTO_STAR or t == WARP_TRANSITION_FADE_INTO_COLOR) then
      MISCHA_TRANSITION = true
      audio_stream_play(SOUND_WARP, false, 1)
      return false
    end
    
    if (t == WARP_TRANSITION_FADE_FROM_CIRCLE or t == WARP_TRANSITION_FADE_FROM_STAR or t == WARP_TRANSITION_FADE_FROM_COLOR) and MISCHA_TRANSITION == true then
      MISCHA_TRANSITION = false
      return false
    end
	end
end

function on_death(m)
  if m.playerIndex == 0 then
    MISCHA_TRANSITION = true
    audio_stream_play(SOUND_RESTART, false, 1)
    if (m.numLives > 0) then
      m.numLives = m.numLives - 1
      warp_restart_level()
    else
      warp_exit_level(30)
      m.numLives = 4
    end
    m.health = 0x920
    return false
	end
end

scaleX = 1
scaleY = 1

view = {
  x = 0,
  y = 0,
  velX = 1,
  velY = 1
}

function updateGeo()
  posX = math.random(-200, 200)
  posY = math.random(-100, 100)
  
  if get_global_timer() % 100 == 0 then
    intendedSclX = math.random(6, 10)/10
    intendedSclY = math.random(6, 10)/10
  end

    viewport = geo_get_current_root()
    scaleX = math.lerp(scaleX, intendedSclX or 1, 0.1)
    scaleY = math.lerp(scaleY, intendedSclY or 1, 0.1)
    
    view.x = view.x + view.velX
    view.y = view.y + view.velY
    
    if view.x < -75 or view.x > 80 then
      view.velX = view.velX*-1
    end
    
    if view.y < -60 or view.y > 55 then
      view.velY = view.velY*-1
    end
    
    viewport.x = viewport.x + view.x
    viewport.y = viewport.y + view.y
    viewport.width = 320*.25
    viewport.height = 240*.25
end

function mischa_hud()
  m = gMarioStates[0]
  djui_hud_set_resolution(RESOLUTION_N64)
  
  
  
  
  DIALOG_MARGIN_LEFT = djui_hud_get_screen_width()/2 - djui_hud_get_screen_width()/3
  DIALOG_WIDTH = djui_hud_get_screen_width()*(2/3)
  --[[
  if (not is_game_paused() and get_dialog_box_state() ~= 0 and MISCHA_DIALOG ~= true) then
    MISCHA_DIALOG = true
    curDialog = get_dialog_id()
    local txt = smlua_text_utils_dialog_get(curDialog).text or ""
    
    DIALOG_TEXT = txt
    DIALOG_GOAL = #txt
    DIALOG_CUR = 1
    
    curPos = gLakituState.pos
    curFocus = gLakituState.focus
    DIALOGUE_OFFSET = 192
  end
	]]
  
  if (MISCHA_TRANSITION == true) then
    MISCHA_TRANSITION_CURTAIN_SCALE = lerp(MISCHA_TRANSITION_CURTAIN_SCALE, 1.25, .075)
  
  else
    MISCHA_TRANSITION_CURTAIN_SCALE = lerp(MISCHA_TRANSITION_CURTAIN_SCALE, 0, .075)
  end
  
  render_mischa_hud()
  
  djui_hud_render_texture(TEX_CURTAIN, 0, -5, 2.05, MISCHA_TRANSITION_CURTAIN_SCALE*2)
  
  if (cam.pos.y < m.waterLevel and charSelect.get_options_status(MISCHA_KOFECAM) == 1) then
    djui_hud_set_color(32, 32, 192, 92)
    djui_hud_render_rect(-20, -20, djui_hud_get_screen_width() + 40, djui_hud_get_screen_height() + 40)
    djui_hud_reset_color()
  end
  
  if (MISCHA_DIALOG == true) then
    set_mario_action(m, ACT_READING_NPC_DIALOG, 0)
    set_mario_animation(m, CHAR_ANIM_IDLE_HEAD_CENTER)
    camera_freeze()
    
    intendedPos = {
      x = m.pos.x - 400*sins(m.faceAngle.y - 0x2000),
      y = m.pos.y + 300,
      z = m.pos.z - 400*coss(m.faceAngle.y - 0x2000),
    }
    
    intendedFocus = {
      x = m.pos.x + 250*sins(m.faceAngle.y),
      y = m.pos.y,
      z = m.pos.z + 250*coss(m.faceAngle.y),
    }
    
    curPos = {
      x = lerp(curPos.x, intendedPos.x, .1),
      y = lerp(curPos.y, intendedPos.y, .1),
      z = lerp(curPos.z, intendedPos.z, .1)
    }
    
    curFocus = {
      x = lerp(curFocus.x, intendedFocus.x, .1),
      y = lerp(curFocus.y, intendedFocus.y, .1),
      z = lerp(curFocus.z, intendedFocus.z, .1)
    }
    
    vec3f_copy(gLakituState.focus, curFocus)
    vec3f_copy(gLakituState.pos, curPos)
    
    DIALOGUE_OFFSET = lerp(DIALOGUE_OFFSET, 0, .1)
    
    DIALOG_TIMER = DIALOG_TIMER - 1
    
    if m.controller.buttonDown & Z_TRIG ~= 0 then
      DIALOG_TIMER = DIALOG_TIMER + 1
    end
    
    if (DIALOG_TIMER < 1 and DIALOG_CUR <= DIALOG_GOAL) then
      local curLetter = string.sub(DIALOG_TEXT, DIALOG_CUR, DIALOG_CUR)
      local debounce = 1
      local skip = 0
      
      if curLetter == "!" or curLetter == "." or curLetter == "," or curLetter == "?" then
        debounce = 15
      end
      
      if m.controller.buttonDown & A_BUTTON ~= 0 then
        skip = 2
        debounce = debounce/2
      end
      
      DIALOG_TIMER = debounce
      
      DIALOG_CUR = DIALOG_CUR + 1 + skip
      play_sound_with_freq_scale(SOUND_MENU_MESSAGE_APPEAR, m.marioObj.header.gfx.cameraToObject, math.random(3, 10)/5 + skip/2)
      
    end
    
    local visText = string.sub(DIALOG_TEXT, 0, DIALOG_CUR)
    
    local textBox = string_to_lines(visText, djui_hud_get_screen_width()*1.5)
    
    djui_hud_set_color(64, 64, 64, 128)
    
    djui_hud_render_rect(DIALOG_MARGIN_LEFT, djui_hud_get_screen_height()*(2/3) - 32 + DIALOGUE_OFFSET, DIALOG_WIDTH, djui_hud_get_screen_height()/3 + 16)
    djui_hud_reset_color()
    djui_hud_set_font(FONT_ALIASED)
    
    for i, v in pairs(textBox) do
      local transparency = math.max(-6*(#textBox - i + 1)^2 + 255, 0)
      
      djui_hud_set_color(255, 255, 255, transparency)
      djui_hud_print_text(v, djui_hud_get_screen_width()/2 - (djui_hud_measure_text(v)*.5)/2, djui_hud_get_screen_height()*(2/3) + 12 + 12*i - 8*#textBox + DIALOGUE_OFFSET, .5)
      djui_hud_reset_color()
    end
    
    djui_hud_print_text("[Message Panel]", DIALOG_MARGIN_LEFT + 8, djui_hud_get_screen_height()*(2/3) - 32 + DIALOGUE_OFFSET, .6)
    
    djui_hud_print_text("[Z]II / [A]>>", DIALOG_MARGIN_LEFT + DIALOG_WIDTH - djui_hud_measure_text("[Z]II / [A]>>")*.35 - 8, djui_hud_get_screen_height() - 30 + DIALOGUE_OFFSET, .35)
    
    if (DIALOG_CUR >= DIALOG_GOAL) then
      if (get_global_timer() % 30 < 15) then
      djui_hud_print_text("[B]->", DIALOG_MARGIN_LEFT + 8, djui_hud_get_screen_height() - 30 + DIALOGUE_OFFSET, .35)
      end
      
      if m.controller.buttonPressed & B_BUTTON ~= 0 or m.controller.buttonPressed & A_BUTTON ~= 0 then
        MISCHA_DIALOG = false
        handle_special_dialog_text(curDialog)
        set_mario_action(m, ACT_IDLE, 0)
        reset_dialog_render_state()
        camera_unfreeze()
        disable_time_stop()
      end
    end
    
  end
  
end

function on_mischa_select(charID)
  if (charSelect.character_get_current_number() ~= CT_MISCHA) then
    reset_dialog_override_pos()
    texture_override_reset("texture_font_aliased")
    hud_show()
  else
    texture_override_set("texture_font_aliased", get_texture_info("font-red-guy"))
    hud_hide()
  end
  
end

function mischa_on_start()
  texture_override_set("texture_font_aliased", get_texture_info("font-red-guy"))
    hud_hide()
end

function mischa_warp()
  MISCHA_PREV_WALL = nil
	GRABBED_OBJ.o = {}
  
end

function mischa_dialog(id)
  local txt = smlua_text_utils_dialog_get(id).text or ""
    DIALOG_TEXT = txt
    DIALOG_GOAL = #txt
    DIALOG_CUR = 1
    curPos = gLakituState.pos
    curFocus = gLakituState.focus
    curDialog = id
    DIALOGUE_OFFSET = 192
    MISCHA_DIALOG = true
		obj = get_dialog_object()
		
		obj.oDialogResponse = 1
		obj.oDialogState = 1
		
end

function playmode(playMode)
  if gNetworkPlayers[0].currLevelNum ~= 6 then
  return 6
  end
end

cheats = {
  [1] = "MASHINA",
	[2] = "SAKHAR",
	[3] = "SPUTNIK"
}

function mischa_cheatcodes(m, msg)
  msg = string.upper(msg)
	
	if m.playerIndex == 0 then
	
	  if (msg == "MASHINA") then
		  djui_popup_create("Cheat Code of Mischa: \nKart.", 2)
			set_mario_action(m, ACT_MISCHA_KART, 0)
	  end
		
		if (msg == "SAKHAR") then
		  djui_popup_create("Cheat Code of Mischa: \nSugar Rush", 2)
		  spawn_non_sync_object(id_bhvMario, E_MODEL_NONE, m.pos.x, m.pos.y, m.pos.z, function(o) o.oBehParams = m.marioObj.oBehParams end)
		end
		
		if (msg == "SPUTNIK") then
		
			if (MISCHA_GRAVITY > 2) then
			  djui_popup_create("Cheat Code of Mischa: \nMoon Gravity", 2)
			  MISCHA_GRAVITY = 1
			else
			  djui_popup_create("Cheat Code of Mischa: \nEarth Gravity", 2)
			  MISCHA_GRAVITY = 2.5
			end
			
		end
		
	end
	
	for i, v in pairs(cheats) do
	  if v == msg then return false end
	end
	
end

function mischa_interact(m, o, intType)
  if intType & INTERACT_GRABBABLE ~= 0 then
    if m.action == ACT_MISCHA_SLAP then
      o.oFaceAngleYaw = obj_angle_to_object(o, m.marioObj) + 0x8000
      o.oMoveAngleYaw = obj_angle_to_object(o, m.marioObj) + 0x8000
      o.oPosY = m.pos.y + 50
      o.oVelY = 35
      o.oForwardVel = 25
      m.forwardVel = -65
      if obj_has_behavior_id(o, id_bhvKingBobomb) ~= 0 or obj_has_behavior_id(o, id_bhvChuckya) ~= 0 or obj_has_behavior_id(o, id_bhvPenguinBaby) ~= 0 then
        o.oAction = 4
      elseif obj_has_behavior_id(o, id_bhvBowser) ~= 0 and o.oAction ~= 1 then
        o.oAction = 1
        o.oForwardVel = 65
      end
      
      if obj_has_behavior_id(o, id_bhvMips) ~= 0 then
        m.input = m.input | INPUT_INTERACT_OBJ_GRABBABLE
        if o.oSyncID ~= 0 then
              network_send_object(o, true)
        end
      end
			
    end
     end
end

function mischa_metalcap(m)

  if (m.flags & MARIO_METAL_CAP ~= 0) then
	  m.vel.x = approach_f32(m.vel.x, 0, .5, .5)
		m.vel.y = approach_f32(m.vel.y, 0, .5, .5)
		m.vel.z = approach_f32(m.vel.z, 0, .5, .5)
		
		return false
	end

end

function coyote_time_protect(m, class)
  
	if (m.action & ACT_GROUP_MASK) == ACT_GROUP_MOVING and MISCHA_COYOTE_TIMER > 0 then
	  return SURFACE_DEFAULT
	end

end

function moveset_mischa()
  charSelect.character_hook_moveset(CT_MISCHA, HOOK_MARIO_UPDATE, mischa_update)
  charSelect.character_hook_moveset(CT_MISCHA, HOOK_BEFORE_SET_MARIO_ACTION, mischa_before_act)
	charSelect.character_hook_moveset(CT_MISCHA, HOOK_ON_INTERACT, mischa_interact)
  charSelect.character_hook_moveset(CT_MISCHA, HOOK_BEFORE_PHYS_STEP, mischa_physics)
  charSelect.character_hook_moveset(CT_MISCHA, HOOK_UPDATE, updateCam)
  --charSelect.character_hook_moveset(CT_MISCHA, HOOK_ON_SCREEN_TRANSITION, on_transition)
  charSelect.character_hook_moveset(CT_MISCHA, HOOK_ON_HUD_RENDER_BEHIND, mischa_hud)
  charSelect.hook_on_character_change(on_mischa_select)
  charSelect.character_hook_moveset(CT_MISCHA, HOOK_ON_WARP, mischa_warp)
  --charSelect.character_hook_moveset(CT_MISCHA, HOOK_ON_DEATH, on_death)
  --charSelect.character_hook_moveset(CT_MISCHA, HOOK_ON_DIALOG, mischa_dialog)
	charSelect.character_hook_moveset(CT_MISCHA, HOOK_ON_CHAT_MESSAGE, mischa_cheatcodes)
	charSelect.character_hook_moveset(CT_MISCHA, HOOK_ALLOW_FORCE_WATER_ACTION, mischa_metalcap)
 -- charSelect.character_hook_moveset(CT_MISCHA, HOOK_ON_MODS_LOADED, mischa_on_start)
 -- charSelect.character_hook_moveset(CT_MISCHA, HOOK_ON_PLAY_MODE_UPDATE, playmode)
  --hook_event(HOOK_ON_GEO_PROCESS, updateGeo)
	charSelect.character_hook_moveset(CT_MISCHA, HOOK_MARIO_OVERRIDE_FLOOR_CLASS, coyote_time_protect)
	
	end