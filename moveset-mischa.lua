_G.ACT_MISCHA_WALK = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_MOVING)

function act_mischa_walk(m)
  
  local step = perform_ground_step(m)
  m.vel.y = 0
  
  m.actionState = m.actionState + 1
  
  local bouncy = sins(m.actionState*(3800))
  
  m.marioObj.header.gfx.pos.y = m.pos.y + math.abs(bouncy)*(65) - 25
  
  if step == GROUND_STEP_LEFT_GROUND then
    MISCHA_COYOTE_TIMER = MISCHA_COYOTE_TIMER - 1
    perform_air_step(m, 0)
    if MISCHA_COYOTE_TIMER < 1 then
      m.vel.y = 0
      set_mario_action(m, ACT_MISCHA_JUMP, 0)
    end
  elseif step == GROUND_STEP_NONE then
    if m.heldObj ~= nil then
      set_mario_anim_with_accel(m, CHAR_ANIM_WALK_WITH_LIGHT_OBJ, m.forwardVel * 0x3000)
            if m.controller.buttonPressed & B_BUTTON ~= 0 then
            set_mario_action(m, ACT_THROWING, 0)
            elseif m.controller.buttonPressed & Z_TRIG ~= 0 then
              mario_throw_held_object(m)
              end
            else
                set_mario_anim_with_accel(m, MISCHA_ANIM_RUN, 0x25000)
    end
    
  elseif step == GROUND_STEP_HIT_WALL then
    mario_set_forward_vel(m, approach_s32(m.forwardVel, 0, 5, 5))
  end
  
  if m.controller.buttonDown & A_BUTTON ~= 0 and m.actionTimer == 0 then
    m.vel.x = m.vel.x + sins(m.floorAngle) * (50*(1-(m.floor.normal.y)))
    m.vel.z = m.vel.z + coss(m.floorAngle) * (50*(1-(m.floor.normal.y)))
    mischa_jump(m)
  elseif m.controller.buttonDown & B_BUTTON ~= 0 and m.actionTimer == 0 then
    set_mario_action(m, ACT_MISCHA_SLAP, 0)
    elseif (m.controller.buttonDown & Z_TRIG ~= 0) then
      if m.heldObj ~= nil then
        m.heldObj.oForwardVel = 55
        m.heldObj.oVelY = 35
        m.heldObj.oPosY = m.pos.y + 50
              mario_throw_held_object(m)
      end
      if (m.actionTimer == 0) then
      set_mario_action(m, ACT_MISCHA_TORNADO, 0)
      m.actionTimer = m.forwardVel*3
      end
    end
  
      if (m.input & INPUT_ZERO_MOVEMENT) ~= 0 then

        if math.abs(m.forwardVel) < 2 then
            if m.heldObj ~= nil then
                return set_mario_action(m, ACT_HOLD_IDLE, 0)
            else
                return set_mario_action(m, ACT_IDLE, 0)
            end
        end
      end
  
  local intended_spd = MISCHA_TOP_SPEED*CONTROL_STICK_MAG
  
  m.actionTimer = approach_s32(m.actionTimer, 0, 1, 1)
  
  
  local intended_x = sins(m.intendedYaw) * intended_spd
  local intended_z = coss(m.intendedYaw) * intended_spd
  
  m.vel.x = lerp(m.vel.x, intended_x, MISCHA_ACCEL_SLEERP)
  m.vel.z = lerp(m.vel.z, intended_z, MISCHA_ACCEL_SLEERP)
  
  m.forwardVel = math.sqrt(m.vel.x^2 + m.vel.z^2)
  
  m.marioObj.header.gfx.angle.z = m.floor.normal.z + approach_s16_asymptotic(m.marioObj.header.gfx.angle.z, CONTROL_TURN_DIFF, MISCHA_TILT_SPEED)
  
  m.marioObj.header.gfx.angle.x = m.floor.normal.x
  
  if (m.forwardVel < 20 and intended_spd > 30) then
    m.particleFlags = m.particleFlags | PARTICLE_DUST
  end
  
  if (math.abs(CONTROL_TURN_DIFF) > 0x2000) then
    play_sound(SOUND_MOVING_SLIDE_DOWN_POLE, m.pos)
  end
  
      update_turning(m, 2)
  
end

hook_mario_action(ACT_MISCHA_WALK, act_mischa_walk)

_G.ACT_MISCHA_JUMP = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR)

function act_mischa_jump(m)
  local step = perform_air_step(m, 1)
  m.faceAngle.y = approach_s16_asymptotic(m.faceAngle.y, m.intendedYaw, 4)
  
  local intended_spd = (MISCHA_TOP_SPEED*MISCHA_AIR_DECEL)*CONTROL_STICK_MAG
  
  local intended_x = sins(m.intendedYaw) * intended_spd
  local intended_z = coss(m.intendedYaw) * intended_spd
  
  m.vel.x = lerp(m.vel.x, intended_x, MISCHA_ACCEL_SLEERP)
  m.vel.z = lerp(m.vel.z, intended_z, MISCHA_ACCEL_SLEERP)
  
  if m.vel.y < -150 and m.actionArg ~= 2 then
      m.actionArg = 2
    end
  
  if m.actionArg ~= 2 then
  
  if (step == AIR_STEP_LANDED) then
    set_mario_action(m, ACT_MISCHA_WALK, 0)
    m.actionTimer = 2
    return
  end
  
  m.marioObj.header.gfx.angle.z = approach_s16_asymptotic(m.marioObj.header.gfx.angle.z, CONTROL_TURN_DIFF, MISCHA_TILT_SPEED)
  
  if m.vel.y > 0 then
  set_mario_animation(m, CHAR_ANIM_DOUBLE_JUMP_RISE)
  else
   set_mario_animation(m, CHAR_ANIM_DOUBLE_JUMP_FALL) 
  end
  
  else
    set_mario_anim_with_accel(m, CHAR_ANIM_AIRBORNE_ON_STOMACH, 0x20000)
    
    if (step == AIR_STEP_LANDED) then
      m.particleFlags = m.particleFlags | PARTICLE_MIST_CIRCLE | PARTICLE_HORIZONTAL_STAR
      cur_obj_shake_screen(SHAKE_POS_LARGE)
      play_sound(SOUND_GENERAL2_BOBOMB_EXPLOSION, m.pos)
  return set_mario_action(m, ACT_HEAD_STUCK_IN_GROUND, 0)
  end
  end
  
  if (m.controller.buttonPressed & A_BUTTON ~= 0 and m.actionArg == 0 and m.actionTimer > 1) then
    mischa_lunge(m)
  end
  
  if (m.controller.buttonDown & Z_TRIG == 0 and m.controller.buttonDown & B_BUTTON ~= 0 and m.actionArg == 0 and m.actionTimer > 8) then
    m.vel.y = 15
    m.particleFlags = m.particleFlags | PARTICLE_MIST_CIRCLE
    play_sound(SOUND_ACTION_UNSTUCK_FROM_GROUND, m.pos)
    set_mario_action(m, ACT_MISCHA_SLAP_AIR, 0)
  end
	
	if (m.controller.buttonDown & Z_TRIG ~= 0 and m.controller.buttonPressed & B_BUTTON ~= 0) then
	  m.vel.y = 10
	  set_mario_action(m, ACT_MISCHA_GROUND_SLAP_AIR, 0)
	end
  
  m.actionTimer = m.actionTimer + 1
  
