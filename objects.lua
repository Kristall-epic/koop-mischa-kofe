ACT_TORNADO_SPIN = 1
ACT_TORNADO_DISAPPEAR = 2

BOWSER_DEBUG = F3.allocate_debug_info()

hook_event(HOOK_UPDATE, function()
  m = gMarioStates[0]
  local bowser = obj_get_nearest_object_with_behavior_id(m.marioObj, id_bhvBowser)
	
	if bowser then
	  F3.update_debug_info(BOWSER_DEBUG, "act: "..bowser.oAction)
	end
end)

function mischa_tornado_init(o)
  o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
  o.header.gfx.skipInViewCheck = true
  o.header.gfx.scale.x = 0.001
  o.header.gfx.scale.z = 0.001
  o.header.gfx.scale.y = 0.05
  o.oFaceAnglePitch = 0x500
  o.oFaceAngleRoll = 0x250
  o.oAction = ACT_TORNADO_SPIN
end

function mischa_tornado_loop(o)
  local m = gMarioStates[0]
  
  if (#GRABBED_OBJ.o < MISCHA_GRAB_MAX_OBJECTS) then
    for i = 0, id_bhv_max_count do 
      local object = obj_get_nearest_object_with_behavior_id(o, i)
      if object and (obj_is_grabbable(object)) or MISCHA_TORNADO_GRABBABLES[i] then
        local dist = dist_between_objects(object, o)
        
        
        if dist < (250 + 25*#GRABBED_OBJ.o) and obj_is_not_tornado_grabbed(object) == true and (m.action == ACT_MISCHA_TORNADO or m.action == ACT_MISCHA_TORNADO_AIR) then
          audio_sample_play(SOUND_GRAB, m.pos, 1)
          table.insert(GRABBED_OBJ.o, object)
					
					if get_id_from_behavior(object.behavior) == id_bhvBowser then
					  djui_chat_message_create("luigi look, it's from bowser!")
						m.actionState = TORNADO_STATE_BOWSER
						m.interactObj = object
						m.input = m.input | INPUT_INTERACT_OBJ_GRABBABLE
						mario_grab_used_object(m)
						object.oAction = 1
						
						TORNADO_GRABBED_DIST = 300
						
						if object.oSyncID ~= 0 then
                network_send_object(object, true)
            end
					else
					  TORNADO_GRABBED_DIST = 100
					end
					
        end
      end
    end
  end
	
	TORNADO_GRAB_SPIN_ACCEL = lerp(TORNADO_GRAB_SPIN_ACCEL, TORNADO_OBJ_SPIN_DIR, .3)
	
	TORNADO_GRAB_SPIN_TIMER = TORNADO_GRAB_SPIN_TIMER + TORNADO_GRAB_SPIN_ACCEL
	
    
    for c = 1, MISCHA_GRAB_MAX_OBJECTS do
      local obj = GRABBED_OBJ.o[c]
      if obj then
        
        GRABBED_OBJ.goalPos = {
          x = o.oPosX + (sins(TORNADO_GRAB_SPIN_TIMER*MISCHA_GRAB_SPINATO + (65535/#GRABBED_OBJ.o)*c)*(TORNADO_GRABBED_DIST + 25*#GRABBED_OBJ.o)),
          y = o.oPosY + 110 + math.random(-100, 25*#GRABBED_OBJ.o),
          z = o.oPosZ + (coss(TORNADO_GRAB_SPIN_TIMER*MISCHA_GRAB_SPINATO + (65535/#GRABBED_OBJ.o)*c)*(TORNADO_GRABBED_DIST + 25*#GRABBED_OBJ.o))
        }
        
        obj.oVelY = 0
        obj.oInteractStatus = INT_STATUS_INTERACTED
        if (obj_has_behavior_id(obj, id_bhvKingBobomb) ~= 0) then
            obj.oAction = 4
            table.remove(GRABBED_OBJ.o, c)
          end
				if get_id_from_behavior(obj.behavior) ~= id_bhvBowser then	
          obj.oPosX = lerp(obj.oPosX, GRABBED_OBJ.goalPos.x, MISCHA_GRAB_OBJECT_SLEERP)
          obj.oPosY = lerp(obj.oPosY, GRABBED_OBJ.goalPos.y, MISCHA_GRAB_OBJECT_SLEERP/2)
          obj.oPosZ = lerp(obj.oPosZ, GRABBED_OBJ.goalPos.z, MISCHA_GRAB_OBJECT_SLEERP)
				else
				  obj.oPosX = GRABBED_OBJ.goalPos.x
					obj.oPosY = m.pos.y + 50
				  obj.oPosZ = GRABBED_OBJ.goalPos.z
				  obj.oFaceAngleYaw = atan2s(m.pos.z - obj.oPosZ, m.pos.x - obj.oPosX) + 0x8000
				end
        
        if (obj.activeFlags == ACTIVE_FLAG_DEACTIVATED) then
          table.remove(GRABBED_OBJ.o, c)
        end
        
      end
    end
  
  o.oPosX = m.pos.x
  o.oPosY = m.pos.y
  o.oPosZ = m.pos.z
  
  o.oFaceAngleYaw = o.oFaceAngleYaw + 0x1000
  
  if (m.action ~= ACT_MISCHA_TORNADO and m.action ~= ACT_MISCHA_TORNADO_AIR) then
    o.oAction = ACT_TORNADO_DISAPPEAR
    end
  
  if (o.oAction == ACT_TORNADO_DISAPPEAR) then
    o.header.gfx.scale.x = lerp(o.header.gfx.scale.x, 0, 0.2)
    o.header.gfx.scale.z = lerp(o.header.gfx.scale.z, 0, 0.2)
    o.header.gfx.scale.y = lerp(o.header.gfx.scale.y, 0, 0.05)
      
    for i = 1, MISCHA_GRAB_MAX_OBJECTS + 1 do
      GRABBED_OBJ.o[i] = nil
    end
  else
    o.header.gfx.scale.x = lerp(o.header.gfx.scale.x, INTENDED_TORNADO_WIDTH + .0175*#GRABBED_OBJ.o, 0.1)
    o.header.gfx.scale.y = lerp(o.header.gfx.scale.y, INTENDED_TORNADO_HEIGHT + .005*#GRABBED_OBJ.o, 0.1)
    o.header.gfx.scale.z = lerp(o.header.gfx.scale.z, INTENDED_TORNADO_WIDTH + .0175*#GRABBED_OBJ.o, 0.1) 
  end
  
  if (o.header.gfx.scale.x < 0.001) then
    obj_mark_for_deletion(o)
    end
  
end

id_bhvMischaTornado = hook_behavior(bhvMischaTornado, OBJ_LIST_DEFAULT, false, mischa_tornado_init, mischa_tornado_loop)