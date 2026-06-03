MISCHA_CAM = false
MODE_REGULAR = 0
MODE_ROTATE_ALONG_ITSELF = 1
MODE_STAY_IN_PLACE = 2
MODE_FIRST_PERSON = 3
IS_FREECAM = camera_config_is_free_cam_enabled()

cam = {
  focus = {
    x = 0,
    y = 0,
    z = 0
  },
  pos = {
    x = 0,
    y = 0,
    z = 0
  },
  intendedFocus = {
    x = 0,
    y = 0,
    z = 0
  },
  intendedPos = {
    x = 0,
    y = 0,
    z = 0
  },
  yaw = 0x0,
  pitch = 0x0,
  outward = 750,
  maxOutward = 3000,
  mode = MODE_REGULAR,
  fov = 65,
  sleerp = 0.15,
  speedato = 0x400,
}


function updateCam()
  if charSelect.get_options_status(MISCHA_KOFECAM) == 0 then
    camera_unfreeze()
    camera_config_enable_free_cam(IS_FREECAM)
    return end
  
  if (MISCHA_DIALOG == true or gMarioStates[0].action == ACT_FIRST_PERSON) then return end
  
  cam.maxOutward = 2000 + 25*#GRABBED_OBJ.o
  
  m = gMarioStates[0]
  cont = m.controller
  l = gLakituState
  
  camera_config_enable_free_cam(false)
  
  if (m.area.camera and m.area.camera.cutscene ~= 0 and (m.action & ACT_GROUP_MASK ~= ACT_GROUP_CUTSCENE)) then
    camera_unfreeze()
  else
    camera_freeze()
  end
  

  if ((m.action == ACT_MISCHA_SWIM and m.actionArg == MISCHA_SWIM_STATE_SURFACE) or m.action ~= ACT_MISCHA_SWIM) and m.action ~= ACT_MISCHA_KART then
    
    cam.intendedFocus = 
    {x = m.pos.x + m.vel.x*1.25, 
    y = m.pos.y + 150 + m.vel.y*1.25, 
    z = m.pos.z + m.vel.z*1.25
    }
  cam.intendedPos = {
    x = m.pos.x + sins(cam.yaw)*cam.outward,
    y = m.pos.y + cam.outward/2,
    z = m.pos.z + coss(cam.yaw)*cam.outward
  }
  
    
    if cont.buttonDown & L_CBUTTONS ~= 0 then
      if (cam.mode == MODE_REGULAR) then
        cam.yaw = cam.yaw - cam.speedato
      end
      
      if (cam.mode == MODE_ROTATE_ALONG_ITSELF) then
        cam.intendedFocus.x = cam.pos.x + sins(cam.yaw - 0x6000)*100
        cam.intendedFocus.y = cam.pos.y
        cam.intendedFocus.z = cam.pos.z + coss(cam.yaw - 0x6000)*100
      end
      
    end
    if cont.buttonDown & R_CBUTTONS ~= 0 then
      if (cam.mode == MODE_REGULAR) then
        cam.yaw = cam.yaw + cam.speedato
      end
      
      if (cam.mode == MODE_ROTATE_ALONG_ITSELF) then
        cam.intendedFocus.x = cam.intendedPos.x + sins(cam.yaw + 0x6000)*100
        cam.intendedFocus.y = cam.intendedPos.y
        cam.intendedFocus.z = cam.intendedPos.z + coss(cam.yaw + 0x6000)*100
      end
    end
    
    if (double_tap(m.controller, D_CBUTTONS) ~= 0) then
      if (cont.stickMag > 0) then
        cam.yaw = m.intendedYaw + 0x8000
      else
        cam.yaw = m.faceAngle.y + 0x8000
      end
      cam.outward = cam.outward - 275
    end
    
    if (double_tap(m.controller, U_CBUTTONS) ~= 0) then
      assert(1 > 3, "GET BACK TO WORK")
      set_mario_action(m, ACT_FIRST_PERSON, 0)
    end
    
    if (cont.buttonDown & R_TRIG ~= 0 and MOVING_VEL == 0) then
      cam.mode = MODE_ROTATE_ALONG_ITSELF
    else
      cam.mode = MODE_REGULAR
    end
  else
    cam.intendedFocus = 
    {
      x = m.pos.x + m.vel.x*1.25, 
    y = m.pos.y + m.vel.y*1.25 + 50, 
    z = m.pos.z + m.vel.z*1.25
    }
  cam.intendedPos = {
    x = m.pos.x + (sins(m.faceAngle.y)*-cam.outward)*coss(m.faceAngle.x),
    y = m.pos.y + sins(m.faceAngle.x)*-cam.outward,
    z = m.pos.z + (coss(m.faceAngle.y)*-cam.outward)*coss(m.faceAngle.x)
  }
  cam.yaw = m.faceAngle.y +0x8000
  end
  
  if cont.buttonDown & U_CBUTTONS ~= 0 then
      if (cam.mode == MODE_REGULAR) then
      cam.outward = math.lerp(cam.outward, 500, cam.sleerp/2)
      end
      
      if (cam.mode == MODE_ROTATE_ALONG_ITSELF) then
        cam.intendedFocus.x = cam.pos.x + sins(cam.yaw)*-30
        cam.intendedFocus.y = cam.pos.y + 50
        cam.intendedFocus.z = cam.pos.z + coss(cam.yaw)*-30
      end
    end
    if cont.buttonDown & D_CBUTTONS ~= 0 then
      if (cam.mode == MODE_REGULAR) then
      cam.outward = math.lerp(cam.outward, cam.maxOutward, cam.sleerp/2)
      end
      
      if (cam.mode == MODE_ROTATE_ALONG_ITSELF) then
        cam.intendedFocus.x = cam.pos.x + sins(cam.yaw)*-30
        cam.intendedFocus.y = cam.pos.y - 50
        cam.intendedFocus.z = cam.pos.z + coss(cam.yaw)*-30
      end
    end
  
  if ((m.action == ACT_MISCHA_SWIM and m.actionArg == MISCHA_SWIM_STATE_SURFACE) or m.action ~= ACT_MISCHA_SWIM) then
    camColl = collision_find_surface_on_ray(
    m.pos.x, 
    m.pos.y + 100, 
    m.pos.z,
    sins(cam.yaw)*(cam.outward - 100),
    (cam.outward - 100)/2,
    coss(cam.yaw)*(cam.outward - 100)
    )
  else
    camColl = collision_find_surface_on_ray(
    m.pos.x, 
    m.pos.y + 100, 
    m.pos.z,
    (sins(m.faceAngle.y)*-cam.outward)*coss(m.faceAngle.x),
    sins(m.faceAngle.x)*-cam.outward,
    (coss(m.faceAngle.y)*-cam.outward)*coss(m.faceAngle.x)
    )
  end
    
    if camColl.hitPos then
      cam.intendedPos = {
        x = camColl.hitPos.x,
        y = camColl.hitPos.y,
        z = camColl.hitPos.z
      }
    end
    
  
  cam.focus = {
    x = math.lerp(cam.focus.x, cam.intendedFocus.x, cam.sleerp*3),
    y = math.lerp(cam.focus.y, cam.intendedFocus.y, cam.sleerp),
    z = math.lerp(cam.focus.z, cam.intendedFocus.z, cam.sleerp*3)
  }
  
  cam.pos = {
    x = math.lerp(cam.pos.x, cam.intendedPos.x, cam.sleerp),
    y = math.lerp(cam.pos.y, cam.intendedPos.y, cam.sleerp/2),
    z = math.lerp(cam.pos.z, cam.intendedPos.z, cam.sleerp)
  }
  
  vec3f_copy(l.pos, cam.pos)
  vec3f_copy(l.focus, cam.focus)
  
  if (m.area.camera) then
    m.area.camera.yaw = atan2s(cam.pos.z - cam.focus.z, cam.pos.x - cam.focus.x)
    vec3f_set(m.area.camera.pos, m.pos.x, m.pos.y, m.pos.z)
  end
end