end

hook_mario_action(ACT_MISCHA_JUMP, {every_frame = act_mischa_jump, gravity = mischa_gravity})


_G.ACT_MISCHA_LUNGE = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_DIVING| ACT_FLAG_AIR | ACT_FLAG_SHORT_HITBOX)

function act_mischa_lunge(m)
  
  step = perform_air_step(m, 1)
  
  if (step == AIR_STEP_LANDED) then
    set_mario_action(m, ACT_MISCHA_WALK, 0)
    m.actionTimer = 2
    return
  elseif (step == AIR_STEP_HIT_WALL) then
    return mischa_bonk(m)
  end
  
  local intendedX = (sins(m.faceAngle.y) * m.forwardVel/1.5) + (sins(m.intendedYaw) * m.forwardVel)
  local intendedZ = (coss(m.faceAngle.y) * m.forwardVel/1.5) + (coss(m.intendedYaw) * m.forwardVel)
  
  m.vel.x = lerp(m.vel.x, intendedX, MISCHA_ACCEL_SLEERP/2)
  m.vel.z = lerp(m.vel.z, intendedZ, MISCHA_ACCEL_SLEERP/2)
  
  if (m.forwardVel < MISCHA_FORWARD_LUNGE_VEL/2.5) then
    set_mario_animation(m, CHAR_ANIM_FORWARD_SPINNING)
  if (m.forwardVel < MISCHA_FORWARD_LUNGE_VEL/3.5) then
    set_mario_action(m, ACT_MISCHA_JUMP, 1)
  end
  else
    set_mario_anim_with_accel(m, CHAR_ANIM_FORWARD_SPINNING_FLIP, 0x15000)
  end
	
	if (m.flags & MARIO_WING_CAP ~= 0 and m.controller.buttonPressed & A_BUTTON ~= 0) then
	  m.particleFlags = m.particleFlags & PARTICLE_MIST_CIRCLE
	  set_mario_action(m, ACT_FLYING_TRIPLE_JUMP, 0)
		m.vel.y = 0
	end
  
  m.forwardVel = approach_s32(m.forwardVel, 0, MISCHA_LUNGE_DECEL, MISCHA_LUNGE_DECEL)
  
end

hook_mario_action(ACT_MISCHA_LUNGE, {every_frame = act_mischa_lunge, gravity = mischa_gravity})


_G.ACT_MISCHA_DOOR = allocate_mario_action(ACT_GROUP_CUTSCENE | ACT_FLAG_INVULNERABLE)

function act_mischa_door(m)
  mischa = gMischaStates[0]
  
  local doorAngle = mischa.doorInteract.angle
  local doorPosX = mischa.doorInteract.x
  local doorPosZ = mischa.doorInteract.z
  
  perform_ground_step(m)
  if m.actionTimer < 25 then
    mario_set_forward_vel(m, lerp(m.forwardVel, 0, 0.5))
    set_mario_animation(m, MISCHA_ANIM_IDLE)
    m.faceAngle.y = approach_s16_asymptotic(m.faceAngle.y, doorAngle, MISCHA_TILT_SPEED)
    m.pos.x = lerp(m.pos.x, doorPosX, 0.2)
      m.pos.z = lerp(m.pos.z, doorPosZ, 0.2)
  elseif
    m.actionTimer < 35 and m.actionTimer > 20 then
      mario_set_forward_vel(m, lerp(m.forwardVel, 35, 0.2))
      set_mario_anim_with_accel(m, MISCHA_ANIM_RUN, 0x25000)
    elseif m.actionTimer > 35 then
      return set_mario_action(m, ACT_MISCHA_WALK, 0)
    end
  
  
  m.actionTimer = m.actionTimer + 1
end

hook_mario_action(ACT_MISCHA_DOOR, act_mischa_door)

ACT_MISCHA_TRIP = (ACT_GROUP_AUTOMATIC | ACT_FLAG_BUTT_OR_STOMACH_SLIDE)

