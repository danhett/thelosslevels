pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- the loss levels
-- dan hett

function _init()
	setupgameparts()
	setuptimeout()
	setupglitches()
	setupfader()
end

function setupgameparts()
	debugmode = false
	nextgame = 'games/6-roo.p8' -- SKIPPING ONE AT THE MOMENT
	line1 = "bundled into a police car."
	line2 = "lights and sirens on. go."
	success = "we arrive quickly, police\n\nand reporters everywhere."
	failure = "barely made it, police\n\nand reporters everywhere."
	col1 = 3
	col2 = 11

	flashcurrent = 0
	flashrate = 10
	flashstate = false

	messagetimer = 0
	messagelimit = 100

	car = {}
	car.x = 10
	car.y = 50
	car.xspeed = 1
	car.yspeed = 2

	enemy1 = {}
	enemy1.x = 1130
	enemy1.y = 30
	enemy1.speed = 3

	enemy2 = {}
	enemy2.x = 1200
	enemy2.y = 60
	enemy2.speed = 4

	enemy3 = {}
	enemy3.x = 1290
	enemy3.y = 70
	enemy3.speed = 5

	linepos = 50

	wincount = 0
	wintarget = 600
end

function setuptimeout()
	tcurrent = 0
	tmax = 60 * 60 -- reset timeout to return to the main menu
end

function setupfader()
	state = "waiting" -- or fadingdown or playing
	waittime = 0
	waittotal = 40
	fadedelay = 0
	fadelimit = 150

	messagetimer = 0
  messagelimit = 100

  flashcurrent = 0
  flashrate = 10
  flashstate = false

	ypos = -20
end

function setupglitches()
	glit = {}
	glit.height=128
	glit.width=128
	glit.t=0
end

function _update()
	checkinputs()
	checksuccess()
end

function _draw()
	cls(0)
	drawgame()
	checkcollisions()
	checktimeout()
	handlewinloss()
	handlefading()
	flash()
	glitch()
end


function drawgame()
	rectfill_p(0,0,128,128,14,11,3) -- background
	rectfill_p(0,30,128,90,16,0,6) -- road surface

	-- lines
	line(0,32,128,32, 7)
	line(0,33,128,33, 7)
	line(0,88,128,88, 7)
	line(0,87,128,87, 7)

	palt(0,false)
	palt(14,true)

	-- car lines
	drawlines()

	-- police car
	if flashstate then
		spr(0,car.x, car.y, 3, 2)
	else
		spr(3,car.x, car.y, 3, 2)
	end

	-- enemies
	--if state == "playing" then drawenemies() end
	drawenemies()

	-- debug
	if debugmode then
		print(wincount, 10, 10, 8)
	end
end

function drawlines()
	linepos-=10

	if linepos < -30 then
		linepos = 180
	end

	rectfill(linepos, 57, linepos+30, 59, 7)
end

function drawenemies()
	-- car one
	enemy1.x-=enemy1.speed
	if enemy1.x < -200 and state == "playing" then
		enemy1.x = 180
	end
	spr(6, enemy1.x, enemy1.y, 3, 2, true)

	-- car two
	enemy2.x-=enemy2.speed
	if enemy2.x < -60 and state == "playing" then
		enemy2.x = 200
	end
	spr(9, enemy2.x, enemy2.y, 3, 2, true)

	-- car three
	enemy3.x-=enemy3.speed
	if enemy3.x < -40 and state == "playing" then
		enemy3.x = 195
	end
	spr(12, enemy3.x, enemy3.y, 3, 2, true)
end

function checkcollisions()
	if(dst(car, enemy1) < 6 and dst(car, enemy1) > 1) state = "fail"
	if(dst(car, enemy2) < 6 and dst(car, enemy2) > 1) state = "fail"
	if(dst(car, enemy3) < 6 and dst(car, enemy3) > 1) state = "fail"

end

function dst(p0, p1)
 local dx = p0.x - p1.x
 local dy = p0.y - p1.y

 return sqrt(dx*dx+dy*dy)
end

function outline(s,x,y,c1,c2)
	for i=0,2 do
	 for j=0,2 do
	  if not(i==1 and j==1) then
	   print(s,x+i,y+j,c1)
	  end
	 end
	end
	print(s,x+1,y+1,c2)
end

function checkinputs()
	if btn(0) and car.x > 1 then
		car.x-=car.xspeed
		resettimeout()
	end

	if btn(1) and car.x < 40 then
		car.x+=car.xspeed
		resettimeout()
	end

	if btn(2) and car.y > 28 then
		car.y-=car.yspeed
		resettimeout()
	end

	if btn(3) and car.y < 70  then
		car.y+=car.yspeed
		resettimeout()
	end
end

function resettimeout()
	tcurrent = 0
end

function checktimeout()
	if tcurrent < tmax then tcurrent+=1 end

	if tcurrent == tmax then
		load('losslevels.p8')
	end
end

function handlefading()
	if state == "waiting" then
		if fadedelay < fadelimit then
			fadedelay+=1
		end

		if fadedelay == fadelimit then
			state = "fadingup"
		end

		drawmessage()
	end

	if state == "fadingup" then
		waittime+=1

		if waittime < waittotal  then
			rectfill( 0, 0, 127, 127 - (3 * waittime), 0 )
			rectfill( 127, 127, 0, 3 * waittime, 0 )
			drawmessage()
			ypos += 4
		end
	end

	if waittime == waittotal then
		if state == "fadingup" then
			state = "playing"
			waittime = 0
		end

		if state == "fadingdown" then
			load(nextgame)
		end
	end

	if state == "fadingdown" then
		waittime+=1
		rectfill( 0, 0, 127, 3 * waittime, 0 )
		rectfill( 127, 127, 0, 127 - (3 * waittime), 0 )
	end
