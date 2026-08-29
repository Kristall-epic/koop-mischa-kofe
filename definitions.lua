E_MODEL_MISCHA = smlua_model_util_get_id("redguy_geo")
SOUND_BOUNCE_WALL = audio_sample_load("sproing.mp3")
SOUND_THEME = audio_stream_load("anthem.ogg")
SOUND_MOON_GET = audio_stream_load("moon-get.ogg")
SOUND_WARP = audio_stream_load("mischa-warp.ogg")
SOUND_BONK = audio_sample_load("mischa-bonk.ogg")
SOUND_GRAB = audio_sample_load("mischa-tornado-grab.ogg")
SOUND_SPIN = audio_stream_load("mischa-tornado-loop.ogg")
SOUND_RESTART = audio_stream_load("mischa-restart-level.ogg")
SOUND_HEAVY_LAND = audio_sample_load("mischa-land-pound.ogg")
SOUND_FEAR = audio_sample_load("mischa-near-bully.ogg")
SOUND_KART_ENG = audio_stream_load("mischa-kart-eng.ogg")
SOUND_KART_HONK = audio_sample_load("mischa-kart-honk.ogg")
SOUND_KART_DRIFT = audio_stream_load("mischa-kart-drift.ogg")
SOUND_KART_BRAKE = audio_stream_load("mischa-kart-brake.ogg")
MISCHA_FANFARE = audio_stream_load("mischa-fanfare.ogg")
SOUND_LEDGE_SLIP = audio_sample_load("mischa-slip.ogg")

TEX_CURTAIN = get_texture_info("mischa-transition-screen")
TEX_MISCHA_UI = get_texture_info("mischa-atlas")

_G.MISCHA_ANIM_RUN = 800
_G.MISCHA_ANIM_IDLE = 801
_G.MISCHA_ANIM_SLAP_IDLE = 802
_G.MISCHA_ANIM_SLAP_MOVE = 803
_G.MISCHA_ANIM_TORNADO = 804
_G.MISCHA_ANIM_KAZOTSKY = 805
_G.MISCHA_ANIM_SLAP_POUND = 806

--constants
MISCHA_TOP_SPEED = 35
MISCHA_TURN_SPEERP = 0.3
MISCHA_TILT_SPEED = 3
MISCHA_ACCEL_SLEERP = 0.2
MISCHA_GRAVITY = 2.5
MISCHA_TERMINAL_VEL = -1000
MISCHA_JUMP_HEIGHT = 40
MISCHA_AIR_DECEL = 0.9
MISCHA_SLOPE_DECEL = 15
MISCHA_FORWARD_LUNGE_VEL = 35
MISCHA_LUNGE_DECEL = 1
MISCHA_TORNADO_ADD = 2
MISCHA_TORNADO_MAX = 100
MISCHA_TORNADO_DEBOUNCE = 35
INTENDED_TORNADO_WIDTH = 0.375
INTENDED_TORNADO_HEIGHT = .25
MISCHA_LEDGE_BOING = 0.15
MISCHA_COYOTE = 3
KART_FORWARD_MAX = 250
KART_MISCHA_ACCEL = 2
KART_TURN_VEL = KART_FORWARD_MAX*10.24
KART_DECEL = .85
MISCHA_GRAB_MAX_OBJECTS = 5
TORNADO_GRABBED_DIST = 100
MISCHA_GRAB_SPINATO = 0x1000
MISCHA_GRAB_OBJECT_SLEERP = .5
MISCHA_TORNADO_GRABBABLES = {
  [id_bhvGoomba] = true,
  [id_bhvKoopa] = true,
  [id_bhvSpiny] = true,
  [id_bhvMoneybag] = true,
	[id_bhvFlyGuy] = true
}
MISCHA_SWIM_STATE_SUBMERGED = 0
MISCHA_SWIM_STATE_SURFACE = 1
MISCHA_UI_SCALE = .75
MISCHA_TORNADO_MIN_ROTATE = 0x250
TORNADO_STATE_BOWSER = 1
TORNADO_STATE_REGULAR = 0

mischaUI = {
  scl = MISCHA_UI_SCALE,
  power = {
    pos = {
      x = 0,
      y = 0
    }
  },
  lives = {
    pos = {
      x = 0,
      y = 0
    }
  },
  kofe = {
    pos = {
      x = 0,
      y = 0
    }
  }
}