function act_mischa_trip(m)
  
  step = perform_ground_step(m)
  
  m.marioObj.header.gfx.angle.y = approach_s16_asymptotic(m.marioObj.header.gfx.angle.y, m.floorAngle, MISCHA_TILT_SPEED)
  
  local intendedX = (sins(m.floorAngle) * math.abs(m.forwardVel)) + sins(m.intendedYaw) * 35
  local intendedZ = coss(m.floorAngle) * math.abs(m.forwardVel) + coss(m.intendedYaw) * 35
  
  if (m.input & INPUT_ABOVE_SLIDE ~= 0) then
    m.forwardVel = approach_s32(m.forwardVel, MISCHA_TERMINAL_VEL/2, 2, 2)
    m.vel.x = lerp(m.vel.x, intendedX, MISCHA_ACCEL_SLEERP)
    m.vel.z = lerp(m.vel.z, intendedZ, MISCHA_ACCEL_SLEERP)
    else
    m.forwardVel = approach_s32(m.forwardVel, 0, 0.05, 0.05)
    m.vel.x = lerp(m.vel.x, 0, MISCHA_ACCEL_SLEERP)
    m.vel.z = lerp(m.vel.z, 0, MISCHA_ACCEL_SLEERP)
    
    if (math.sqrt(m.vel.x^2 + m.vel.z^2) < 10) then
    set_mario_action(m, ACT_HARD_BACKWARD_GROUND_KB, 0)
    end
    end
  
  set_mario_anim_with_accel(m, CHAR_ANIM_FORWARD_SPINNING, 0x300*(math.sqrt(m.vel.x^2 + m.vel.z^2)))
  
end

hook_mario_action(ACT_MISCHA_TRIP, act_mischa_trip)

_G.ACT_MISCHA_BONK = allocate_mario_action(ACT_GROUP_CUTSCENE | ACT_FLAG_AIR | ACT_FLAG_INVULNERABLE)

function act_mischa_bonk(m)
  if (m.actionTimer < 16) then
    play_sound(SOUND_ACTION_UNSTUCK_FROM_GROUND, m.marioObj.header.gfx.cameraToObject)
    set_mario_anim_with_accel(m, CHAR_ANIM_SHOCKED, 0x10000/m.actionTimer)
    mario_set_forward_vel(m, 1)
    m.marioObj.header.gfx.pos.x = m.pos.x + sins(m.faceAngle.y) * 25
      m.pos.z = m.marioObj.header.gfx.pos.z + coss(m.faceAngle.y) * 25
    m.vel.y = MISCHA_JUMP_HEIGHT/4
    if (m.wall ~= nil) then
      m.faceAngle.y = atan2s(m.wall.normal.z, m.wall.normal.x) + 0x8000
      m.marioObj.header.gfx.angle.y = m.faceAngle.y
    end
    
    if (m.controller.buttonPressed & A_BUTTON ~= 0) then
      m.actionTimer = 16
      end
    
  elseif (m.actionTimer > 15 and m.actionTimer < 25) then
   perform_air_step(m, 1)
   m.vel.x = sins(m.faceAngle.y) * -MISCHA_TOP_SPEED/2
    m.vel.z = coss(m.faceAngle.y) * -MISCHA_TOP_SPEED/2
   set_mario_animation(m, CHAR_ANIM_BACKWARD_SPINNING)
   else
     set_mario_action(m, ACT_MISCHA_JUMP, 1)
    end
  
  m.actionTimer = m.actionTimer + 1
end

hook_mario_action(ACT_MISCHA_BONK, {every_frame = act_mischa_bonk, gravity = mischa_gravity})


_G.ACT_MISCHA_TORNADO = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_MOVING)

function act_mischa_tornado(m)
  local e = gMischaStates[0]
  
  step = perform_ground_step(m)
  
  m.faceAngle.y = 0x4000
  set_mario_anim_with_accel(m, MISCHA_ANIM_TORNADO, 0x17500)
  m.particleFlags = m.particleFlags | PARTICLE_DUST
  play_sound_with_freq_scale(SOUND_MOVING_FLYING, m.marioObj.header.gfx.cameraToObject, m.actionTimer/100 + 0.35)
  
  local intendedAngX = (m.vel.x/66)*0x6000
  local intendedAngZ = (m.vel.z/66)*0x6000
  
  m.marioObj.header.gfx.angle.x = lerp(m.marioObj.header.gfx.angle.x, intendedAngX, 0.2)
  m.marioObj.header.gfx.angle.z = lerp(m.marioObj.header.gfx.angle.z, intendedAngZ, 0.2)
  
  if (m.playerIndex == 0) then
    if MISCHA_PREV_SPIN_DIR == 0 and MISCHA_SPIN_DIR ~= 0 and MISCHA_SPIN_DIR == -MISCHA_LAST_CIRCLING_DIR then
      MISCHA_TORNADO_TIMER = 12
      --djui_chat_message_create(tostring(MISCHA_LAST_CIRCLING_DIR.." Curr:"..MISCHA_SPIN_DIR))
    
    end
    
    if (MISCHA_TORNADO_TIMER < 1) then
      if (MISCHA_SPIN_DIR*MISCHA_PREV_SPIN_DIR == -1) then
        m.actionTimer = approach_s32(m.actionTimer, 0, MISCHA_TORNADO_ADD*4, MISCHA_TORNADO_ADD*4)
        MISCHA_TORNADO_TIMER = 30
      elseif (MISCHA_SPIN_DIR*MISCHA_PREV_SPIN_DIR == 0) then
        m.actionTimer = approach_s32(m.actionTimer, 0, MISCHA_TORNADO_ADD/2, MISCHA_TORNADO_ADD/2)
        else
          m.actionTimer = approach_s32(m.actionTimer, MISCHA_TORNADO_MAX, MISCHA_TORNADO_ADD*2, MISCHA_TORNADO_ADD*2)
      end
    else
        m.actionTimer = approach_s32(m.actionTimer, 0, MISCHA_TORNADO_ADD/2, MISCHA_TORNADO_ADD/2)
        MISCHA_TORNADO_TIMER = MISCHA_TORNADO_TIMER - 1
    end
  end
  
  if (m.wall ~= nil) then
    spawn_triangle_break_particles(16, 138, 3, 4)
    audio_sample_play(SOUND_BOUNCE_WALL, m.pos, .25)
    local wallAngle = atan2s(m.wall.normal.z, m.wall.normal.x)
    m.vel.x = m.vel.x + sins(wallAngle) * 100
    m.vel.z = m.vel.z + coss(wallAngle) * 100
  end
  
  local ang = (CONTROL_STICK_MAG > 0 and m.intendedYaw or atan2s(m.vel.z, m.vel.x))
  
  local intendedX = (sins(ang) * (m.actionTimer/1.25))
  local intendedZ = (coss(ang) * (m.actionTimer/1.25))

  m.vel.x = lerp(m.vel.x, intendedX, MISCHA_ACCEL_SLEERP)
  m.vel.z = lerp(m.vel.z, intendedZ, MISCHA_ACCEL_SLEERP)
  
  m.forwardVel = math.sqrt(m.vel.x^2 + m.vel.z^2)
  
  if (m.actionArg == 0 and m.actionTimer > 50) then
    m.actionArg = 1
  end
  
  if (m.controller.buttonDown & A_BUTTON ~= 0) then
        m.particleFlags = m.particleFlags | PARTICLE_FIRE
        play_sound_with_freq_scale(SOUND_MOVING_SLIDE_DOWN_TREE, m.pos, m.forwardVel/10)
        m.actionTimer = m.actionTimer - .5
    elseif (m.controller.buttonDown & Z_TRIG ~= 0 and m.actionArg ~= 0 and m.actionTimer > 0) then
    m.actionTimer = m.actionTimer - MISCHA_TORNADO_ADD
    end

  if (m.controller.buttonReleased & A_BUTTON ~= 0) then
    m.forwardVel = m.forwardVel/1.5
    m.particleFlags = m.particleFlags | PARTICLE_MIST_CIRCLE
    m.vel.y = 45 + 40/(math.max(m.forwardVel, 5))
    
    m.vel.x = m.vel.x + sins(m.floorAngle) * (100*(1-(m.floor.normal.y)))
    m.vel.z = m.vel.z + coss(m.floorAngle) * (100*(1-(m.floor.normal.y)))
    
    local timer = m.actionTimer
    set_mario_action(m, ACT_MISCHA_TORNADO_AIR, 0)
    m.actionTimer = timer
    m.vel.y = 45 + 40/(math.max(m.forwardVel, 5))
    play_sound(SOUND_ACTION_SIDE_FLIP_UNK, m.pos)
  end
  
  if (m.actionTimer == 100) then
    m.particleFlags = m.particleFlags | PARTICLE_DUST
    end
  
  if (m.actionTimer < 5 and m.actionArg ~= 0) then
    set_mario_action(m, ACT_MISCHA_WALK, 0)
    m.actionTimer = MISCHA_TORNADO_DEBOUNCE
  end
  
  if (step == GROUND_STEP_LEFT_GROUND) then
    MISCHA_COYOTE_TIMER = MISCHA_COYOTE_TIMER - 1
    perform_air_step(m, 0)
    if MISCHA_COYOTE_TIMER < 1 then
        local timer = m.actionTimer
				m.vel.y = MISCHA_MOVEMENT.y
      set_mario_action(m, ACT_MISCHA_TORNADO_AIR, 0)
      m.actionTimer = timer
    end
  end
  
