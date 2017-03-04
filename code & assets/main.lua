--[[

Copyright (c) 2017 Stylianos Tsiakalos

This file is part of GSS 6473

 GSS 6473 is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 GSS 6473 is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with GSS 6473.  If not, see <http://www.gnu.org/licenses/>.

--]]

highscore = require("highscores")

function love.load()

	--MODELS,SOUNDS,FONTS.--
	player_model = love.graphics.newImage("ASSETS/art/battleship.png")
	player_width,player_height = player_model:getDimensions()
	SCALING_FACTOR = 0.85
	PLAYER_SCALING_FACTOR = 0.8
	--SCALING_FACTOR = 0.663
	--PLAYER_SCALING_FACTOR = 0.625
	--recommended player_scaling/other_Scaling ratio : 1.06
	player_width = player_width*SCALING_FACTOR
	player_height = player_height*SCALING_FACTOR
	default_player_model = true --change to false if model is changed!

	if(default_player_model) then
		laser_beam_x_correction = player_width/2
		laser_beam_y_correction = 0 
		collision_x_correction = player_width/5
		collision_y_correction = 0
	else
		--input appropriate correction values,if needed
		laser_beam_x_correction = 0
		laser_beam_y_correction = 0 
		collision_x_correction = 0
		collision_y_correction = 0
	end
	laser_model = love.graphics.newImage("ASSETS/art/laserbeam2.jpg")
	laser_model2 = love.graphics.newImage("ASSETS/art/laserbeam3.jpg")
	space_background = love.graphics.newImage("ASSETS//art/space.jpg")
	enemy_model = love.graphics.newImage("ASSETS/art/alienship2.png")
	enemy_model2 = love.graphics.newImage("ASSETS/art/alienship1.png")
	asteroid_model = love.graphics.newImage("ASSETS/art/asteroid.png")

	laser_sound = love.audio.newSource("ASSETS/sfx/Laser_Shoot9.wav","static")
	enemy_destr_sound = love.audio.newSource("ASSETS/sfx/explosion.wav","static")
	pause_sound = love.audio.newSource("ASSETS/sfx/pause.wav","static")
	selection_sound = love.audio.newSource("ASSETS/sfx/Blip_Select.wav","static")
	gameover_sound = love.audio.newSource("ASSETS/sfx/atari_boom.wav","static")
	asteroid_hit_sound = love.audio.newSource("ASSETS/sfx/rock_hit.wav","static")

	game_font = love.graphics.newFont("ASSETS/fonts/Xolonium-Regular.otf",15)
	mainmenu_font = love.graphics.newFont("ASSETS/fonts/nulshock_bd.ttf",45)
	mainmenu_font_small = love.graphics.newFont("ASSETS/fonts/nulshock_bd.ttf",25)
	highscore_and_controls_font = love.graphics.newFont("ASSETS/fonts/nulshock_bd.ttf",17)
	about_font = love.graphics.newFont("ASSETS/fonts/Xolonium-Regular.otf",20)
	about_font_small = love.graphics.newFont("ASSETS/fonts/Xolonium-Regular.otf",10)

	--HIGHSCORE LIBRARY
	WHERE = love.filesystem.getIdentity()
	print(WHERE)
	highscore.set("hscores.txt",10)
	

	--

	--DIMENSIONS--
	laser_width = laser_model:getDimensions()
	enemy_width,enemy_height = enemy_model:getDimensions()
	enemy2_width,enemy2_height = enemy_model2:getDimensions()
	asteroid_width,asteroid_height = asteroid_model:getDimensions()
	
	laser_width = laser_width*SCALING_FACTOR
	enemy_width = enemy_width*SCALING_FACTOR
	enemy_height = enemy_height*SCALING_FACTOR
	enemy2_width = enemy2_width *SCALING_FACTOR
	enemy2_height = enemy2_height*SCALING_FACTOR
	asteroid_width = asteroid_width*SCALING_FACTOR
	asteroid_height = asteroid_height*SCALING_FACTOR
	--

	--INITIALIZATION--
	--love.window.setFullscreen(true)
	s_width = 1024
	s_height = 650
	--s_width = 800
	--s_height = 600
	love.window.setMode(s_width,s_height)
	love.window.setTitle("GSS 6473")

	--enemy unit velocities (in terms of seconds to reach bottom)--
	enemy_seconds = 2
	asteroid_seconds = 3
	enemy_velocity = s_height / enemy_seconds
	asteroid_velocity = s_height / asteroid_seconds

	--player velocity (in terms of seconds to reach from one side to the other)
	playermodel_seconds = 1.93
	player_velocity = s_width / playermodel_seconds

	
	xx = s_width/2.0
	yy = s_height/2.0
	pause_sound:setVolume(0.5)
	laser_sound:setVolume(0.2)
	enemy_destr_sound:setVolume(0.3)
	selection_sound:setVolume(0.4)
	asteroid_hit_sound:setVolume(0.8)

	initialization() --for variables that may be repeatedly initialized
	
