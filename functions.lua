lerp = math.lerp

function update_turning(m, spd)
m.faceAngle.y = approach_s16_asymptotic(m.faceAngle.y, m.intendedYaw, spd)
end

--[[
function angle_diff(a, b)
  local diff = a - b
  if diff > 32767 then
    diff = diff - 65536
  elseif diff < -32768 then
    diff = diff + 65536
  end
  return diff
end
]]

function angle_diff(a, b)
    local d = (a - b) & 0xFFFF
    if d >= 0x8000 then
        d = d - 0x10000
    end
    return d
end

function interact_w_door(m, e)
  
    local wdoor = obj_get_nearest_object_with_behavior_id(m.marioObj, id_bhvDoorWarp)
    local door = obj_get_nearest_object_with_behavior_id(m.marioObj, id_bhvDoor)
    local sdoor = obj_get_nearest_object_with_behavior_id(m.marioObj, id_bhvStarDoor)

    if door ~= nil and dist_between_objects(m.marioObj, door) < 200 and m.numStars >= door.oBehParams >> 24 then
        interact_door(m, 0, door)
        --djui_chat_message_create("door.")
        if door.oAction == 0 then
            if (should_push_or_pull_door(m, door) & 1) ~= 0 then
                door.oInteractStatus = 0x00010000
                doorAngle = door.oFaceAngleYaw
            doorposX = door.oPosX + sins(door.oFaceAngleYaw)*20
            doorposZ = door.oPosZ + coss(door.oFaceAngleYaw)*20
            else
                door.oInteractStatus = 0x00020000
                doorAngle = door.oFaceAngleYaw + 0x8000
                doorposX = door.oPosX + sins(door.oFaceAngleYaw)*-20
            doorposZ = door.oPosZ + coss(door.oFaceAngleYaw)*-20
            end
          set_mario_action(m, ACT_MISCHA_DOOR, 0)
        end
    elseif sdoor ~= nil and dist_between_objects(m.marioObj, sdoor) < 400 then
      if m.numStars >= sdoor.oBehParams >> 24 then
        interact_door(m, 0, sdoor)
        --djui_chat_message_create("star door.")
        if sdoor.oAction == 0 then
            if (should_push_or_pull_door(m, sdoor) & 1) ~= 0 then
                sdoor.oInteractStatus = 0x00010000
            else
                sdoor.oInteractStatus = 0x00020000
            end
            doorAngle = m.faceAngle.y
        end
          else
            set_mario_action(m, ACT_DECELERATING, 0)
        end
    elseif wdoor ~= nil and dist_between_objects(m.marioObj, wdoor) < 150 then
        interact_warp_door(m, 0, wdoor)
        set_mario_action(m, ACT_DECELERATING, 0)
        --djui_chat_message_create("warp door.")
    end
    
  e.doorInteract.angle = doorAngle
  e.doorInteract.x = doorposX
  e.doorInteract.z = doorposZ
end

function mischa_gravity(m)
  
  if (m.vel.y > MISCHA_TERMINAL_VEL) then
  m.vel.y = m.vel.y - MISCHA_GRAVITY
  end
  
end

function mischa_jump(m)
  local jumpAdd = (MISCHA_MOVEMENT.y > 0) and (MISCHA_MOVEMENT.y) or 0 
  
      m.particleFlags = m.particleFlags | PARTICLE_MIST_CIRCLE
      play_sound(SOUND_GENERAL_SWISH_AIR, m.marioObj.header.gfx.cameraToObject)
      m.vel.y = MISCHA_JUMP_HEIGHT + jumpAdd
      set_mario_action(m, ACT_MISCHA_JUMP, 0) 
end

function mischa_lunge(m)
  m.particleFlags = m.particleFlags | PARTICLE_VERTICAL_STAR
  play_sound(SOUND_GENERAL_BOING2, m.marioObj.header.gfx.cameraToObject)
    mario_set_forward_vel(m, MISCHA_FORWARD_LUNGE_VEL + (math.abs(m.vel.y)/10))
    m.vel.y = MISCHA_JUMP_HEIGHT/2
    set_mario_action(m, ACT_MISCHA_LUNGE, 0)
end

function mischa_bonk(m)
  cur_obj_shake_screen(SHAKE_POS_MEDIUM)
  spawn_triangle_break_particles(16, 138, 3, 4)
  audio_sample_play(SOUND_BONK, m.pos, 1)
  set_mario_action(m, ACT_MISCHA_BONK, 0)
end

function string_to_lines(str, length)
  local line = ""
  local result = {}

  for word in string.gmatch(str, "%S+") do
    local testLine = line .. word .. " "
      if djui_hud_measure_text(testLine) > length or word:find("/n") then
          if line ~= "" then
            table.insert(result, line)
          end
          if word:find("/n") == 1 then
            word = string.sub(word, 3)
          end
          
          line = (word ~= "/n" and word.." " or " ")
      else
          line = testLine
      end
  end
  if line ~= "" then
      table.insert(result, line)
  end

  return result
end