end

hook_mario_action(ACT_MISCHA_TORNADO, act_mischa_tornado)

_G.ACT_MISCHA_SLAP = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_MOVING)


function act_mischa_slap(m)
  step = perform_ground_step(m)
  
  if (m.forwardVel ~= 0) then
  set_mario_anim_with_accel(m, MISCHA_ANIM_SLAP_MOVE, 0x60000)
    else
  set_mario_animation(m, MISCHA_ANIM_SLAP_IDLE)
  end
  m.marioBodyState.handState = MARIO_HAND_RIGHT_OPEN
  
  local intendedX = (sins(m.intendedYaw) * MISCHA_TOP_SPEED/1.5)*CONTROL_STICK_MAG
  local intendedZ = (coss(m.intendedYaw) * MISCHA_TOP_SPEED/1.5)*CONTROL_STICK_MAG
  
  m.vel.x = lerp(m.vel.x, intendedX, MISCHA_ACCEL_SLEERP/2)
  m.vel.z = lerp(m.vel.z, intendedZ, MISCHA_ACCEL_SLEERP/2)
  m.faceAngle.y = approach_s16_asymptotic(m.faceAngle.y, m.intendedYaw, 16)
  
  m.forwardVel = math.sqrt(m.vel.x^2 + m.vel.z^2)
  
  if (is_anim_past_end(m) ~= 0) then
    set_mario_action(m, ACT_MISCHA_WALK, 0)
  end
  
  if (m.controller.buttonDown & A_BUTTON ~= 0) then
    m.vel.y = 40
    m.particleFlags = m.particleFlags | PARTICLE_MIST_CIRCLE
    play_sound(SOUND_ACTION_UNSTUCK_FROM_GROUND, m.pos)
    set_mario_action(m, ACT_MISCHA_SLAP_AIR, 0)
  end
  
  if (m.controller.buttonDown & Z_TRIG ~= 0) then
    set_mario_action(m, ACT_MISCHA_KICK, 0)
  end
  
  if (step == GROUND_STEP_LEFT_GROUND) then
    MISCHA_COYOTE_TIMER = MISCHA_COYOTE_TIMER - 1
    perform_air_step(m, 0)
    if MISCHA_COYOTE_TIMER < 1 then
      set_mario_action(m, ACT_MISCHA_SLAP_AIR, 0)
    end
  end
  
end

hook_mario_action(ACT_MISCHA_SLAP, act_mischa_slap, INT_KICK)

_G.ACT_MISCHA_LEDGE = allocate_mario_action(ACT_GROUP_AUTOMATIC)