--variables
MISCHA_TORNADO_TIMER = 0
MISCHA_SPIN_DIR = 0
MISCHA_PREV_SPIN_DIR = 0
TORNADO_OBJ_SPIN_DIR = 1
MISCHA_LAST_CIRCLING_DIR = 0
TORNADO_GRAB_SPIN_TIMER = 0
TORNADO_GRAB_SPIN_ACCEL = 1
MISCHA_TURNING_ANGLE = 0x0
CONTROL_STICK_MAG = 0
CONTROL_SPIN_DIFF = 0x0
MISCHA_POS_X = 0
MISCHA_POS_Y = 0
MISCHA_POS_Z = 0
MISCHA_GOAL_FOV = 50
MISCHA_FOV = 45
MISCHA_MAX_FOV = 25
MISCHA_MIN_FOV = 50
DIALOG_FULL = ""
DIALOG_CUR = 0
DIALOG_TIMER = 0
DIALOG_DEBOUNCE = 0
DIALOG_OFFSET = 0
MISCHA_COYOTE_TIMER = 3
MISCHA_WALL_SLAPS = 0
MISCHA_PREV_WALL = nil
MISCHA_TRANSITION = false
MISCHA_TRANSITION_CURTAIN_SCALE = 0
MISCHA_LIVES_ANIM = 0
MISCHA_LIVES_ANIM_TIMER = 0
MISCHA_KART_DIST_DRIVEN = mod_storage_load_number("MISCHA-DRIVE-DIST")
MISCHA_PREV_POS = {
  x = 0,
  y = 0,
  z = 0
}
MISCHA_MOVEMENT = {
  x = 0,
  y = 0,
  z = 0
}
MOVING_VEL = 0
GRABBED_OBJ = {
  o = {},
  goalPos = {
    x = 0,
    y = 0,
    z = 0
  }
}
CUR_PRESSED = {
  [A_BUTTON] = 0,
  [B_BUTTON] = 0,
  [Z_TRIG] = 0,
  [U_CBUTTONS] = 0,
  [L_CBUTTONS] = 0,
  [R_CBUTTONS] = 0,
  [D_CBUTTONS] = 0,
  [R_CBUTTONS] = 0,
  [R_TRIG] = 0
}
CUR_PRESSED_DEBOUNCE = 0
DOUBLE_TAP_TIMER = 10

MOVING_VEL = 0
--extra states
gMischaStates = {}
for i = 0, (MAX_PLAYERS-1) do
  gMischaStates[i] = {}
  local m = gMarioStates[i]
  local mischa = gMischaStates[i]
  mischa.doorInteract = {
    angle = 0x0,
    x = 0,
    z = 0
  }
  mischa.prevIntendedYaw = 0x0
end

function update_variables(m)
  if m.playerIndex ~= 0 then
    return end
  local e = gMischaStates[0]
  local diff = angle_diff(e.prevIntendedYaw, MISCHA_TURNING_ANGLE)
  local absDiff = math.abs(diff)

  MISCHA_TURNING_ANGLE = approach_s16_asymptotic(MISCHA_TURNING_ANGLE, m.intendedYaw, 2)
  
  MISCHA_MOVEMENT = {
    x = m.pos.x - MISCHA_PREV_POS.x,
    y = m.pos.y - MISCHA_PREV_POS.y,
    z = m.pos.z - MISCHA_PREV_POS.z
  }
  
  MISCHA_PREV_POS = {
    x = m.pos.x,
    y = m.pos.y,
    z = m.pos.z
  }
  
  MISCHA_PREV_SPIN_DIR = MISCHA_SPIN_DIR
	
	if MISCHA_SPIN_DIR ~= 0 then
	  TORNADO_OBJ_SPIN_DIR = MISCHA_SPIN_DIR
	end
	
  CONTROL_STICK_MAG = (m.controller.stickMag)/64
  CONTROL_TURN_DIFF = m.marioObj.header.gfx.angle.y - m.intendedYaw
  
	--djui_chat_message_create(tostring(TORNADO_OBJ_SPIN_DIR))
	
  for num, button in pairs(CUR_PRESSED) do
    if (button > 0) then
      CUR_PRESSED[num] = CUR_PRESSED[num] - 1
    end
    
    --djui_chat_message_create(tostring(num.." "..button))
  end
  
  if (m.controller.buttonPressed ~= 0) then
    for num, button in pairs(CUR_PRESSED) do
      if ((button == 0) and (m.controller.buttonPressed & num ~= 0)) then
        if (CUR_PRESSED_DEBOUNCE == 0) then
          CUR_PRESSED_DEBOUNCE = 2
        end
        CUR_PRESSED[num] = DOUBLE_TAP_TIMER
      end
      
    end
  end
  
  if (CUR_PRESSED_DEBOUNCE > 0) then
    CUR_PRESSED_DEBOUNCE = CUR_PRESSED_DEBOUNCE - 1
  end

if (absDiff > MISCHA_TORNADO_MIN_ROTATE) then
  MISCHA_SPIN_DIR = diff > 0 and 1 or -1
  if (MISCHA_PREV_SPIN_DIR ~= 0) then
    MISCHA_LAST_CIRCLING_DIR = MISCHA_PREV_SPIN_DIR
  end
else
  MISCHA_SPIN_DIR = 0
end
  
  CONTROL_SPIN_DIFF = diff
  
  e.prevIntendedYaw = m.intendedYaw
  
  MOVING_VEL = math.sqrt(MISCHA_MOVEMENT.x^2 + MISCHA_MOVEMENT.y^2 + MISCHA_MOVEMENT.z^2)
  
	if obj_count_objects_with_behavior_id(id_bhvTuxiesMother) > 0 then
	 local mom = obj_get_nearest_object_with_behavior_id(m.marioObj, id_bhvTuxiesMother) 
		djui_chat_message_create(tostring(mom.oDialogState.." response:"..mom.oDialogResponse))
	end
	
end