end

function checksuccess()
	if(wincount < wintarget) wincount+=1

	if(wincount == wintarget) state = "success"
end

function handlewinloss()
	if state == "success" then
		outline(success,4,6,0,11)
		showingmessage = true
	end

	if state == "fail" then
		outline(failure,4,6,0,8)
		showingmessage = true
	end

	if showingmessage then
		messagetimer+=1
		if(messagetimer >= messagelimit) state = "fadingdown"
	end
end

function drawmessage()
	-- draw shutters
	rectfill( 0, 0, 127, 127 - (3 * waittime), 0 )
	rectfill( 127, 127, 0, 3 * waittime, 0 )

	-- draw text
	if(ypos < 50) then ypos+= 4 end

	if flashstate then
		outline(line1,0,ypos,0,col1)
		outline(line2,0,ypos+10,0,col2)
	else
		outline(line1,0,ypos,1,col1)
		outline(line2,0,ypos+10,1,col2)
	end
end

function rectfill_p(x0,y0,x1,y1,p,c0,c1)
 fill_pattern(p)
 col=color_pattern(c0,c1)
 rectfill(x0,y0,x1,y1,col)
end

function fill_pattern(n)
 t={
 0b1111111111111111,
 0b1111111111110111,
 0b1111110111110111,
 0b1111110111110101,
 0b1111010111110101,
 0b1111010110110101,
 0b1110010110110101,
 0b1110010110100101,
 0b1010010110100101,
 0b1010010110100001,
 0b1010010010100001,
 0b1010010010100000,
 0b1010000010100000,
 0b1010000000100000,
 0b1000000000100000,
 0b1000000000000000,
 0b0000000000000000}
 if n<0 then n=0
 elseif n>16 then n=16 end
 fillp(t[n+1])
end

function color_pattern(c0,c1)
 t={0,1,2,3,4,5,6,7,8,9,
 "a","b","c","d","e","f"}
 return "0x"..t[c0+1]..t[c1+1]
end

function flash()
	flashcurrent+=1

	if flashcurrent > flashrate then
		flashstate = true
	else
		flashstate = false
	end

	if flashcurrent == flashrate * 2 then
		flashcurrent = 0
	end
end

function glitch()
	if g_on == true then -- on boolean is mangaged by the timer
		local t={7,6,10} -- create array of three colors
		local c=rnd(3) -- generate a random number between 1 and 3, we'll use this in a bit
		c=flr(c) -- make sure our random number is an integer and not a float
		for i=0, 5, 4 do -- the outer loop generates the vertical glitch dots
			local gl_height = rnd(glit.height)
			for h=0, 100, 2 do -- the inner loop creates longer horizontal lines
				pset(rnd(glit.width), gl_height, t[c]) -- write the random pixels to the screen and randomize the colors from the previously generated random number against out color array
			end
		end
	end

	-- animation timeline that turns the static on and off
	if glit.t>30 and glit.t < 50 then
		g_on=true
	elseif glit.t>70 and glit.t < 80 then
		g_on=true
	elseif glit.t>120 then
		glit.t = 0

	else
		g_on=false

	end
	glit.t+=1

	o1 = flr(rnd(0x1f00)) + 0x6040
 o2 = o1 + flr(rnd(0x4)-0x2)
 len = flr(rnd(0x40))

 memcpy(o1,o2,len)
end
__gfx__
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000
eeeeeeeee0eeeeeeeeeeeeeeeeeeeeeee0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000
eeeee0000800eeeeeeeeeeeeeeeee0000100eeeeeeeeeeeeeeeee0000100eeeeeeeeeeeeeeeee0000100eeeeeeeeeeeeeeeee0000100eeeeeeeeeeee00000000
eeeee07668610eeeeeeeeeeeeeeee07661610eeeeeeeeeeeeeeee08888820eeeeeeeeeeeeeeee0bbbbb30eeeeeeeeeeeeeeee0ccccc10eeeeeeeeeee00000000
ee00027261611000000eeeeeee00027268611000000eeeeeee00027888288000000eeeeeee00027bbb3bb000000eeeeeee00027ccc1cc000000eeeee00000000
e0777c76616c17777770eeeee0777c76686c17777770eeeee0888c78882c88888880eeeee0bbbc7bbb3cbbbbbbb0eeeee0cccc7ccc1cccccccc0eeee00000000
e07752777c70ccacaca0eeeee07752777c70ccacaca0eeeee08852777c78c8228220eeeee0bb52777c78cb33b330eeeee0cc52777c78cc11c110eeee00000000
e0777061611617777770eeeee0777061611617777770eeeee0288068888688888880eeeee02bb06b33333333bbb0eeeee02cc06c11111111ccc0eeee00000000
e0cacacaca0acacacac0eeeee0cacacaca0acacacac0eeeee0888818888888882220eeeee0bbbb1bbbbbbbbb3330eeeee0cccc1ccccccccc1110eeee00000000
e00cacacacacacacaca0eeeee00cacacacacacacaca0eeeee0000288888880000080eeeee00003bbbbbbb0000080eeeee00001ccccccc0000080eeee00000000
ee101116660666111000eeeeee101116660666111000eeeeee102222880880111000eeeeee103333bb0bb0111000eeeeee101111cc0cc0111000eeee00000000
eee0060000000006000eeeeeeee0060000000006000eeeeeee00060000000006000eeeeeee00060000000006000eeeeeee00060000000006000eeeee00000000
eeee000eeeeeee000eeeeeeeeeee000eeeeeee000eeeeeeeeeee000eeeeeee000eeeeeeeeeee000eeeeeee000eeeeeeeeeee000eeeeeee000eeeeeee00000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000
__map__
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0401000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0021000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