function act_mischa_ledge(m)
  
  --local step = perform_ground_step(m)
	
	set_mario_anim_with_accel(m, CHAR_ANIM_MOVE_ON_WIRE_NET_RIGHT + m.actionArg, 0)
	
	m.actionTimer = m.actionTimer + 1
	
	local wall = collision_find_surface_on_ray(m.pos.x, m.pos.y + 65, m.pos.z, sins(m.faceAngle.y)*250, 0, coss(m.faceAngle.y)*250)
	
	local wallsurface = wall.surface
	local wallace
	
	stickMagX = (m.controller.rawStickX/127)
	
	m.marioObj.header.gfx.angle.z = approach_s16_asymptotic(m.marioObj.header.gfx.angle.z, 0x1000*stickMagX, 8)
	
	if stickMagX ~= 0 then
	  m.marioObj.header.gfx.animInfo.animFrame = m.marioObj.header.gfx.animInfo.animFrame + 1*math.abs(stickMagX)
		
		if is_anim_past_end(m) ~= 0 then
		  m.actionArg = 1 - m.actionArg
		end
		
	end
	
	m.forwardVel = stickMagX*35
	
	m.vel.x = lerp(m.vel.x, sins(m.faceAngle.y - 0x4000)*m.forwardVel, .1)
	m.vel.z = lerp(m.vel.z, coss(m.faceAngle.y - 0x4000)*m.forwardVel, .1)
	
	if wall.surface then
	  wallace = atan2s(wall.surface.normal.z, wall.surface.normal.x)
		
		m.pos.x = wall.hitPos.x - sins(m.faceAngle.y)*25 + m.vel.x
		m.pos.z = wall.hitPos.z - coss(m.faceAngle.y)*25 + m.vel.z
		
		m.faceAngle.y = wallace + 0x8000
	else
	  set_mario_action(m, ACT_MISCHA_JUMP, 0)
		audio_stream_stop(MISCHA_FANFARE)
		audio_sample_play(SOUND_LEDGE_SLIP, m.pos, .35)
		m.vel.y = 0
	end
	
	local floor = collision_find_surface_on_ray(m.pos.x + sins(m.faceAngle.y)*50, m.pos.y + 150, m.pos.z + coss(m.faceAngle.y)*50, 0, -300, 0)
  
	if floor.surface then
		m.pos.y = floor.hitPos.y - 75
	else
	  set_mario_action(m, ACT_MISCHA_JUMP, 0)
		audio_stream_stop(MISCHA_FANFARE)
		audio_sample_play(SOUND_LEDGE_SLIP, m.pos, .35)
		m.vel.y = 0
	end
	
	
	local predictedwall = collision_find_surface_on_ray((m.pos.x - sins(m.faceAngle.y)*25) + sins(m.faceAngle.y - 0x4000)*(35*stickMagX), m.pos.y + 50 + MISCHA_MOVEMENT.y, (m.pos.z - coss(m.faceAngle.y)*25) + coss(m.faceAngle.y - 0x4000)*(35*stickMagX), sins(m.faceAngle.y)*250, 0, coss(m.faceAngle.y)*250)
	
	if predictedwall.surface then
	  pwAngle = atan2s(predictedwall.surface.normal.z, predictedwall.surface.normal.x)
	  
	  if wallace and pwAngle and math.abs(angle_diff(wallace, pwAngle)) > 0x500 then
			--djui_chat_message_create("normal.y: "..predictedwall.surface.normal.y.." yawdiff: "..angle_diff(wallace, pwAngle))
		  m.pos.x = predictedwall.hitPos.x
		  m.pos.z = predictedwall.hitPos.z
		  m.faceAngle.y = pwAngle + 0x8000
	  end
	end
	
	
  if (m.controller.buttonDown & A_BUTTON ~= 0 and m.actionTimer > 10) then
      mischa_jump(m)
			audio_stream_stop(MISCHA_FANFARE)
  end
	
	if m.controller.buttonDown & Z_TRIG == 0 and m.actionTimer > 10 then
	  set_mario_action(m, ACT_MISCHA_JUMP, 0)
	end
	
	visPos = m.marioObj.header.gfx.pos
	
	visPos.x = lerp(visPos.x, m.pos.x, .5)
	visPos.y = lerp(visPos.y, m.pos.y - 75, .5)
  visPos.z = lerp(visPos.z, m.pos.z, .5) 
	
	m.marioObj.header.gfx.angle.y = approach_s16_asymptotic(m.marioObj.header.gfx.angle.y, m.faceAngle.y, 3)
	
	if m.playerIndex == 0 then
	  MISCHA_FANFARE.frequency = lerp(MISCHA_FANFARE.frequency, math.max(math.abs(stickMagX), .25), .1)
	  audio_stream_play(MISCHA_FANFARE, false, .35)
	end
	
end

hook_mario_action(ACT_MISCHA_LEDGE, act_mischa_ledge)

_G.ACT_MISCHA_KICK = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_MOVING | ACT_FLAG_SHORT_HITBOX)

function act_mischa_kick(m)
  
  local step = perform_ground_step(m)
  
  set_mario_animation(m, MISCHA_ANIM_KAZOTSKY)
  
  m.actionState = m.actionState + 1
  
   local bouncy = math.abs(sins(m.actionState*(11400/4)))
  
  m.marioObj.header.gfx.pos.y = m.pos.y + bouncy*(25) - 7
  
   m.marioBodyState.handState = MARIO_HAND_OPEN
  
  local intendedX = (sins(m.intendedYaw) * MISCHA_TOP_SPEED/5)*CONTROL_STICK_MAG
  local intendedZ = (coss(m.intendedYaw) * MISCHA_TOP_SPEED/5)*CONTROL_STICK_MAG
  
  m.vel.x = lerp(m.vel.x, intendedX, MISCHA_ACCEL_SLEERP/2)
  m.vel.z = lerp(m.vel.z, intendedZ, MISCHA_ACCEL_SLEERP/2)
  m.faceAngle.y = approach_s16_asymptotic(m.faceAngle.y, m.intendedYaw, 8)
  
  m.forwardVel = math.sqrt(m.vel.x^2 + m.vel.z^2)
  
  if (m.controller.buttonDown & Z_TRIG == 0 or m.controller.buttonDown & B_BUTTON == 0) then
    set_mario_action(m, ACT_MISCHA_WALK, 0)
    m.actionTimer = 20
  end
  
end

hook_mario_action(ACT_MISCHA_KICK, act_mischa_kick, INT_PUNCH)

_G.ACT_MISCHA_TORNADO_AIR = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR)

