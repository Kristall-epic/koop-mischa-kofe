
score = 0
highscore = mod_storage_load_integer("MISCHA_TETRIS_SCORE")

SCORE_PER_LINE = 80

SHAPE_T = 5
SHAPE_I = 7
SHAPE_O = 1
SHAPE_L = 2
SHAPE_J = 3
SHAPE_Z = 4
SHAPE_S = 6
SHAPE_MAX = 8

COLOR_RED = 1
COLOR_YELLOW = 2
COLOR_GREEN = 3
COLOR_BLUE = 4
COLOR_ORANGE = 5
COLOR_PURPLE = 6
COLOR_CYAN = 7

actualColors = {
  [COLOR_RED] = {255, 4, 4},
	[COLOR_YELLOW] = {225, 225, 4},
	[COLOR_GREEN] = {4, 255, 4},
	[COLOR_BLUE] = {4, 4, 255},
	[COLOR_ORANGE] = {255, 128, 4},
	[COLOR_PURPLE] = {255, 4, 255},
	[COLOR_CYAN] = {128, 128, 255}
}

nextShape = math.random(1, SHAPE_MAX - 1)

--rot [i][j] = [j][2 - i]

collision = {

  [SHAPE_T] = {
	  {0, 0, 0, 0},
		{0, 6, 6, 6},
		{0, 0, 6, 0},
		{0, 0, 0, 0}
	},
	
	[SHAPE_I] = {
	  {0, 0, 7, 0},
		{0, 0, 7, 0},
		{0, 0, 7, 0},
		{0, 0, 7, 0}
	},
	
	[SHAPE_O] = {
	  {0, 0, 0, 0},
		{0, 2, 2, 0},
		{0, 2, 2, 0},
		{0, 0, 0, 0}
	},
	
	[SHAPE_L] = {
	  {0, 5, 0, 0},
		{0, 5, 0, 0},
		{0, 5, 5, 0},
		{0, 0, 0, 0}
	},
	
	[SHAPE_J] = {
	  {0, 0, 4, 0},
		{0, 0, 4, 0},
		{0, 4, 4, 0},
		{0, 0, 0, 0}
	},
	
	[SHAPE_S] = {
	  {0, 0, 0, 0},
		{0, 0, 3, 3},
		{0, 3, 3, 0},
		{0, 0, 0, 0}
	},
	
	[SHAPE_Z] = {
	  {0, 0, 0, 0},
		{0, 1, 1, 0},
		{0, 0, 1, 1},
		{0, 0, 0, 0}
	},

}

canvas = {
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
}

canvasX = 0
canvasY = 0
tileW = 2
tileH = 2

tilesX = 10
tilesY = 18

curShape = {
  position = {x = 4, y = 0},
	shape = math.random(1, SHAPE_MAX - 1),
	rotation = 0
}

function spawn_shape(posX, posY, Shape)
  curShape = {
	  position = {x = posX or 0, y = posY or 0},
		shape = Shape or 1,
		color = 1
	}
end


function turn_shape(Shape)
  local coll = collision[Shape]
	local newShape = {
	  {0, 0, 0, 0},
		{0, 0, 0, 0},
		{0, 0, 0, 0},
		{0, 0, 0, 0}
	}
	
	for i = 1, 4 do
	  for j = 1, 4 do
				newShape[i][j] = coll[j][5 - i]
		end
	end
	
	collision[Shape] = newShape
	
	if check_shape_bottom_or_col(curShape.position.x, curShape.position.y) then
	  collision[Shape] = coll
	end
	
end

function check_full_rows()
  gertrude = 0

  for row = 0, tilesY - 1 do
	  curRow = canvas[tilesY - row]
		isFull = true
		isEmpty = true
	  
	  for x = 1, tilesX do
		  if curRow and curRow[x] == 0 then
			  isFull = false
			else
			  isEmpty = false
			end
		end
		
		if isFull == true then
		  gertrude = gertrude + 1
			canvas[tilesY - row] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
			score = score + SCORE_PER_LINE
		else
		  for i = 1, 10 do
				canvas[(tilesY - row) + gertrude][i] = curRow[i]
			end
		end
		
		--[[
		if isEmpty == true and not canvas[(20 - row) - gertrude] then
		  break
		end
		]]
		
	end

end

function drop_shape()
  for shapeX = 1, 4 do
		for shapeY = 1, 4 do
			if collision[curShape.shape][shapeY][shapeX] ~= 0 then
				canvas[curShape.position.y + shapeY][curShape.position.x + shapeX] = collision[curShape.shape][shapeY][shapeX]
			end
		end
	end
	
	check_full_rows()
	
	curShape = {
					position = {x = 4, y = 0},
					shape = nextShape,
					rotation = 0
				}
				
	nextShape = math.random(1, SHAPE_MAX - 1)
	
	while nextShape == curShape.shape do
	  nextShape = math.random(1, SHAPE_MAX - 1)
	end
				
	if check_shape_bottom_or_col(curShape.position.x, curShape.position.y) then
	  if score > highscore then
		  highscore = score
		end
		saveMischaScoreOnThisModAndNotCharacterSelect = true 
		
		canvas = {
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
}
	end
	
end

--returns true if the given poisition of the given shape does in fact have collision
function point_has_collision(Shape, posX, posY)
  if collision[Shape][posY][posX] ~= 0 then
	  return true
	end
end