function obj_is_not_tornado_grabbed(o)
  
  for i = 1, MISCHA_GRAB_MAX_OBJECTS do
    if (o == GRABBED_OBJ.o[i]) then
      return false
    end
  end
  
  return true
end

function render_mischa_hud()
  m = gMarioStates[0]
  vis = hud_get_value(HUD_DISPLAY_FLAGS)
  djui_hud_set_font(FONT_ALIASED)
  hud_hide()
  
  if (vis & HUD_DISPLAY_FLAG_POWER ~= 0) then
    
    mischaUI.power.pos.x = 38
    mischaUI.power.pos.y = 32
    
    djui_hud_set_rotation(sins(get_global_timer()*500)*0x500, 0.5, 0.5)
    djui_hud_render_texture_tile(TEX_MISCHA_UI, mischaUI.power.pos.x*MISCHA_UI_SCALE, mischaUI.power.pos.y*MISCHA_UI_SCALE, MISCHA_UI_SCALE, MISCHA_UI_SCALE, 0, 0, 64, 64)
    djui_hud_set_rotation(0, 0, 0)
    
    for i = 0x110, m.health, 0x110 do
      local angle = 0x2000*(i/0x110) + get_global_timer()*250
      local out = 64*MISCHA_UI_SCALE
      local pos = {
        x = sins(angle)*out,
        y = coss(angle)*out
      }
      djui_hud_render_texture_tile(TEX_MISCHA_UI, (16 + mischaUI.power.pos.x + pos.x)*MISCHA_UI_SCALE, (16 + mischaUI.power.pos.y + pos.y)*MISCHA_UI_SCALE, MISCHA_UI_SCALE, MISCHA_UI_SCALE, 64, 0, 32, 32)
      
    end
  end
  
  if (vis & HUD_DISPLAY_FLAG_COIN_COUNT ~= 0) then
	
	  local boings = math.min(m.numCoins, 130)
    
    mischaUI.kofe.pos.x = djui_hud_get_screen_width() - 48
    mischaUI.kofe.pos.y = 48
    
    --djui_hud_render_rect(mischaUI.kofe.pos.x, mischaUI.kofe.pos.y - 40*(math.min(m.numCoins/100, 1)), 40, 40*(math.min(m.numCoins/100, 1)))
		djui_hud_render_texture_tile(TEX_MISCHA_UI, mischaUI.kofe.pos.x - 13, mischaUI.kofe.pos.y - 26*(boings/90), MISCHA_UI_SCALE*1.15, MISCHA_UI_SCALE*1.15, 128, 192 - 32*(boings/90), 64, 64)
    djui_hud_render_texture_tile(TEX_MISCHA_UI, mischaUI.kofe.pos.x - 13, mischaUI.kofe.pos.y - 43, MISCHA_UI_SCALE*1.15, MISCHA_UI_SCALE*1.15, 64, 128, 64, 64)
    djui_hud_print_text(tostring(m.numCoins), mischaUI.kofe.pos.x + 8 - (djui_hud_measure_text(tostring(m.numCoins))*.5)/2, mischaUI.kofe.pos.y - 24, .5)
  end
  
  if (vis & HUD_DISPLAY_FLAGS_LIVES ~= 0) then
    
    mischaUI.lives.pos.x = djui_hud_get_screen_width() - 84
    mischaUI.lives.pos.y = djui_hud_get_screen_height() - 42
    
    djui_hud_render_texture_tile(TEX_MISCHA_UI, mischaUI.lives.pos.x, mischaUI.lives.pos.y , MISCHA_UI_SCALE, MISCHA_UI_SCALE, 224, 32*MISCHA_LIVES_ANIM, 32, 32)
    djui_hud_set_color(0, 0, 0, 255)
    djui_hud_print_text(tostring("x "..m.numLives), mischaUI.lives.pos.x + 29, mischaUI.lives.pos.y - 5.5, .95)
    djui_hud_reset_color()
    djui_hud_print_text(tostring("x "..m.numLives), mischaUI.lives.pos.x + 30, mischaUI.lives.pos.y - 4, .85)
    
  end
	
	if m.action == ACT_MISCHA_KART then
	  local milesDriven = sm64units_to_miles(MISCHA_KART_DIST_DRIVEN)
	  djui_hud_set_color(0, 0, 0, 255)
    djui_hud_print_text("Miles: "..string.format("%0.2f", milesDriven), 15, djui_hud_get_screen_height() - 31, .56)
		djui_hud_reset_color()
		djui_hud_print_text("Miles: "..string.format("%0.2f", milesDriven), 16, djui_hud_get_screen_height() - 32, .55)
	
	end
  
end

function double_tap(controller, button)
  if (CUR_PRESSED_DEBOUNCE == 0 and CUR_PRESSED[button] and (controller.buttonPressed & button ~= 0) and CUR_PRESSED[button] > 0) then
    return 1
  else
    return 0
  end
end

function sm64units_to_miles(units)
  local meters = units/100
	local miles = meters*0.000621371
  return miles
end

function get_cur_mischa_icon()
	local icon = get_texture_info("mischa-icon"..MISCHA_LIVES_ANIM)
	return icon
end