function act_mischa_tornado_air(m)
  
  local step = perform_air_step(m, 1)
  
  local ang = (CONTROL_STICK_MAG > 0 and m.intendedYaw or atan2s(m.vel.z, m.vel.x))
  
	if (m.actionArg == 0) then
    intendedX = (sins(ang) * (m.actionTimer/1.5))
    intendedZ = (coss(ang) * (m.actionTimer/1.5))
	else
	  intendedX = (sins(ang) * (MISCHA_TOP_SPEED))*CONTROL_STICK_MAG
    intendedZ = (coss(ang) * (MISCHA_TOP_SPEED))*CONTROL_STICK_MAG
		m.actionTimer = 50
	end

  m.vel.x = lerp(m.vel.x, intendedX, MISCHA_ACCEL_SLEERP/4)
  m.vel.z = lerp(m.vel.z, intendedZ, MISCHA_ACCEL_SLEERP/4)
  
  m.faceAngle.y = 0x4000
  set_mario_anim_with_accel(m, MISCHA_ANIM_TORNADO, 0x17500)
  m.particleFlags = m.particleFlags | PARTICLE_DUST
  play_sound_with_freq_scale(SOUND_MOVING_FLYING, m.marioObj.header.gfx.cameraToObject, m.actionTimer/100 + 0.35)
  
  local intendedAngX = (m.vel.x/66)*0x6000
  local intendedAngZ = (m.vel.z/66)*0x6000
  
  m.marioObj.header.gfx.angle.x = lerp(m.marioObj.header.gfx.angle.x, intendedAngX, 0.1)
  m.marioObj.header.gfx.angle.z = lerp(m.marioObj.header.gfx.angle.z, intendedAngZ, 0.1)
  
  m.actionTimer = approach_s32(m.actionTimer, 0, 1, 2)
  
  if (m.vel.y < 5 and step == AIR_STEP_LANDED) then
    local timer = m.actionTimer
    set_mario_action(m, ACT_MISCHA_TORNADO, 0)
    m.actionTimer = timer + math.abs(m.vel.y)
    m.vel.y = 0
  end
  
  if (m.wall) then
    spawn_triangle_break_particles(16, 138, 3, 4)
    audio_sample_play(SOUND_BOUNCE_WALL, m.pos, .25)
    local wallAngle = atan2s(m.wall.normal.z, m.wall.normal.x)
    m.vel.x = m.vel.x + sins(wallAngle) * 100
    m.vel.z = m.vel.z + coss(wallAngle) * 100
  end
  
  if (m.controller.buttonPressed & B_BUTTON ~= 0) then
	  if (m.controller.buttonDown & Z_TRIG ~= 0) then
		  m.vel.y = 10
			set_mario_action(m, ACT_MISCHA_GROUND_SLAP_AIR, 0)
			m.faceAngle.y = m.intendedYaw
		else
      m.vel.y = 15
      m.particleFlags = m.particleFlags | PARTICLE_MIST_CIRCLE
      play_sound(SOUND_ACTION_UNSTUCK_FROM_GROUND, m.pos)
      set_mario_action(m, ACT_MISCHA_SLAP_AIR, 0)
		end
  end
  
end

hook_mario_action(ACT_MISCHA_TORNADO_AIR, {every_frame = act_mischa_tornado_air, gravity = mischa_gravity})

_G.ACT_MISCHA_SLAP_AIR = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_ATTACKING | ACT_FLAG_AIR)

function act_mischa_slap_air(m)
  
   local step = perform_air_step(m, 0)
   local prevWallangle
   
   if (MISCHA_PREV_WALL and MISCHA_PREV_WALL.normal) then
     prevWallangle = atan2s(MISCHA_PREV_WALL.normal.z, MISCHA_PREV_WALL.normal.x) 
    else
       prevWallangle = 0x0
    end
   
   m.actionTimer = m.actionTimer + 1
  
  set_mario_animation(m, MISCHA_ANIM_SLAP_IDLE)
  
   m.marioBodyState.handState = MARIO_HAND_RIGHT_OPEN
  
  local intendedX = (sins(m.intendedYaw) * MISCHA_TOP_SPEED/1.5)*CONTROL_STICK_MAG
  local intendedZ = (coss(m.intendedYaw) * MISCHA_TOP_SPEED/1.5)*CONTROL_STICK_MAG
  
  m.vel.x = lerp(m.vel.x, intendedX, MISCHA_ACCEL_SLEERP/2)
  m.vel.z = lerp(m.vel.z, intendedZ, MISCHA_ACCEL_SLEERP/2)
  m.faceAngle.y = m.faceAngle.y - 0x100*(2^((15 - m.actionTimer)/2))
  
  m.marioObj.header.gfx.angle.y = m.faceAngle.y + 0x4000
  
  m.forwardVel = math.sqrt(m.vel.x^2 + m.vel.z^2)
  
  if (is_anim_past_end(m) ~= 0) then
    set_mario_action(m, ACT_MISCHA_JUMP, 0)
    m.faceAngle.y = m.intendedYaw
  end
  
  if (m.wall) then
    local curWallAngle = atan2s(m.wall.normal.z, m.wall.normal.x)
    local wallDiff = math.abs(curWallAngle - prevWallangle)
    MISCHA_PREV_WALL = m.wall
    
    if (m.playerIndex == 0) then
        if (wallDiff < 0x6000) then
          MISCHA_WALL_SLAPS = MISCHA_WALL_SLAPS + 1
        else
          MISCHA_WALL_SLAPS = approach_s32(MISCHA_WALL_SLAPS, 1, 1, 1)
					set_mario_action(m, ACT_MISCHA_SLAP_AIR, 0)
        end
    end
    
    spawn_triangle_break_particles(16, 138, 2, 4)
    play_sound(SOUND_GENERAL_POUND_ROCK, m.marioObj.header.gfx.cameraToObject)
     
    local wallAngle = atan2s(m.wall.normal.z, m.wall.normal.x)
    m.vel.x = m.vel.x + sins(wallAngle) * 75
    m.vel.z = m.vel.z + coss(wallAngle) * 75
    
    m.vel.y = m.forwardVel/1.5 + -6*MISCHA_WALL_SLAPS + 25
    m.marioObj.header.gfx.animInfo.animFrame = 0
  end
  
  if (step == AIR_STEP_LANDED) then
    set_mario_action(m, ACT_MISCHA_SLAP, 0)
  end
  