--returns true if it touches the bottom or another piece
function check_shape_bottom_or_col(nextX, nextY)
  for shapeX = 1, 4 do
	  for shapeY = 1, 4 do
		--are you going to touch the bottom of the canvas
		  if point_has_collision(curShape.shape, shapeX, shapeY) and shapeY + nextY > tilesY then
			  return true
			end
			
		--is any of your next collisions already marked as "this has a shape piece"
			if point_has_collision(curShape.shape, shapeX, shapeY) and canvas[shapeY + nextY][shapeX + nextX] ~= 0 then
			  return true
			end
			
		end
	end
end

function get_tile_color(posX, posY)
  local tile = canvas[posY][posX]
	local color = actualColors[tile]
	
	return {r = color[1], g = color[2], b = color[3]}
end

dropTimer = 0

function shape_loop()
  local c = charSelect.controller
	
  dropTimer = dropTimer + 1
	
	if dropTimer > 15 then
	  dropTimer = 0
		if not check_shape_bottom_or_col(curShape.position.x, curShape.position.y + 1) then
			curShape.position.y = curShape.position.y + 1
		else
		  drop_shape()
		end
	end
	
	if c.buttonPressed & L_CBUTTONS ~= 0 and not check_shape_bottom_or_col(curShape.position.x - 1, curShape.position.y) then
	  curShape.position.x = curShape.position.x - 1
	end
	
	if c.buttonPressed & R_CBUTTONS ~= 0 and not check_shape_bottom_or_col(curShape.position.x + 1, curShape.position.y) then
	  curShape.position.x = curShape.position.x + 1
	end
	
	if c.buttonDown & D_CBUTTONS ~= 0 then
	  dropTimer = dropTimer + 8
	end
	
	if c.buttonPressed & U_CBUTTONS ~= 0 then
	  turn_shape(curShape.shape, 0)
	end
	
end



function render()
  djui_hud_set_resolution(RESOLUTION_N64)
	
	if charSelect.is_options_open() ~= false or charSelect.character_get_current_number() ~= CT_MISCHA then
	  mischaUI.tetris.y = lerp(mischaUI.tetris.y, 192, .1)
	else
	  mischaUI.tetris.y = lerp(mischaUI.tetris.y, 0, .1)
		shape_loop()
	end
	
	cs_tv = get_texture_info("char_select_options_tv")
	
	tileH = 2.85
	tileW = tileH
	
  canvasX = djui_hud_get_screen_width()/2 + 32
	canvasY = djui_hud_get_screen_height()/5 + tilesY*tileH + 12
	
	djui_hud_set_color(8, 8, 8, 255)
	
	djui_hud_render_rect(canvasX - 20, canvasY - 4 + mischaUI.tetris.y, 68, 64)
	
	djui_hud_reset_color()
	
	djui_hud_print_text("SCORE:\n"..score, canvasX - tileW*5 + tileW*(tilesX + 2) + 2, canvasY + tileH*4 + 2 + mischaUI.tetris.y, .2)
	
	djui_hud_print_text("HIGHSCORE:\n"..highscore, canvasX - tileW*5 + tileW*(tilesX + 2) + 2, canvasY + tileH*8 + 2 + mischaUI.tetris.y, .2)
	
	djui_hud_render_rect(canvasX - tileW*5 + tileW*(tilesX + 2) + 2, canvasY + tileH*12 + 2 + mischaUI.tetris.y, tileW*6, tileH*6)

  for x = 1, tilesX do
	  for y = 1, tilesY do
		  djui_hud_set_color(255, 255, 255, 255)
		  if canvas[y][x] ~= 0 then
			  local color = get_tile_color(x, y)
			  djui_hud_set_color(color.r, color.g, color.b, 255)
			end
				djui_hud_render_rect(canvasX - tileW*5 + tileW*x + 2, canvasY + tileH*y + 2 + mischaUI.tetris.y, tileW, tileH)
			  djui_hud_set_color(255, 255, 255, 255)
		end
	end
	
	for shapeX = 1, 4 do
			for shapeY = 1, 4 do
				if collision[curShape.shape][shapeY][shapeX] ~= 0 then
				  local color = actualColors[collision[curShape.shape][shapeY][shapeX]]
				
				  djui_hud_set_color(color[1], color[2], color[3], 255)
					djui_hud_render_rect(canvasX - tileW*5 + tileW*(curShape.position.x + shapeX) + 2, canvasY + tileH*(curShape.position.y + shapeY) + 2 + mischaUI.tetris.y, tileW, tileH)
					djui_hud_reset_color()
				end
				
				if collision[nextShape] and collision[nextShape][shapeY][shapeX] ~= 0 then
				  local color = actualColors[collision[nextShape][shapeY][shapeX]]
					
					djui_hud_set_color(color[1], color[2], color[3], 255)
					djui_hud_render_rect(canvasX - tileW*5 + tileW*(tilesX + 2 + shapeX) + 2, canvasY + tileH*(12 + shapeY) + 2 + mischaUI.tetris.y, tileW, tileH)
					djui_hud_reset_color()
				end
				
			end
		end
		
		
		djui_hud_render_texture(cs_tv, djui_hud_get_screen_width()/2 - 32, djui_hud_get_screen_height()/2 - 64 + mischaUI.tetris.y, .35, .35)
	
end

if charSelect then
  charSelect.hook_render_in_menu(render)
end