end

function initialization()
	accuracy = 0
	shots_hit = 0
	shots_fired_count = 0
	final_score = 0
	shots_fired = {}
	enemies = {}
	player_object = {}
	player_object.x = xx
	player_object.y = yy
	red_beam = false
	time_begin = love.timer.getTime()
	time_interval = 1 --how many seconds till next enemy spawns.
	enemy_created = false
	time_of_creation = nil
	score = 0
	second_passed_start = love.timer.getTime()
	second_passed_check = nil
	paused = false
	diff_level = 1
	diff_level_timer_start = love.timer.getTime()
	game_time_seconds = 0
	game_time_minutes = 0
	starting_menu = true
	pause_menu = false
	highscore_screen = false
	controls_screen = false
	gameover_screen = false
	about_screen = false
	selection_id = 1
end

function love.update(dt)

	if(starting_menu == true)then

		love.graphics.setFont(mainmenu_font)
		--starting_menu = false
	
	elseif(not gameover_screen) then
		if(paused == false) then



			--player movement 
			if(love.keyboard.isDown("up") or love.keyboard.isDown("w")) and yy>0 then
				yy = yy - player_velocity*dt
			elseif (love.keyboard.isDown("down") or love.keyboard.isDown("s")) and yy<s_height-player_height then
				yy = yy + player_velocity*dt
			elseif (love.keyboard.isDown("right") or love.keyboard.isDown("d")) and xx<s_width-player_width then
				xx = xx + player_velocity*dt
			elseif (love.keyboard.isDown("left") or love.keyboard.isDown("a")) and xx>0 then
				xx = xx - player_velocity*dt
			end
			--

			player_object.y = yy
			player_object.x = xx

			--adjust score,game time and accuracy meter
			second_passed_check = love.timer.getTime() - second_passed_start
			if(second_passed_check >=1) then
				score = score + 1
				game_time_seconds = game_time_seconds + 1
				if(game_time_seconds == 60) then
					game_time_seconds = 0
					game_time_minutes = game_time_minutes + 1
				end
				second_passed_start = love.timer.getTime()
			end
			if(shots_fired_count > 0) then
				accuracy = shots_hit / shots_fired_count
				accuracy = round(accuracy,2)
			end
			--

			--adjust difficulty level
			diff_level_timer_check = love.timer.getTime() - diff_level_timer_start
			if(diff_level == 1) then
				if(diff_level_timer_check >= 1*60) then
					diff_level = 2
					time_interval = 0.6
				end
			elseif(diff_level == 2) then
				if(diff_level_timer_check >= (2.5*60)) then
					diff_level = 3
					time_interval = 0.4
				end
			elseif(diff_level == 3) then
				if(diff_level_timer_check >= (5*60)) then
					diff_level = 4
					time_interval = 0.2
				end
			elseif(diff_level == 4) then
				if(diff_level_timer_check >= (10*60)) then
					diff_level = 5
					time_interval = 0.1
				end
			end
			--


			--laser beam
			for i,v in ipairs(shots_fired) do
				v.y = v.y - v.speed*dt
				if(v.y < 0 ) then
					table.remove(shots_fired,i)
				end
			end
			--

			--enemy/asteroid movement
			for i,v in ipairs(enemies) do
				v.y = v.y + v.speed*dt
				if(v.y > s_height ) then
					table.remove(enemies,i)
				end
			end
			--

			--check for collisions
			beam_enemy_coll,beam_asteroid_coll,enemy_player_coll,asteroid_player_coll,index1,index2 = collisionManagement()

			--do the appropriate actions after the check
			if(beam_enemy_coll == true) then
				love.audio.rewind(enemy_destr_sound)
				love.audio.play(enemy_destr_sound)
				table.remove(shots_fired,index1)
				table.remove(enemies,index2)
				score = score + 10
			end

			if(beam_asteroid_coll == true) then

				if(enemies[index2].hp > 1) then
					enemies[index2].hp = enemies[index2].hp - 1
					love.audio.rewind(asteroid_hit_sound)
					love.audio.play(asteroid_hit_sound)
					table.remove(shots_fired,index1)
				else
					love.audio.rewind(enemy_destr_sound)
					love.audio.play(enemy_destr_sound)
					table.remove(shots_fired,index1)
					table.remove(enemies,index2)
					score = score + 20
				end
			end

			if(enemy_player_coll or asteroid_player_coll) then
				love.audio.play(gameover_sound)
				gameover_screen = true
				if(shots_hit >=200) then
					final_score = score + accuracy*score
				else
					final_score = score
				end
				final_score = math.floor(final_score)
				highscore.add('-',final_score)
				highscore.save()
			end
			--


			--non-player objects creation
			if(enemy_created == true) then
				temp_time = love.timer.getTime() - time_of_creation
				if(temp_time >= 0.01) then
					enemy_created = false
				end
			end
			
			time_current = love.timer.getTime() - time_begin

			if(time_current >= time_interval) and enemy_created == false then
				table.insert(enemies,findFirstFreeIndex(enemies),createEnemy())
				enemy_created = true
				time_of_creation = love.timer.getTime()
				time_begin = love.timer.getTime()
			end
			--


		end
	end