end

hook_mario_action(ACT_MISCHA_SLAP_AIR, {every_frame = act_mischa_slap_air, gravity = mischa_gravity}, INT_KICK)

_G.ACT_MISCHA_KART = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_AIR | ACT_FLAG_MOVING | ACT_FLAG_SWIMMING)

function act_mischa_kart(m)
  local stepAir = perform_air_step(m, 0)
  local air
  local vel = math.sqrt(m.vel.x^2 + m.vel.z^2)
  local inertiaDir = atan2s(m.vel.z, m.vel.x)
  if (stepAir == AIR_STEP_LANDED) then
    local stepGround = perform_ground_step(m)
    air = false
  else
    air = true
  end
	
	m.forwardVel = math.sqrt(m.vel.x^2 + m.vel.z^2)
  
  m.faceAngle.x = lerp(m.faceAngle.x, MISCHA_MOVEMENT.y*10, .1)
  
  set_mario_animation(m, CHAR_ANIM_START_SLEEP_SITTING)
  set_anim_to_frame(m, 24)
  
  if (m.wall) then
    local wallace = atan2s(m.wall.normal.z, m.wall.normal.x)
    
    m.vel.x = m.vel.x + sins(wallace)*(vel)
    m.vel.z = m.vel.z + coss(wallace)*(vel)
  end
  
  if (air == false) then
    m.vel.y = MISCHA_MOVEMENT.y
  end
  
  if (math.abs(m.pos.y - m.floorHeight) < 25) then
    if (m.controller.buttonPressed & B_BUTTON ~= 0) then
      m.vel.y = m.vel.y + vel/2
			audio_sample_play(SOUND_KART_HONK, m.pos, .25)
    end
  end
  
  if (m.controller.buttonDown & A_BUTTON ~= 0) then
    m.vel.x = m.vel.x + sins(m.faceAngle.y)*KART_MISCHA_ACCEL
    m.vel.z = m.vel.z + coss(m.faceAngle.y)*KART_MISCHA_ACCEL
    
    if vel > KART_FORWARD_MAX/2 then
      local slower = approach_f32(vel, KART_FORWARD_MAX/2, 5, 5)
      local scale = slower / vel
      m.vel.x = m.vel.x * scale
      m.vel.z = m.vel.z * scale
    end
  else
    if vel > 0 then
      local slower = approach_f32(vel, 0, KART_DECEL, KART_DECEL)
      local scale = slower / vel
      m.vel.x = m.vel.x * scale
      m.vel.z = m.vel.z * scale
    end
  end
  
  if (m.controller.buttonDown & Z_TRIG ~= 0) then
    
    if (vel < 15) then
      m.vel.x = m.vel.x + sins(m.faceAngle.y)*-(KART_MISCHA_ACCEL/2)
    m.vel.z = m.vel.z + coss(m.faceAngle.y)*-(KART_MISCHA_ACCEL/2)
    else
      m.vel.x = m.vel.x*.97
      m.vel.z = m.vel.z*.97
      -- play_sound(SOUND_ACTION_METAL_JUMP, m.marioObj.header.gfx.cameraToObject)
	  audio_stream_play(SOUND_KART_BRAKE, false, .15)
      m.particleFlags = m.particleFlags | PARTICLE_FIRE
    end
  end
  
  if (m.controller.buttonReleased & Z_TRIG ~= 0) then
	  audio_stream_stop(SOUND_KART_BRAKE)
  end
  
  if (math.abs(m.faceAngle.y - inertiaDir) > 0x1500 and math.abs(m.pos.y - m.floorHeight) < 25 and vel > 10) then
    --  play_sound_with_freq_scale(SOUND_MOVING_LAVA_BURN, m.marioObj.header.gfx.cameraToObject, KART_FORWARD_MAX/vel)
	  audio_stream_play(SOUND_KART_DRIFT, false, .25)
    m.particleFlags = m.particleFlags | PARTICLE_DIRT
  else
    audio_stream_stop(SOUND_KART_DRIFT)
  end

  local turnMag = (vel/(KART_FORWARD_MAX))*(math.abs(m.controller.rawStickX)/127)
  
  if (m.controller.rawStickX < -64) then
    m.faceAngle.y = m.faceAngle.y + math.min((KART_TURN_VEL*turnMag), 0x2000)
  end
  
  if (m.controller.rawStickX > 64) then
    m.faceAngle.y = m.faceAngle.y - math.max((KART_TURN_VEL*turnMag), -0x2000)
  end
  
  --play_sound_with_freq_scale(SOUND_MOVING_SHOCKED, m.marioObj.header.gfx.cameraToObject, math.max(vel/(KART_FORWARD_MAX/2), 20/KART_FORWARD_MAX))
  audio_stream_set_frequency(SOUND_KART_ENG, math.max(1 + vel/5, 2))
  audio_stream_play(SOUND_KART_ENG, false, .1)
	
	if m.playerIndex == 0 then
	  MISCHA_KART_DIST_DRIVEN = MISCHA_KART_DIST_DRIVEN + MOVING_VEL
    
	  m.actionTimer = m.actionTimer + 1
	  
	  if m.actionTimer > 30 then
			m.actionTimer = 0
		  mod_storage_save_number("MISCHA-DRIVE-DIST", MISCHA_KART_DIST_DRIVEN)
	  end
	end
	
	
end

hook_mario_action(ACT_MISCHA_KART, {every_frame = act_mischa_kart, gravity = mischa_gravity})

_G.ACT_MISCHA_SWIM = allocate_mario_action(ACT_GROUP_SUBMERGED | ACT_FLAG_SWIMMING)