end

function love.keypressed(k)

	if(about_screen) then
		if(k == "return") then
			about_screen = false
			love.graphics.reset()
			return
		end
		return
	end

	if(highscore_screen) then
		if(k == "return" or k== "space" or k == "escape") then
			highscore_screen = false
			love.graphics.reset()
			return
		end
		return
	end

	if(gameover_screen) then
		if(k == "return") then
			initialization()
			starting_menu = true
			gameover_screen = false
			return
		end
		if(k == "q") then
			highscore.save()
			love.event.quit()
		end
		return
	end

	if(paused) then

		if(k == "escape" or k == "p" or k == "return") then
			paused = false
			love.audio.rewind(pause_sound)
			love.audio.play(pause_sound)
			return
		elseif(k == "m") then
			love.graphics.reset()
			initialization()
		elseif(k == "q") then
			highscore.save()
			love.event.quit()
		end
		return
	end

	if(starting_menu) then
		if(controls_screen) then
			if(k == "return") then
				controls_screen = false
			end
			return
		end

		if(k == "down") then
			love.audio.rewind(selection_sound)
			love.audio.play(selection_sound)
			selection_id = selection_id + 1
			if(selection_id == 6) then
				selection_id = 1
			end
		end

		if(k == "up") then
			love.audio.rewind(selection_sound)
			love.audio.play(selection_sound)
			selection_id = selection_id - 1
			if(selection_id == 0) then
				selection_id = 5
			end
		end

		if(k == "return") then
			if(selection_id == 1) then
				starting_menu = false
				love.graphics.reset()
				love.graphics.setFont(game_font)
			elseif(selection_id == 5) then
				highscore.save()
				love.event.quit()
			elseif(selection_id == 2) then
				highscore_screen = true
			elseif(selection_id == 3) then
				controls_screen = true
			elseif(selection_id == 4) then
				about_screen = true
			end
		end
	else
		if (k == "escape" or k=="p") then
			paused = true
			love.audio.rewind(pause_sound)
			love.audio.play(pause_sound)
		end

		if(starting_menu == false) then
			if(k == "space") then
				if(not paused) then
					shots_fired_count = shots_fired_count + 1
					table.insert(shots_fired,findFirstFreeIndex(shots_fired),createLaserBeam(xx,yy))
					love.audio.rewind(laser_sound)
					love.audio.play(laser_sound)
				end
			end

		end
	end

end

function love.draw()
	
	love.graphics.draw(space_background)

	if(about_screen) then
		love.graphics.setColor(0,255,0,255)
		love.graphics.setFont(about_font)
		love.graphics.printf("Original Game Code & Design -> Stelios Tsiakalos",0,s_height/4.5,s_width,'center')
		love.graphics.printf("Contributors -> [Your name here!]",0,s_height/3.6,s_width,'center')
		love.graphics.printf("Assets (art,fonts,sounds,etc) -> See 'ATTRIBUTIONS.txt'",0,s_height/3.0,s_width,'center')
		love.graphics.printf("Press Enter to return to the main menu",0,s_height/2.0,s_width,'center')
		love.graphics.setFont(about_font_small)
		love.graphics.printf("Copyright (C) 2017 Stylianos Tsiakalos",0,s_height - s_height/8.0,s_width,'center')
		love.graphics.setColor(0,0,255,255)
		return
	end

	if(gameover_screen) then
		love.graphics.setFont(mainmenu_font_small)
		love.graphics.setColor(255,0,0,255)
		love.graphics.printf("---G A M E  O V E R---",0,s_height/4.0,s_width,'center')
		love.graphics.printf("Your score : ",0,s_height/2.5,s_width,'center')
		love.graphics.printf(score,0,s_height/2.25,s_width,'center')
		if(shots_hit >= 200) then
			love.graphics.printf("Accuracy bonus* :",0,s_height/2.0,s_width,'center')
			love.graphics.printf(math.floor(accuracy*score),0,s_height/1.85	,s_width,'center')
			love.graphics.printf("FINAL SCORE : ",0,s_height/1.55,s_width,'center')
			love.graphics.printf(math.floor(score+accuracy*score),0,s_height/1.45,s_width,'center')
		else
			love.graphics.printf("Accuracy bonus* :",0,s_height/2.0,s_width,'center')
			love.graphics.printf("0",0,s_height/1.85,s_width,'center')
			love.graphics.printf("FINAL SCORE : ",0,s_height/1.55,s_width,'center')
			love.graphics.printf(score,0,s_height/1.45,s_width,'center')
		end
		love.graphics.setFont(highscore_and_controls_font)
		love.graphics.printf("Enter -> Main Menu",0,s_height/1.3,s_width,'center')
		love.graphics.printf("Q -> Exit Game",0,s_height/1.2,s_width,'center')
		love.graphics.setFont(about_font_small)
		love.graphics.printf("*Accuracy bonus is only applied when you have 200 hits or more.",0,s_height/1.7,s_width,'center')
		love.graphics.printf("Hit count : ",0,s_height/1.65,s_width,'center')
		love.graphics.printf(shots_hit,0,s_height/1.65,s_width+85,'center')
		love.graphics.setColor(0,0,255,255)
		return
	end
	if(starting_menu) then

		if(highscore_screen) then
			love.graphics.setColor(0,255,0,255)
			love.graphics.setFont(mainmenu_font_small)
			love.graphics.printf("HIGHSCORES",0,100,s_width,'center')
			love.graphics.setFont(highscore_and_controls_font)
			for i, score, name in highscore() do
    			love.graphics.printf(math.floor(score),0, 100+i*40, s_width,'center')
			end
			love.graphics.setColor(0,0,255,255)
			return

		end

		if(controls_screen) then
			love.graphics.setColor(0,255,0,255)
			love.graphics.setFont(mainmenu_font_small)
			love.graphics.printf("CONTROLS",0,100,s_width,'center')
			love.graphics.setFont(highscore_and_controls_font)
			love.graphics.printf("P/ESC -> Pause Menu",0,250,s_width,'center')
			love.graphics.printf("W/A/S/D OR arrow keys -> Movement",0,300,s_width,'center')
			love.graphics.printf("SPACE -> FIRE",0,350,s_width,'center')
			love.graphics.printf("Press Enter to return to the main menu",0,450,s_width,'center')
			love.graphics.setColor(0,0,255,255)
			return
		end

		love.graphics.setFont(mainmenu_font)
		love.graphics.setColor(0,255,0,255)
		love.graphics.printf("GSS 6473",0,100,s_width,'center')
		love.graphics.setFont(mainmenu_font_small)
		if(selection_id == 1) then
			love.graphics.setColor(255,255,255,255)
			love.graphics.printf("{Start Game}",0,s_height/3.0,s_width,'center')
			love.graphics.setColor(0,255,0,255)
		else
			love.graphics.printf("Start Game",0,s_height/3.0,s_width,'center')
		end
		if(selection_id == 2) then
			love.graphics.setColor(255,255,255,255)
			love.graphics.printf("{Highscores}",0,(s_height/3.0)+30,s_width,'center')
			love.graphics.setColor(0,255,0,255)
		else
			love.graphics.printf("Highscores",0,(s_height/3.0)+30,s_width,'center')
		end
		if(selection_id == 3) then
			love.graphics.setColor(255,255,255,255)
			love.graphics.printf("{Controls}",0,(s_height/3.0)+60,s_width,'center')
			love.graphics.setColor(0,255,0,255)
		else
			love.graphics.printf("Controls",0,(s_height/3.0)+60,s_width,'center')
		end
		if(selection_id == 4) then
			love.graphics.setColor(255,255,255,255)
			love.graphics.printf("{About}",0,(s_height/3.0)+90,s_width,'center')
			love.graphics.setColor(0,255,0,255)
		else
			love.graphics.printf("About",0,(s_height/3.0)+90,s_width,'center')
		end
		if(selection_id == 5) then
			love.graphics.setColor(255,255,255,255)
			love.graphics.printf("{Exit}",0,(s_height/3.0)+120,s_width,'center')
			love.graphics.setColor(0,255,0,255)
		else
			love.graphics.printf("Exit",0,(s_height/3.0)+120,s_width,'center')
		end

		love.graphics.setColor(0,0,255,255)
		
	else
		
		love.graphics.setColor(100,255,255,255)
		love.graphics.draw(player_model,xx,yy,0,SCALING_FACTOR,SCALING_FACTOR)
		love.graphics.setColor(255,255,255,255)


		love.graphics.setColor(0,255,0,255)
		love.graphics.print("SCORE",0,0)
		love.graphics.print(score,0,15)

		love.graphics.print("GAME TIME",0,40)
		love.graphics.print(game_time_minutes,0,55)
		love.graphics.print(":",20,55)
		love.graphics.print(game_time_seconds,30,55)

		love.graphics.print("LEVEL",2,90)
		love.graphics.print(diff_level,0,105)
		if(diff_level == 5) then
			love.graphics.print("(MAX)",15,105)
		end

		love.graphics.print("ACCURACY",0,140)
		love.graphics.print(100*accuracy,0,155)
		love.graphics.print("%",35,155)

		
		love.graphics.print("P/ESC : pause menu",s_width-180,s_height-25)
		love.graphics.setFont(game_font)

		if(paused == true) then
			love.graphics.printf("PAUSED",0,s_height/2.5,s_width,'center')
			love.graphics.printf("P/Enter/ESC -> Continue",0,s_height/2.0,s_width,'center')
			love.graphics.printf("m -> Main Menu",0,s_height/1.75,s_width,'center')
			love.graphics.printf("q -> Exit Game",0,s_height/1.6,s_width,'center')

		end

		love.graphics.reset()
		love.graphics.setFont(game_font)

		for i,v in ipairs(shots_fired) do
			love.graphics.draw(v.image,v.x,v.y,0,SCALING_FACTOR,SCALING_FACTOR)
		end

		for i,v in ipairs(enemies) do
			--
			if(v.type == "spaceship") then
				if(v.image == enemy_model) then
					love.graphics.setColor(255,100,200,255)
				else
					love.graphics.setColor(255,200,255,255)
				end
			
			else
				love.graphics.setColor(255,255,255,255)
			end
			love.graphics.draw(v.image,v.x,v.y,0,SCALING_FACTOR,SCALING_FACTOR)
			
		end
		love.graphics.setColor(255,255,255,255)
	end