function act_mischa_swim(m)
  local step = perform_water_step(m)
  
  if (math.abs(m.waterLevel - m.pos.y) < 200) then
    m.actionArg = MISCHA_SWIM_STATE_SURFACE
  else
    m.actionArg = MISCHA_SWIM_STATE_SUBMERGED
  end
  
  if m.actionArg == MISCHA_SWIM_STATE_SURFACE then
    
    m.faceAngle.x = approach_s16_asymptotic(m.faceAngle.x, 1, 8)
    local intendedX = (sins(m.intendedYaw) * MISCHA_TOP_SPEED/1.5)*CONTROL_STICK_MAG
    local intendedZ = (coss(m.intendedYaw) * MISCHA_TOP_SPEED/1.5)*CONTROL_STICK_MAG
    
    set_mario_anim_with_accel(m, CHAR_ANIM_FLUTTERKICK, 0x10000*(CONTROL_STICK_MAG + .1))
    
    m.vel.x = lerp(m.vel.x, intendedX, MISCHA_ACCEL_SLEERP/4)
    m.vel.z = lerp(m.vel.z, intendedZ, MISCHA_ACCEL_SLEERP/4)
    m.faceAngle.y = approach_s16_asymptotic(m.faceAngle.y, m.intendedYaw, 8)
    
    if (m.controller.buttonPressed & A_BUTTON ~= 0) then
      mischa_jump(m)
    end
    
    if (m.controller.buttonPressed & Z_TRIG ~= 0) then
      m.vel.y = -20
    end
    
  end
  
  if m.actionArg == MISCHA_SWIM_STATE_SUBMERGED then
    local intendedX = (sins(m.faceAngle.y) * MISCHA_TOP_SPEED/1.25)*coss(m.faceAngle.x)
    local intendedY = sins(m.faceAngle.x)*MISCHA_TOP_SPEED/1.25
    local intendedZ = (coss(m.faceAngle.y) * MISCHA_TOP_SPEED/1.25)*coss(m.faceAngle.x)
    
    if m.controller.buttonDown & A_BUTTON ~= 0 then
      m.vel.x = lerp(m.vel.x, intendedX, MISCHA_ACCEL_SLEERP/4)
      m.vel.y = lerp(m.vel.y, intendedY, MISCHA_ACCEL_SLEERP/4)
      m.vel.z = lerp(m.vel.z, intendedZ, MISCHA_ACCEL_SLEERP/4)
    elseif m.controller.buttonDown & Z_TRIG ~= 0 then
      m.vel.x = lerp(m.vel.x, -(intendedX/2), MISCHA_ACCEL_SLEERP/4)
      m.vel.y = lerp(m.vel.y, -(intendedY/2), MISCHA_ACCEL_SLEERP/4)
      m.vel.z = lerp(m.vel.z, -(intendedZ/2), MISCHA_ACCEL_SLEERP/4)
    else
      m.vel.x = lerp(m.vel.x, 0, MISCHA_ACCEL_SLEERP/4)
      m.vel.y = lerp(m.vel.y, 0, MISCHA_ACCEL_SLEERP/4)
      m.vel.z = lerp(m.vel.z, 0, MISCHA_ACCEL_SLEERP/4)
    end
    
    m.faceAngle.y = m.faceAngle.y + (m.controller.rawStickX/-127)*0x250
    if (math.abs(m.faceAngle.x) < 0x3000) then
      m.faceAngle.x = m.faceAngle.x + (m.controller.rawStickY/127)*0x250
    else
      m.faceAngle.x = approach_s16_asymptotic(m.faceAngle.x, 1, 32)
    end
    
  end
  
  if m.health < 0x100 then
    set_mario_action(m, ACT_DROWNING, 0)
  end
  
end

hook_mario_action(ACT_MISCHA_SWIM, act_mischa_swim)

_G.ACT_MISCHA_GROUND_SLAP_AIR = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_ATTACKING | ACT_FLAG_AIR)

function act_mischa_ground_slap_air(m)

  step = perform_air_step(m, 0)
	set_mario_anim_with_accel(m, MISCHA_ANIM_SLAP_POUND, 0x17500)
	
	if m.marioObj.header.gfx.animInfo.animFrame > 25 then
	  m.marioBodyState.handState = MARIO_HAND_OPEN
	end

  if step == AIR_STEP_LANDED then
	  set_mario_action(m, ACT_MISCHA_GROUND_SLAP_LAND, 0)
		m.particleFlags = m.particleFlags | PARTICLE_MIST_CIRCLE | PARTICLE_HORIZONTAL_STAR
		cur_obj_shake_screen(2)
		spawn_triangle_break_particles(16, 138, 2, 4)
	end
	
	m.vel.y = m.vel.y - .5
	
	local intendedX = (sins(m.intendedYaw) * MISCHA_TOP_SPEED/1.5)*CONTROL_STICK_MAG
  local intendedZ = (coss(m.intendedYaw) * MISCHA_TOP_SPEED/1.5)*CONTROL_STICK_MAG
  
  m.vel.x = lerp(m.vel.x, intendedX, MISCHA_ACCEL_SLEERP/2)
  m.vel.z = lerp(m.vel.z, intendedZ, MISCHA_ACCEL_SLEERP/2)
  m.faceAngle.y = approach_s16_asymptotic(m.faceAngle.y, m.intendedYaw, 32)

end

hook_mario_action(ACT_MISCHA_GROUND_SLAP_AIR, {every_frame = act_mischa_ground_slap_air, gravity = mischa_gravity})

_G.ACT_MISCHA_GROUND_SLAP_LAND = allocate_mario_action(ACT_GROUP_STATIONARY | ACT_FLAG_ATTACKING)

function act_mischa_ground_slap_land(m)

  m.vel.x = 0
	m.vel.z = 0
	m.pos.y = lerp(m.pos.y, m.floorHeight, .2)
	m.marioObj.header.gfx.pos.y = m.pos.y
	
	if m.controller.buttonDown & A_BUTTON ~= 0 then
	  m.vel.y = math.abs(m.vel.y)*.65
		set_mario_action(m, ACT_MISCHA_TORNADO_AIR, 2)
	end

  if m.actionTimer > 10 then
	  set_mario_action(m, ACT_MISCHA_WALK, 0)
	end
	
  m.actionTimer = m.actionTimer + 1
end

hook_mario_action(ACT_MISCHA_GROUND_SLAP_LAND, act_mischa_ground_slap_land, INT_GROUND_POUND)