end

function createEnemy()
	local new_enemy = {}
	new_enemy.x = math.random(0,s_width-100)
	new_enemy.y = -200
	
	local enemy_id = math.random(0,14)
	if(enemy_id == 0) then
		new_enemy.image = asteroid_model
		new_enemy.type = "asteroid"
		new_enemy.speed = asteroid_velocity
		new_enemy.hp = 2
	else
		enemy_id_2 = math.random(0,2)
		if(enemy_id_2 == 0) then
			new_enemy.image = enemy_model
		else
			new_enemy.image = enemy_model2
		end
		new_enemy.type = "spaceship"
		new_enemy.speed = enemy_velocity
	end
	return new_enemy
end

function createLaserBeam(player_x,player_y)
	local beam = {}
	beam.x = player_x + laser_beam_x_correction
	beam.y = player_y + laser_beam_y_correction
	beam.speed = 1000
	if(red_beam == true) then
		beam.image = laser_model
		red_beam = false
	elseif(red_beam == false) then
		beam.image = laser_model2
		red_beam = true
	end
	return beam
end

function collisionManagement()

	-- beam-enemy
	local index1 = nil
	local index2 = nil
	local beam_enemy_collision = false
	local beam_asteroid_collision = false
	local enemy_player_collision = false
	local asteroid_player_collision = false

	for i=1,getSize(shots_fired),1 do
		for j=1,getSize(enemies),1 do
			if(enemies[j].image == enemy_model or enemies[j].image == enemy_model2) then
				if(shots_fired[i].y - (enemies[j].y + enemy_height) <= 0.1) then
					if(shots_fired[i].x >= enemies[j].x and shots_fired[i].x <= enemies[j].x+enemy_width ) or ( (shots_fired[i].x+laser_width) >= enemies[j].x and (shots_fired[i].x+laser_width) <= enemies[j].x+enemy_width) then
						index1 = i
						index2 = j
						beam_enemy_collision = true
						shots_hit = shots_hit + 1
						return beam_enemy_collision,beam_asteroid_collision,enemy_player_collision,asteroid_player_collision,index1,index2
					end
				end
			elseif(enemies[j].image == asteroid_model) then
				if(shots_fired[i].y - (enemies[j].y + asteroid_height) <= 0.1) then
					if(shots_fired[i].x >= enemies[j].x and shots_fired[i].x <= enemies[j].x+asteroid_width ) or (shots_fired[i].x+laser_width >= enemies[j].x and shots_fired[i].x+laser_width <= enemies[j].x+asteroid_width) then
						index1 = i
						index2 = j
						beam_asteroid_collision = true
						shots_hit = shots_hit + 1
						return beam_enemy_collision,beam_asteroid_collision,enemy_player_collision,asteroid_player_collision,index1,index2
					end
				end
			end
		end
	end

	for i=1,getSize(enemies),1 do
		if(enemies[i].image == enemy_model) then
			enemy_player_collision = checkCollision(player_object.x+collision_x_correction,player_object.y+collision_y_correction,player_width-collision_x_correction,player_height-collision_y_correction,enemies[i].x,enemies[i].y,enemy_width,enemy_height)
		elseif(enemies[i].image == enemy_model2) then
			enemy_player_collision = checkCollision(player_object.x+collision_x_correction,player_object.y+collision_y_correction,player_width-collision_x_correction,player_height-collision_y_correction,enemies[i].x,enemies[i].y,enemy2_width,enemy2_height)
		elseif(enemies[i].image == asteroid_model) then
			asteroid_player_collision = checkCollision(player_object.x+collision_x_correction,player_object.y+collision_y_correction,player_width-collision_x_correction,player_height-collision_y_correction,enemies[i].x,enemies[i].y,asteroid_width,asteroid_height)
		end
		if(enemy_player_collision or asteroid_player_collision) then
			return beam_enemy_collision,beam_asteroid_collision,enemy_player_collision,asteroid_player_collision,index1,index2
		end

	end


end

function findFirstFreeIndex(tabl)

	i = 0
	repeat
		i = i + 1
	until tabl[i] == nil
	return i
end

function getSize(tabl)

	if tabl[1] == nil then
		return 0
	else
		size = 0
		repeat
			size = size + 1
		until tabl[size] == nil
		size = size - 1
		return size
	end
end

-- Collision detection function (used for the player-asteroid and player-enemy cases)
-- Returns true if two boxes overlap, false if they don't
-- x1,y1 are the left-top coords of the first box, while w1,h1 are its width and height
-- x2,y2,w2 & h2 are the same, but for the second box
function checkCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  

  return x1 < x2+w2 and x2 < x1+w1 and y1 < y2+h2 and y2 < y1+h1         
         
end

function round(num,numDecimalPlaces)

	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num*mult+0.5) / mult

end

